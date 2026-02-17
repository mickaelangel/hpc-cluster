#!/bin/bash
# ============================================================================
# Script de Synchronisation Utilisateurs
# Synchronisation LDAP ↔ Kerberos ou FreeIPA
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
LDAP_BASE="dc=cluster,dc=local"
LDAP_DN="cn=Directory Manager"
LDAP_PW="${LDAP_PASSWORD:-DSPassword123!}"
REALM="CLUSTER.LOCAL"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SYNCHRONISATION UTILISATEURS${NC}"
echo -e "${GREEN}LDAP ↔ Kerberos${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. EXTRACTION UTILISATEURS LDAP
# ============================================================================
echo -e "\n${YELLOW}[1/3] Extraction utilisateurs LDAP...${NC}"

if ! systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
    echo -e "${RED}Erreur: LDAP non actif${NC}"
    exit 1
fi

# Extraire les UID
LDAP_USERS=$(ldapsearch -x -D "$LDAP_DN" -w "$LDAP_PW" \
    -b "ou=users,$LDAP_BASE" "(objectClass=posixAccount)" \
    uid 2>/dev/null | grep "^uid:" | awk '{print $2}')

echo -e "${GREEN}  ✅ Utilisateurs LDAP: $(echo "$LDAP_USERS" | wc -l)${NC}"

# ============================================================================
# 2. EXTRACTION PRINCIPAUX KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[2/3] Extraction principaux Kerberos...${NC}"

if ! systemctl is-active krb5kdc > /dev/null 2>&1; then
    echo -e "${RED}Erreur: Kerberos non actif${NC}"
    exit 1
fi

# Obtenir un ticket admin
echo "${KERBEROS_ADMIN_PASSWORD:-AdminPassword123!}" | kinit admin/admin@${REALM} || {
    echo -e "${RED}Erreur: Impossible d'obtenir un ticket admin${NC}"
    exit 1
}

# Extraire les principaux utilisateurs (sans /admin, /host, etc.)
KERBEROS_USERS=$(kadmin.local -q "listprincs" 2>/dev/null | \
    grep "@${REALM}" | \
    grep -v "/admin@" | \
    grep -v "/host@" | \
    grep -v "krbtgt" | \
    sed "s/@${REALM}//" | \
    awk '{print $1}')

echo -e "${GREEN}  ✅ Principaux Kerberos: $(echo "$KERBEROS_USERS" | wc -l)${NC}"

# ============================================================================
# 3. SYNCHRONISATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Synchronisation...${NC}"

SYNCED=0
CREATED=0
MISSING=0

# Créer les principaux Kerberos manquants
while IFS= read -r user; do
    if [ -z "$user" ]; then
        continue
    fi
    
    # Vérifier si le principal existe
    if echo "$KERBEROS_USERS" | grep -q "^${user}$"; then
        echo -e "${GREEN}  ✅ $user: synchronisé${NC}"
        ((SYNCED++))
    else
        # Créer le principal
        echo -e "${YELLOW}  ⚠️  $user: création principal Kerberos...${NC}"
        kadmin.local -q "addprinc ${user}@${REALM}" <<< "${LDAP_PW}" <<< "${LDAP_PW}" 2>/dev/null || {
            echo -e "${RED}  ❌ Erreur création $user${NC}"
            ((MISSING++))
            continue
        }
        echo -e "${GREEN}  ✅ $user: principal créé${NC}"
        ((CREATED++))
    fi
done <<< "$LDAP_USERS"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== SYNCHRONISATION TERMINÉE ===${NC}"
echo "Utilisateurs synchronisés: $SYNCED"
echo "Principaux créés: $CREATED"
echo "Erreurs: $MISSING"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Vérifier que les mots de passe sont identiques"
echo "  - Tester l'authentification: kinit <user>@${REALM}"
echo ""
echo -e "${GREEN}Synchronisation terminée!${NC}"
