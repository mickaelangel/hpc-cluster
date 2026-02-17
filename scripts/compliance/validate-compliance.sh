#!/bin/bash
# ============================================================================
# Script de Validation de Conformité - Cluster HPC
# Validation DISA STIG, CIS Level 2, ANSSI BP-028
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REPORT_DIR="/tmp/compliance-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/compliance-report.txt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VALIDATION DE CONFORMITÉ${NC}"
echo -e "${GREEN}DISA STIG + CIS Level 2 + ANSSI BP-028${NC}"
echo -e "${GREEN}========================================${NC}"

# Compteurs
PASSED=0
FAILED=0
WARNINGS=0

# Fonction de vérification
check_compliance() {
    local name="$1"
    local command="$2"
    local expected="$3"
    
    echo -e "\n${YELLOW}Vérification: $name${NC}" | tee -a "$REPORT_FILE"
    
    if eval "$command" > /dev/null 2>&1; then
        if [ -n "$expected" ]; then
            RESULT=$(eval "$command" 2>/dev/null)
            if echo "$RESULT" | grep -q "$expected"; then
                echo -e "${GREEN}  ✅ PASS${NC}" | tee -a "$REPORT_FILE"
                ((PASSED++))
                return 0
            else
                echo -e "${RED}  ❌ FAIL${NC}" | tee -a "$REPORT_FILE"
                echo "    Attendu: $expected" | tee -a "$REPORT_FILE"
                echo "    Obtenu: $RESULT" | tee -a "$REPORT_FILE"
                ((FAILED++))
                return 1
            fi
        else
            echo -e "${GREEN}  ✅ PASS${NC}" | tee -a "$REPORT_FILE"
            ((PASSED++))
            return 0
        fi
    else
        echo -e "${RED}  ❌ FAIL${NC}" | tee -a "$REPORT_FILE"
        ((FAILED++))
        return 1
    fi
}

# ============================================================================
# 1. VÉRIFICATIONS SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/6] Vérifications système...${NC}"

check_compliance "IP Forwarding désactivé" \
    "sysctl net.ipv4.ip_forward" "0"

check_compliance "ICMP redirects désactivés" \
    "sysctl net.ipv4.conf.all.accept_redirects" "0"

check_compliance "Source routing désactivé" \
    "sysctl net.ipv4.conf.all.accept_source_route" "0"

# ============================================================================
# 2. VÉRIFICATIONS SSH
# ============================================================================
echo -e "\n${YELLOW}[2/6] Vérifications SSH...${NC}"

check_compliance "Root login désactivé" \
    "grep PermitRootLogin /etc/ssh/sshd_config" "no"

check_compliance "Empty passwords désactivés" \
    "grep PermitEmptyPasswords /etc/ssh/sshd_config" "no"

check_compliance "X11 forwarding désactivé" \
    "grep X11Forwarding /etc/ssh/sshd_config" "no"

# ============================================================================
# 3. VÉRIFICATIONS SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[3/6] Vérifications sécurité...${NC}"

check_compliance "Fail2ban actif" \
    "systemctl is-active fail2ban" "active"

check_compliance "Auditd actif" \
    "systemctl is-active auditd" "active"

check_compliance "AIDE configuré" \
    "[ -f /var/lib/aide/aide.db ]" ""

# ============================================================================
# 4. VÉRIFICATIONS SERVICES
# ============================================================================
echo -e "\n${YELLOW}[4/6] Vérifications services...${NC}"

# Services à désactiver
SERVICES_TO_DISABLE=("ctrl-alt-del.target" "debug-shell.service" "kdump.service")

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files | grep -q "$service"; then
        check_compliance "Service $service désactivé" \
            "systemctl is-enabled $service" "masked\|disabled"
    fi
done

# ============================================================================
# 5. VÉRIFICATIONS PERMISSIONS
# ============================================================================
echo -e "\n${YELLOW}[5/6] Vérifications permissions...${NC}"

check_compliance "SSH config permissions" \
    "stat -c %a /etc/ssh/sshd_config" "600"

check_compliance "Shadow permissions" \
    "stat -c %a /etc/shadow" "000\|640"

# ============================================================================
# 6. VÉRIFICATIONS PAM
# ============================================================================
echo -e "\n${YELLOW}[6/6] Vérifications PAM...${NC}"

check_compliance "PAM password quality" \
    "[ -f /etc/security/pwquality.conf ]" ""

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}" | tee -a "$REPORT_FILE"
echo -e "${RED}Tests échoués: ${FAILED}${NC}" | tee -a "$REPORT_FILE"
echo -e "${YELLOW}Avertissements: ${WARNINGS}${NC}" | tee -a "$REPORT_FILE"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ CONFORME - Tous les tests passent${NC}" | tee -a "$REPORT_FILE"
    exit 0
else
    echo -e "\n${RED}❌ NON CONFORME - Des corrections sont nécessaires${NC}" | tee -a "$REPORT_FILE"
    exit 1
fi
