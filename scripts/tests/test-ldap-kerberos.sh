#!/bin/bash
# ============================================================================
# Script de Tests LDAP + Kerberos
# Tests détaillés d'authentification
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
TEST_USER="jdoe"
TEST_PASSWORD="TestPassword123!"

# Compteurs
PASSED=0
FAILED=0

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TESTS LDAP + KERBEROS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TESTS LDAP
# ============================================================================
echo -e "\n${YELLOW}[1/4] Tests LDAP...${NC}"

# Test service LDAP
if systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Service LDAP actif${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Service LDAP inactif${NC}"
    ((FAILED++))
fi

# Test connexion LDAP
if ldapsearch -x -b "$LDAP_BASE" -s base > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Connexion LDAP OK${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Connexion LDAP échouée${NC}"
    ((FAILED++))
fi

# Test recherche utilisateur
if ldapsearch -x -D "$LDAP_DN" -w "$LDAP_PW" \
    -b "$LDAP_BASE" "(uid=$TEST_USER)" > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Utilisateur $TEST_USER trouvé${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠️  Utilisateur $TEST_USER non trouvé (peut être normal)${NC}"
fi

# Test authentification LDAP
if ldapwhoami -x -D "uid=$TEST_USER,ou=users,$LDAP_BASE" \
    -w "$TEST_PASSWORD" > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Authentification LDAP OK${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠️  Authentification LDAP échouée (utilisateur peut ne pas exister)${NC}"
fi

# ============================================================================
# 2. TESTS KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[2/4] Tests Kerberos...${NC}"

# Test service KDC
if systemctl is-active krb5kdc > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Service KDC actif${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Service KDC inactif${NC}"
    ((FAILED++))
fi

# Test service Kadmin
if systemctl is-active kadmin > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Service Kadmin actif${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Service Kadmin inactif${NC}"
    ((FAILED++))
fi

# Test configuration Kerberos
if [ -f /etc/krb5.conf ]; then
    echo -e "${GREEN}  ✅ Configuration Kerberos présente${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Configuration Kerberos manquante${NC}"
    ((FAILED++))
fi

# Test ticket admin
if echo "${KERBEROS_ADMIN_PASSWORD:-AdminPassword123!}" | \
    kinit admin/admin@${REALM} > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Ticket admin obtenu${NC}"
    ((PASSED++))
    kdestroy
else
    echo -e "${RED}  ❌ Impossible d'obtenir ticket admin${NC}"
    ((FAILED++))
fi

# Test ticket utilisateur
if echo "$TEST_PASSWORD" | kinit ${TEST_USER}@${REALM} > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Ticket utilisateur obtenu${NC}"
    ((PASSED++))
    klist > /dev/null 2>&1 && echo -e "${GREEN}  ✅ Ticket valide${NC}" && ((PASSED++))
    kdestroy
else
    echo -e "${YELLOW}  ⚠️  Ticket utilisateur échoué (utilisateur peut ne pas exister)${NC}"
fi

# ============================================================================
# 3. TESTS INTÉGRATION
# ============================================================================
echo -e "\n${YELLOW}[3/4] Tests intégration...${NC}"

# Test SSSD
if systemctl is-active sssd > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Service SSSD actif${NC}"
    ((PASSED++))
    
    # Test résolution utilisateur
    if getent passwd $TEST_USER > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ Utilisateur résolu via SSSD${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}  ⚠️  Utilisateur non résolu (peut être normal)${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Service SSSD inactif (optionnel)${NC}"
fi

# Test PAM
if [ -f /etc/pam.d/common-auth ] && grep -q "pam_krb5\|pam_ldap" /etc/pam.d/common-auth; then
    echo -e "${GREEN}  ✅ PAM configuré pour LDAP/Kerberos${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠️  PAM non configuré pour LDAP/Kerberos${NC}"
fi

# ============================================================================
# 4. TESTS SSH AVEC KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[4/4] Tests SSH avec Kerberos...${NC}"

# Test configuration SSH
if grep -q "GSSAPIAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${GREEN}  ✅ SSH configuré pour Kerberos${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}  ⚠️  SSH non configuré pour Kerberos${NC}"
fi

# Test ticket pour SSH
if echo "$TEST_PASSWORD" | kinit ${TEST_USER}@${REALM} > /dev/null 2>&1; then
    # Test connexion SSH locale (si possible)
    if ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=yes \
        ${TEST_USER}@localhost "echo OK" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ SSH avec Kerberos fonctionnel${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}  ⚠️  SSH avec Kerberos non testable (connexion locale)${NC}"
    fi
    kdestroy
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}"
echo -e "${RED}Tests échoués: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ Tous les tests LDAP + Kerberos passent!${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Des tests ont échoué${NC}"
    exit 1
fi
