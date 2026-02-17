#!/bin/bash
# ============================================================================
# Health Check Avancé - Cluster HPC
# Vérification complète de la santé du cluster
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPORT_DIR="/var/log/health-checks"
DATE=$(date +%Y%m%d-%H%M%S)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HEALTH CHECK AVANCÉ - CLUSTER HPC${NC}"
echo -e "${BLUE}Date: $(date)${NC}"
echo -e "${BLUE}========================================${NC}"

mkdir -p "$REPORT_DIR"

# ============================================================================
# FONCTION VÉRIFICATION
# ============================================================================
check_service() {
    local name=$1
    local command=$2
    
    if eval "$command" &> /dev/null; then
        echo -e "${GREEN}✅ $name${NC}"
        echo "PASS: $name" >> "$REPORT_DIR/health-$DATE.txt"
        return 0
    else
        echo -e "${RED}❌ $name${NC}"
        echo "FAIL: $name" >> "$REPORT_DIR/health-$DATE.txt"
        return 1
    fi
}

# ============================================================================
# 1. SERVICES SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/8] Vérification services système...${NC}"

check_service "SSH" "systemctl is-active sshd"
check_service "NetworkManager" "systemctl is-active NetworkManager"
check_service "Chronyd" "systemctl is-active chronyd"

# ============================================================================
# 2. SERVICES AUTHENTIFICATION
# ============================================================================
echo -e "\n${YELLOW}[2/8] Vérification authentification...${NC}"

check_service "LDAP" "systemctl is-active dirsrv@* || ldapsearch -x -b 'dc=cluster,dc=local' -s base"
check_service "Kerberos KDC" "systemctl is-active krb5kdc || klist"
check_service "FreeIPA" "systemctl is-active ipa || ipa-server-status"

# ============================================================================
# 3. SERVICES SLURM
# ============================================================================
echo -e "\n${YELLOW}[3/8] Vérification Slurm...${NC}"

check_service "SlurmCTLD" "systemctl is-active slurmctld"
check_service "SlurmDBD" "systemctl is-active slurmdbd || true"
check_service "Slurm Access" "sinfo"

# ============================================================================
# 4. SERVICES STOCKAGE
# ============================================================================
echo -e "\n${YELLOW}[4/8] Vérification stockage...${NC}"

check_service "BeeGFS Management" "systemctl is-active beegfs-mgmtd"
check_service "BeeGFS Mount" "mountpoint -q /mnt/beegfs || df -h | grep beegfs"
check_service "Lustre" "mountpoint -q /mnt/lustre || df -h | grep lustre"

# ============================================================================
# 5. SERVICES MONITORING
# ============================================================================
echo -e "\n${YELLOW}[5/8] Vérification monitoring...${NC}"

check_service "Prometheus" "curl -s http://localhost:9090/-/healthy"
check_service "Grafana" "curl -s http://localhost:3000/api/health"
check_service "Node Exporter" "curl -s http://localhost:9100/metrics"
check_service "Telegraf" "systemctl is-active telegraf"

# ============================================================================
# 6. SERVICES SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[6/8] Vérification sécurité...${NC}"

check_service "Fail2ban" "systemctl is-active fail2ban"
check_service "Auditd" "systemctl is-active auditd"
check_service "Firewall" "systemctl is-active firewalld || systemctl is-active nftables"
check_service "Suricata" "systemctl is-active suricata || true"
check_service "Wazuh" "systemctl is-active wazuh-manager || true"

# ============================================================================
# 7. SERVICES APPLICATIONS
# ============================================================================
echo -e "\n${YELLOW}[7/8] Vérification applications...${NC}"

check_service "GROMACS" "module avail gromacs 2>&1 | grep -q gromacs || command -v gmx"
check_service "OpenFOAM" "module avail openfoam 2>&1 | grep -q openfoam || command -v simpleFoam"
check_service "Quantum ESPRESSO" "module avail quantum-espresso 2>&1 | grep -q quantum-espresso || command -v pw.x"
check_service "ParaView" "module avail paraview 2>&1 | grep -q paraview || command -v paraview"

# ============================================================================
# 8. RÉSEAU
# ============================================================================
echo -e "\n${YELLOW}[8/8] Vérification réseau...${NC}"

# Test connectivité
NODES=("frontal-01" "frontal-02" "compute-01" "compute-02")
for node in "${NODES[@]}"; do
    if ping -c 1 -W 1 "$node" &> /dev/null; then
        echo -e "${GREEN}✅ $node accessible${NC}"
    else
        echo -e "${RED}❌ $node non accessible${NC}"
    fi
done

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ HEALTH CHECK${NC}"
echo -e "${BLUE}========================================${NC}"

PASSED=$(grep -c "PASS:" "$REPORT_DIR/health-$DATE.txt" || echo "0")
FAILED=$(grep -c "FAIL:" "$REPORT_DIR/health-$DATE.txt" || echo "0")
TOTAL=$((PASSED + FAILED))
SCORE=$((PASSED * 100 / TOTAL))

echo -e "${GREEN}✅ Réussies: $PASSED${NC}"
echo -e "${RED}❌ Échouées: $FAILED${NC}"
echo -e "${YELLOW}📊 Score: $SCORE%${NC}"

cat >> "$REPORT_DIR/health-$DATE.txt" <<EOF

## Résumé
Total: $TOTAL
Passed: $PASSED
Failed: $FAILED
Score: $SCORE%
EOF

echo -e "\n${BLUE}Rapport: $REPORT_DIR/health-$DATE.txt${NC}"
