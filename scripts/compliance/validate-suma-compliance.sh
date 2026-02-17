#!/bin/bash
# ============================================================================
# Script de Validation Conformité SUMA - Cluster HPC
# Validation intégration SUMA et conformité DISA STIG
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REPORT_DIR="/tmp/suma-compliance-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/suma-compliance-report.txt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VALIDATION CONFORMITÉ SUMA${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}Rapport: $REPORT_FILE${NC}"
echo -e "${GREEN}========================================${NC}"

# Compteurs
PASSED=0
FAILED=0

# Fonction de vérification
check_item() {
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
# 1. VÉRIFICATION SALT MINION
# ============================================================================
echo -e "\n${YELLOW}[1/4] Vérification Salt Minion...${NC}"

check_item "Salt Minion installé" \
    "rpm -q salt-minion" ""

check_item "Salt Minion actif" \
    "systemctl is-active salt-minion" "active"

check_item "Configuration SUMA présente" \
    "[ -f /etc/salt/minion.d/suma-defense.conf ]" ""

check_item "Vérification clé master activée" \
    "grep verify_master_pubkey_sign /etc/salt/minion.d/suma-defense.conf" "True"

# ============================================================================
# 2. VÉRIFICATION CONNEXION SUMA
# ============================================================================
echo -e "\n${YELLOW}[2/4] Vérification connexion SUMA...${NC}"

if command -v salt-call > /dev/null 2>&1; then
    check_item "Connexion au serveur SUMA" \
        "salt-call test.ping" "True"
else
    echo -e "${YELLOW}  ⚠️  salt-call non disponible${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# 3. VÉRIFICATION CONFORMITÉ DISA STIG
# ============================================================================
echo -e "\n${YELLOW}[3/4] Vérification conformité DISA STIG...${NC}"

check_item "IP Forwarding désactivé" \
    "sysctl net.ipv4.ip_forward" "0"

check_item "SSH Root login désactivé" \
    "grep PermitRootLogin /etc/ssh/sshd_config" "no"

check_item "Fail2ban actif" \
    "systemctl is-active fail2ban" "active"

check_item "Auditd actif" \
    "systemctl is-active auditd" "active"

check_item "AIDE configuré" \
    "[ -f /var/lib/aide/aide.db ]" ""

# ============================================================================
# 4. VÉRIFICATION AUDIT CVE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Vérification audit CVE...${NC}"

check_item "Cron audit CVE configuré" \
    "[ -f /etc/cron.d/suma-cve-audit ]" ""

if [ -d /var/log/suma ]; then
    CVE_LOGS=$(ls -1 /var/log/suma/cve-audit-*.log 2>/dev/null | wc -l)
    if [ "$CVE_LOGS" -gt 0 ]; then
        echo -e "${GREEN}  ✅ Logs CVE présents ($CVE_LOGS fichiers)${NC}" | tee -a "$REPORT_FILE"
        ((PASSED++))
    else
        echo -e "${YELLOW}  ⚠️  Aucun log CVE trouvé${NC}" | tee -a "$REPORT_FILE"
    fi
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}RÉSUMÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Tests réussis: ${PASSED}${NC}" | tee -a "$REPORT_FILE"
echo -e "${RED}Tests échoués: ${FAILED}${NC}" | tee -a "$REPORT_FILE"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ CONFORME SUMA - Tous les tests passent${NC}" | tee -a "$REPORT_FILE"
    exit 0
else
    echo -e "\n${RED}❌ NON CONFORME SUMA - Des corrections sont nécessaires${NC}" | tee -a "$REPORT_FILE"
    exit 1
fi
