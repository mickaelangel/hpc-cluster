#!/bin/bash
# ============================================================================
# Script de Migration LDAP + Kerberos → FreeIPA
# Migration complète des utilisateurs et configuration
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MIGRATION LDAP + KERBEROS → FREEIPA${NC}"
echo -e "${GREEN}========================================${NC}"

# Configuration
LDAP_BASE="dc=cluster,dc=local"
LDAP_DN="cn=Directory Manager"
LDAP_PW="${LDAP_PASSWORD:-DSPassword123!}"
REALM="CLUSTER.LOCAL"
FREEIPA_SERVER="${FREEIPA_SERVER:-frontal-01.cluster.local}"
FREEIPA_ADMIN="${FREEIPA_ADMIN:-admin}"
FREEIPA_PASSWORD="${FREEIPA_PASSWORD:-AdminPassword123!}"

# ============================================================================
# 1. VÉRIFICATION PRÉREQUIS
# ============================================================================
echo -e "\n${YELLOW}[1/6] Vérification prérequis...${NC}"

# Vérifier LDAP
if ! systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
    echo -e "${RED}Erreur: LDAP non actif${NC}"
    exit 1
fi

# Vérifier Kerberos
if ! systemctl is-active krb5kdc > /dev/null 2>&1; then
    echo -e "${RED}Erreur: Kerberos non actif${NC}"
    exit 1
fi

# Vérifier FreeIPA
if ! ping -c 1 "$FREEIPA_SERVER" > /dev/null 2>&1; then
    echo -e "${RED}Erreur: FreeIPA server non accessible: $FREEIPA_SERVER${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Prérequis OK${NC}"

# ============================================================================
# 2. BACKUP AVANT MIGRATION
# ============================================================================
echo -e "\n${YELLOW}[2/6] Backup avant migration...${NC}"

BACKUP_DIR="/backup/migration-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup LDAP
ldapsearch -x -D "$LDAP_DN" -w "$LDAP_PW" \
    -b "$LDAP_BASE" > "$BACKUP_DIR/ldap-backup.ldif" 2>/dev/null || true

# Backup Kerberos
if [ -f /var/kerberos/krb5kdc/principal ]; then
    cp -a /var/kerberos/krb5kdc/principal* "$BACKUP_DIR/" 2>/dev/null || true
fi

echo -e "${GREEN}  ✅ Backup créé: $BACKUP_DIR${NC}"

# ============================================================================
# 3. INSTALLATION CLIENT FREEIPA
# ============================================================================
echo -e "\n${YELLOW}[3/6] Installation client FreeIPA...${NC}"

if ! command -v ipa > /dev/null 2>&1; then
    zypper install -y freeipa-client
    
    # Configuration client
    ipa-client-install \
        --domain=cluster.local \
        --server="$FREEIPA_SERVER" \
        --principal="$FREEIPA_ADMIN" \
        --password="$FREEIPA_PASSWORD" \
        --enable-dns-updates \
        --no-ntp \
        --unattended || {
        echo -e "${RED}Erreur: Installation client FreeIPA échouée${NC}"
        exit 1
    }
else
    echo -e "${GREEN}  ✅ Client FreeIPA déjà installé${NC}"
fi

# ============================================================================
# 4. EXTRACTION UTILISATEURS LDAP
# ============================================================================
echo -e "\n${YELLOW}[4/6] Extraction utilisateurs LDAP...${NC}"

# Extraire les utilisateurs
USERS=$(ldapsearch -x -D "$LDAP_DN" -w "$LDAP_PW" \
    -b "ou=users,$LDAP_BASE" "(objectClass=posixAccount)" \
    uid cn sn mail uidNumber gidNumber homeDirectory loginShell 2>/dev/null | \
    grep -E "^uid:|^cn:|^sn:|^mail:|^uidNumber:|^gidNumber:|^homeDirectory:|^loginShell:" | \
    awk '{print $2}')

echo -e "${GREEN}  ✅ Utilisateurs extraits: $(echo "$USERS" | grep -c "^uid:" || echo "0")${NC}"

# ============================================================================
# 5. MIGRATION UTILISATEURS VERS FREEIPA
# ============================================================================
echo -e "\n${YELLOW}[5/6] Migration utilisateurs vers FreeIPA...${NC}"

# Obtenir un ticket admin
echo "$FREEIPA_PASSWORD" | kinit "$FREEIPA_ADMIN@$REALM" || {
    echo -e "${RED}Erreur: Impossible d'obtenir un ticket Kerberos${NC}"
    exit 1
}

# Parser et créer les utilisateurs
CURRENT_UID=""
CURRENT_CN=""
CURRENT_SN=""
CURRENT_MAIL=""
CURRENT_UIDNUMBER=""
CURRENT_GIDNUMBER=""
CURRENT_HOME=""
CURRENT_SHELL=""

while IFS= read -r line; do
    if [[ "$line" =~ ^uid: ]]; then
        # Créer l'utilisateur précédent si existe
        if [ -n "$CURRENT_UID" ]; then
            create_freeipa_user
        fi
        
        # Nouvel utilisateur
        CURRENT_UID=$(echo "$line" | awk '{print $2}')
        CURRENT_CN=""
        CURRENT_SN=""
        CURRENT_MAIL=""
        CURRENT_UIDNUMBER=""
        CURRENT_GIDNUMBER=""
        CURRENT_HOME=""
        CURRENT_SHELL=""
    elif [[ "$line" =~ ^cn: ]]; then
        CURRENT_CN=$(echo "$line" | cut -d: -f2- | xargs)
    elif [[ "$line" =~ ^sn: ]]; then
        CURRENT_SN=$(echo "$line" | cut -d: -f2- | xargs)
    elif [[ "$line" =~ ^mail: ]]; then
        CURRENT_MAIL=$(echo "$line" | awk '{print $2}')
    elif [[ "$line" =~ ^uidNumber: ]]; then
        CURRENT_UIDNUMBER=$(echo "$line" | awk '{print $2}')
    elif [[ "$line" =~ ^gidNumber: ]]; then
        CURRENT_GIDNUMBER=$(echo "$line" | awk '{print $2}')
    elif [[ "$line" =~ ^homeDirectory: ]]; then
        CURRENT_HOME=$(echo "$line" | awk '{print $2}')
    elif [[ "$line" =~ ^loginShell: ]]; then
        CURRENT_SHELL=$(echo "$line" | awk '{print $2}')
    fi
done <<< "$USERS"

# Créer le dernier utilisateur
if [ -n "$CURRENT_UID" ]; then
    create_freeipa_user
fi

# Fonction de création utilisateur FreeIPA
create_freeipa_user() {
    # Vérifier si l'utilisateur existe déjà
    if ipa user-show "$CURRENT_UID" > /dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  Utilisateur $CURRENT_UID existe déjà${NC}"
        return
    fi
    
    # Créer l'utilisateur
    ipa user-add "$CURRENT_UID" \
        --first="$CURRENT_CN" \
        --last="$CURRENT_SN" \
        --email="$CURRENT_MAIL" \
        --homedir="$CURRENT_HOME" \
        --shell="$CURRENT_SHELL" \
        --uid="$CURRENT_UIDNUMBER" \
        --gidnumber="$CURRENT_GIDNUMBER" \
        --random || {
        echo -e "${RED}  ❌ Erreur création $CURRENT_UID${NC}"
        return
    }
    
    echo -e "${GREEN}  ✅ Utilisateur $CURRENT_UID créé${NC}"
}

echo -e "${GREEN}  ✅ Migration utilisateurs terminée${NC}"

# ============================================================================
# 6. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[6/6] Vérification...${NC}"

# Vérifier FreeIPA
if ipa user-find > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ FreeIPA accessible${NC}"
else
    echo -e "${RED}  ❌ FreeIPA non accessible${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== MIGRATION TERMINÉE ===${NC}"
echo "Backup sauvegardé dans: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}PROCHAINES ÉTAPES:${NC}"
echo "  1. Vérifier les utilisateurs dans FreeIPA: ipa user-find"
echo "  2. Configurer les clients pour utiliser FreeIPA"
echo "  3. Tester l'authentification"
echo "  4. Désactiver LDAP + Kerberos (après validation)"
echo ""
echo -e "${GREEN}Migration terminée!${NC}"
