#!/bin/bash
# ============================================================================
# Monitoring Compliance - DISA STIG, CIS Level 2, ANSSI BP-028
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPORT_DIR="/var/log/compliance"
DATE=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MONITORING COMPLIANCE${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$REPORT_DIR"

# ============================================================================
# FONCTION VÉRIFICATION
# ============================================================================
check_compliance() {
    local name=$1
    local command=$2
    local expected=$3
    
    result=$($command 2>&1 || echo "FAILED")
    
    if echo "$result" | grep -q "$expected"; then
        echo -e "${GREEN}✅ $name${NC}"
        echo "PASS: $name" >> "$REPORT_DIR/compliance-$DATE.txt"
        return 0
    else
        echo -e "${RED}❌ $name${NC}"
        echo "FAIL: $name - Got: $result" >> "$REPORT_DIR/compliance-$DATE.txt"
        return 1
    fi
}

# ============================================================================
# VÉRIFICATIONS DISA STIG
# ============================================================================
echo -e "\n${YELLOW}[1/3] Vérification DISA STIG...${NC}"

# STIG-1: Root login désactivé
check_compliance "STIG-1: Root login SSH" \
    "grep -E '^PermitRootLogin' /etc/ssh/sshd_config" \
    "no"

# STIG-2: Password authentication limitée
check_compliance "STIG-2: MaxAuthTries SSH" \
    "grep -E '^MaxAuthTries' /etc/ssh/sshd_config" \
    "3"

# STIG-3: Auditd actif
check_compliance "STIG-3: Auditd actif" \
    "systemctl is-active auditd" \
    "active"

# STIG-4: Fail2ban actif
check_compliance "STIG-4: Fail2ban actif" \
    "systemctl is-active fail2ban" \
    "active"

# STIG-5: Firewall actif
check_compliance "STIG-5: Firewall actif" \
    "systemctl is-active firewalld || systemctl is-active nftables" \
    "active"

# ============================================================================
# VÉRIFICATIONS CIS LEVEL 2
# ============================================================================
echo -e "\n${YELLOW}[2/3] Vérification CIS Level 2...${NC}"

# CIS-1: Updates automatiques
check_compliance "CIS-1: Updates automatiques" \
    "systemctl is-enabled zypper-autoupdate || systemctl is-enabled unattended-upgrades" \
    "enabled"

# CIS-2: Logs centralisés
check_compliance "CIS-2: Rsyslog configuré" \
    "systemctl is-active rsyslog" \
    "active"

# CIS-3: Intégrité fichiers
check_compliance "CIS-3: AIDE actif" \
    "systemctl is-active aidecheck || crontab -l | grep aide" \
    "aide"

# CIS-4: SELinux/AppArmor
check_compliance "CIS-4: SELinux/AppArmor" \
    "getenforce 2>/dev/null || aa-status 2>/dev/null | head -1" \
    "Enforcing\|enabled"

# ============================================================================
# VÉRIFICATIONS ANSSI BP-028
# ============================================================================
echo -e "\n${YELLOW}[3/3] Vérification ANSSI BP-028...${NC}"

# ANSSI-1: Authentification forte
check_compliance "ANSSI-1: PAM configuré" \
    "grep -E '^password.*pam_pwquality' /etc/pam.d/common-password 2>/dev/null || grep -E '^password.*pam_cracklib' /etc/pam.d/system-auth" \
    "pam_pwquality\|pam_cracklib"

# ANSSI-2: Chiffrement données
check_compliance "ANSSI-2: LUKS configuré" \
    "lsblk -f | grep -i luks || dmsetup ls | grep luks" \
    "luks"

# ANSSI-3: Monitoring sécurité
check_compliance "ANSSI-3: IDS actif" \
    "systemctl is-active suricata || systemctl is-active wazuh-manager || systemctl is-active ossec" \
    "active"

# ============================================================================
# RAPPORT FINAL
# ============================================================================
echo -e "\n${YELLOW}Génération rapport...${NC}"

PASSED=$(grep -c "PASS:" "$REPORT_DIR/compliance-$DATE.txt" || echo "0")
FAILED=$(grep -c "FAIL:" "$REPORT_DIR/compliance-$DATE.txt" || echo "0")
TOTAL=$((PASSED + FAILED))
SCORE=$((PASSED * 100 / TOTAL))

cat >> "$REPORT_DIR/compliance-$DATE.txt" <<EOF

## Résumé
Total: $TOTAL
Passed: $PASSED
Failed: $FAILED
Score: $SCORE%
EOF

echo -e "${GREEN}=== MONITORING COMPLIANCE TERMINÉ ===${NC}"
echo "Rapport: $REPORT_DIR/compliance-$DATE.txt"
echo "Score: $SCORE% ($PASSED/$TOTAL)"
