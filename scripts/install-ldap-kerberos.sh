#!/bin/bash
# ============================================================================
# Script d'Installation LDAP + Kerberos - Cluster HPC
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REALM=${REALM:-CLUSTER.LOCAL}
DOMAIN=${DOMAIN:-cluster.local}
LDAP_DN="cn=Directory Manager"
LDAP_PASSWORD=${LDAP_PASSWORD:-DSPassword123!}
KERBEROS_DB_PASSWORD=${KERBEROS_DB_PASSWORD:-KerberosDBPassword123!}
KERBEROS_ADMIN_PASSWORD=${KERBEROS_ADMIN_PASSWORD:-AdminPassword123!}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION LDAP + KERBEROS${NC}"
echo -e "${GREEN}Realm: ${REALM}${NC}"
echo -e "${GREEN}Domain: ${DOMAIN}${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION PRÉREQUIS
# ============================================================================
echo -e "\n${YELLOW}[1/8] Vérification des prérequis...${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erreur: Ce script doit être exécuté en tant que root${NC}"
    exit 1
fi

# Vérifier le nom d'hôte
if [ -z "$(hostname -f)" ]; then
    echo -e "${RED}Erreur: Le nom d'hôte FQDN doit être configuré${NC}"
    exit 1
fi

# ============================================================================
# 2. ACTIVATION MODULES SUSE
# ============================================================================
echo -e "\n${YELLOW}[2/8] Activation des modules SUSE...${NC}"

if command -v SUSEConnect &> /dev/null; then
    SUSEConnect -p PackageHub/15.7/x86_64 || true
fi

zypper --non-interactive --gpg-auto-import-keys refresh 2>/dev/null || true

# ============================================================================
# 3. INSTALLATION LDAP (389 Directory Server)
# ============================================================================
echo -e "\n${YELLOW}[3/8] Installation LDAP (389 Directory Server)...${NC}"

zypper --non-interactive install -y --no-recommends 389-ds 2>/dev/null || \
zypper --non-interactive install -y --no-recommends 389-ds lib389 2>/dev/null || true

# Configuration initiale (format dscreate si 389-ds 1.4+)
LDAP_BASE="dc=$(echo ${DOMAIN} | cut -d. -f1),dc=$(echo ${DOMAIN} | cut -d. -f2)"
cat > /tmp/ds.inf <<EOF
[general]
config_version = 2
full_machine_name = $(hostname -f)
strict_host_checking = False

[slapd]
instance_name = cluster
port = 389
root_password = ${LDAP_PASSWORD}

[backend-userroot]
sample_entries = yes
suffix = ${LDAP_BASE}
create_suffix_entry = True
EOF

# Installation silencieuse (dscreate pour 389-ds 1.4+, sinon setup-ds.pl)
if command -v dscreate &>/dev/null; then
    dscreate from-file /tmp/ds.inf 2>/dev/null || {
        echo -e "${YELLOW}Instance LDAP peut déjà exister${NC}"
        dsctl cluster status 2>/dev/null || true
    }
    true
else
    cat > /tmp/ds.inf.legacy <<LEGEOF
[General]
FullMachineName = $(hostname -f)
SuiteSpotUserID = dirsrv
SuiteSpotGroup = dirsrv
AdminDomain = ${DOMAIN}
ConfigDirectoryAdminID = admin
ConfigDirectoryAdminPwd = ${LDAP_PASSWORD}
ConfigDirectoryLdapURL = ldap://$(hostname -f):389/o=NetscapeRoot

[slapd]
ServerPort = 389
ServerIdentifier = cluster
Suffix = ${LDAP_BASE}
RootDN = ${LDAP_DN}
RootDNPwd = ${LDAP_PASSWORD}
LEGEOF
    setup-ds.pl --silent --file /tmp/ds.inf.legacy 2>/dev/null || echo -e "${YELLOW}LDAP peut déjà être installé${NC}"
fi

# Démarrage
systemctl enable dirsrv@cluster
systemctl start dirsrv@cluster

# Attendre que le service soit prêt
sleep 5

# ============================================================================
# 4. CONFIGURATION LDAP DE BASE
# ============================================================================
echo -e "\n${YELLOW}[4/8] Configuration LDAP de base...${NC}"

LDAP_BASE="dc=$(echo ${DOMAIN} | cut -d. -f1),dc=$(echo ${DOMAIN} | cut -d. -f2)"

# Créer la structure de base
cat > /tmp/base.ldif <<EOF
dn: ${LDAP_BASE}
objectClass: top
objectClass: domain
dc: $(echo ${DOMAIN} | cut -d. -f1)

dn: ou=users,${LDAP_BASE}
objectClass: organizationalUnit
ou: users

dn: ou=groups,${LDAP_BASE}
objectClass: organizationalUnit
ou: groups

dn: ou=computers,${LDAP_BASE}
objectClass: organizationalUnit
ou: computers
EOF

# Ajouter la structure (ignorer si existe déjà)
ldapadd -x -D "${LDAP_DN}" -w "${LDAP_PASSWORD}" -f /tmp/base.ldif 2>/dev/null || {
    echo -e "${YELLOW}Structure LDAP existe déjà${NC}"
}

# ============================================================================
# 5. INSTALLATION KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[5/8] Installation Kerberos...${NC}"

zypper --non-interactive install -y krb5 krb5-server krb5-client

# Configuration /etc/krb5.conf
cat > /etc/krb5.conf <<EOF
[libdefaults]
    default_realm = ${REALM}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    default_tgs_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96
    default_tkt_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96

[realms]
    ${REALM} = {
        kdc = $(hostname -f):88
        admin_server = $(hostname -f):749
        default_domain = ${DOMAIN}
    }

[domain_realm]
    .${DOMAIN} = ${REALM}
    ${DOMAIN} = ${REALM}

[logging]
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
EOF

# ============================================================================
# 6. INITIALISATION KERBEROS KDC
# ============================================================================
echo -e "\n${YELLOW}[6/8] Initialisation Kerberos KDC...${NC}"

# Chemins Kerberos (SUSE met les binaires dans /usr/lib/mit/sbin)
KDB5_UTIL="kdb5_util"
KADMIN_LOCAL="kadmin.local"
[ -x /usr/lib/mit/sbin/kdb5_util ] && KDB5_UTIL="/usr/lib/mit/sbin/kdb5_util"
[ -x /usr/lib/mit/sbin/kadmin.local ] && KADMIN_LOCAL="/usr/lib/mit/sbin/kadmin.local"

# Créer la base de données Kerberos (kdb5_util lit le mot de passe depuis le TTY)
if [ ! -f /var/lib/kerberos/krb5kdc/principal ] && [ ! -f /var/kerberos/krb5kdc/principal ]; then
    if command -v script &>/dev/null; then
        script -q -c "printf '%s\n%s\n' '${KERBEROS_DB_PASSWORD}' '${KERBEROS_DB_PASSWORD}' | $KDB5_UTIL create -s -r ${REALM}" /dev/null || {
            echo -e "${RED}Erreur lors de la création de la base Kerberos${NC}"
            exit 1
        }
    else
        echo -e "${KERBEROS_DB_PASSWORD}" | $KDB5_UTIL create -s -r ${REALM} || {
            echo -e "${RED}Erreur lors de la création de la base Kerberos (essayez en mode interactif)${NC}"
            exit 1
        }
    fi
else
    echo -e "${YELLOW}Base de données Kerberos existe déjà${NC}"
fi

# Créer le fichier ACL
cat > /var/kerberos/krb5kdc/kadm5.acl <<EOF
*/admin@${REALM}    *
EOF

# Créer le principal admin
echo -e "${KERBEROS_ADMIN_PASSWORD}\n${KERBEROS_ADMIN_PASSWORD}" | \
    $KADMIN_LOCAL -q "addprinc admin/admin@${REALM}" 2>/dev/null || {
    echo -e "${YELLOW}Principal admin existe déjà${NC}"
}

# Créer le principal host
$KADMIN_LOCAL -q "addprinc -randkey host/$(hostname -f)@${REALM}" 2>/dev/null || true
$KADMIN_LOCAL -q "ktadd host/$(hostname -f)@${REALM}" 2>/dev/null || true

# Démarrage des services
systemctl enable krb5kdc
systemctl start krb5kdc

systemctl enable kadmin
systemctl start kadmin

# ============================================================================
# 7. CRÉATION UTILISATEUR TEST
# ============================================================================
echo -e "\n${YELLOW}[7/8] Création utilisateur test...${NC}"

TEST_USER="jdoe"
TEST_PASSWORD="TestPassword123!"

# Générer le hash du mot de passe
PASSWORD_HASH=$(slappasswd -s "${TEST_PASSWORD}" -h {SSHA})

# Créer l'utilisateur dans LDAP
cat > /tmp/user.ldif <<EOF
dn: uid=${TEST_USER},ou=users,${LDAP_BASE}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${TEST_USER}
cn: John Doe
sn: Doe
mail: ${TEST_USER}@${DOMAIN}
userPassword: ${PASSWORD_HASH}
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/${TEST_USER}
loginShell: /bin/bash
gecos: John Doe
EOF

ldapadd -x -D "${LDAP_DN}" -w "${LDAP_PASSWORD}" -f /tmp/user.ldif 2>/dev/null || {
    echo -e "${YELLOW}Utilisateur ${TEST_USER} existe déjà dans LDAP${NC}"
}

# Créer le principal Kerberos
echo -e "${TEST_PASSWORD}\n${TEST_PASSWORD}" | \
    kadmin.local -q "addprinc ${TEST_USER}@${REALM}" 2>/dev/null || {
    echo -e "${YELLOW}Principal ${TEST_USER} existe déjà${NC}"
}

# ============================================================================
# 8. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[8/8] Vérification de l'installation...${NC}"

# Vérifier LDAP
if ldapsearch -x -b "${LDAP_BASE}" -s base > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ LDAP fonctionnel${NC}"
else
    echo -e "${RED}  ❌ LDAP non accessible${NC}"
fi

# Vérifier Kerberos
if systemctl is-active krb5kdc > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Kerberos KDC actif${NC}"
else
    echo -e "${RED}  ❌ Kerberos KDC inactif${NC}"
fi

# Test d'authentification
if echo "${TEST_PASSWORD}" | kinit ${TEST_USER}@${REALM} 2>/dev/null; then
    echo -e "${GREEN}  ✅ Authentification Kerberos fonctionnelle${NC}"
    kdestroy
else
    echo -e "${YELLOW}  ⚠️  Test d'authentification Kerberos échoué${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== LDAP + KERBEROS INSTALLÉS ===${NC}"
echo "Realm: ${REALM}"
echo "Domain: ${DOMAIN}"
echo "LDAP Base: ${LDAP_BASE}"
echo "LDAP Port: 389 (LDAPS: 636)"
echo "Kerberos Port: 88 (Kadmin: 749)"
echo ""
echo "Utilisateur test créé:"
echo "  Username: ${TEST_USER}"
echo "  Password: ${TEST_PASSWORD}"
echo ""
echo "Commandes utiles:"
echo "  ldapsearch -x -b \"${LDAP_BASE}\"  # Rechercher dans LDAP"
echo "  kinit ${TEST_USER}@${REALM}        # Obtenir un ticket Kerberos"
echo "  klist                                # Vérifier les tickets"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Les utilisateurs doivent être créés dans LDAP ET Kerberos"
echo "  - Les mots de passe doivent être identiques dans les deux systèmes"
echo "  - Utiliser le script de synchronisation pour automatiser"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
