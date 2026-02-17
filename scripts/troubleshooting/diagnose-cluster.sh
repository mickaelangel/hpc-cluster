#!/bin/bash
# ============================================================================
# Script de Diagnostic Complet - Cluster HPC
# Diagnostic automatique de tous les composants
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPORT_DIR="/tmp/cluster-diagnostic-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/diagnostic-report.txt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}DIAGNOSTIC CLUSTER HPC${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}Rapport: $REPORT_FILE${NC}"
echo -e "${GREEN}========================================${NC}"

# Fonction de diagnostic
diagnose() {
    local component="$1"
    local command="$2"
    
    echo -e "\n${BLUE}=== $component ===${NC}" | tee -a "$REPORT_FILE"
    echo "Commande: $command" | tee -a "$REPORT_FILE"
    echo "---" | tee -a "$REPORT_FILE"
    
    if eval "$command" >> "$REPORT_FILE" 2>&1; then
        echo -e "${GREEN}  ✅ $component OK${NC}"
    else
        echo -e "${RED}  ❌ $component PROBLÈME${NC}"
    fi
}

# ============================================================================
# 1. SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/8] Diagnostic système...${NC}"

diagnose "Uptime" "uptime"
diagnose "Charge système" "cat /proc/loadavg"
diagnose "Mémoire" "free -h"
diagnose "Disque" "df -h"
diagnose "CPU" "lscpu | grep -E 'CPU|Thread|Core|Socket'"

# ============================================================================
# 2. RÉSEAU
# ============================================================================
echo -e "\n${YELLOW}[2/8] Diagnostic réseau...${NC}"

diagnose "Interfaces réseau" "ip addr show"
diagnose "Routes" "ip route show"
diagnose "Connexions actives" "ss -tunap | head -20"
diagnose "DNS" "cat /etc/resolv.conf"
diagnose "Ping localhost" "ping -c 2 localhost"

# ============================================================================
# 3. SERVICES
# ============================================================================
echo -e "\n${YELLOW}[3/8] Diagnostic services...${NC}"

SERVICES=("sshd" "dirsrv@cluster" "krb5kdc" "kadmin" "slurmctld" "slurmd" "munge" "chronyd")

for service in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "$service"; then
        diagnose "Service $service" "systemctl status $service --no-pager"
    fi
done

# ============================================================================
# 4. LDAP
# ============================================================================
echo -e "\n${YELLOW}[4/8] Diagnostic LDAP...${NC}"

if systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
    diagnose "LDAP connexion" "ldapsearch -x -b 'dc=cluster,dc=local' -s base"
    diagnose "LDAP logs" "tail -20 /var/log/dirsrv/slapd-cluster/errors 2>/dev/null || echo 'Logs non disponibles'"
else
    echo -e "${YELLOW}  ⚠️  LDAP non actif${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# 5. KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[5/8] Diagnostic Kerberos...${NC}"

if systemctl is-active krb5kdc > /dev/null 2>&1; then
    diagnose "Kerberos KDC" "systemctl status krb5kdc --no-pager"
    diagnose "Kerberos logs" "tail -20 /var/log/krb5kdc.log 2>/dev/null || echo 'Logs non disponibles'"
    diagnose "Configuration Kerberos" "cat /etc/krb5.conf"
else
    echo -e "${YELLOW}  ⚠️  Kerberos non actif${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# 6. SLURM
# ============================================================================
echo -e "\n${YELLOW}[6/8] Diagnostic Slurm...${NC}"

if command -v scontrol > /dev/null 2>&1; then
    diagnose "Slurm ping" "scontrol ping"
    diagnose "Slurm nœuds" "sinfo -N -l"
    diagnose "Slurm jobs" "squeue"
    diagnose "Slurm configuration" "scontrol show config"
    diagnose "Slurm logs" "tail -20 /var/log/slurm/slurmctld.log 2>/dev/null || echo 'Logs non disponibles'"
else
    echo -e "${YELLOW}  ⚠️  Slurm non installé${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# 7. GPFS
# ============================================================================
echo -e "\n${YELLOW}[7/8] Diagnostic GPFS...${NC}"

if command -v mmgetstate > /dev/null 2>&1; then
    diagnose "GPFS état" "mmgetstate -a"
    diagnose "GPFS montages" "mount | grep gpfs"
    diagnose "GPFS quotas" "mmdefquota -j 2>/dev/null || echo 'Quotas non disponibles'"
else
    echo -e "${YELLOW}  ⚠️  GPFS non installé${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# 8. MONITORING
# ============================================================================
echo -e "\n${YELLOW}[8/8] Diagnostic monitoring...${NC}"

# Prometheus
if docker ps | grep -q prometheus || systemctl is-active prometheus > /dev/null 2>&1; then
    diagnose "Prometheus" "curl -s http://localhost:9090/-/healthy || echo 'Prometheus non accessible'"
else
    echo -e "${YELLOW}  ⚠️  Prometheus non actif${NC}" | tee -a "$REPORT_FILE"
fi

# Grafana
if docker ps | grep -q grafana || systemctl is-active grafana-server > /dev/null 2>&1; then
    diagnose "Grafana" "curl -s http://localhost:3000/api/health || echo 'Grafana non accessible'"
else
    echo -e "${YELLOW}  ⚠️  Grafana non actif${NC}" | tee -a "$REPORT_FILE"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}DIAGNOSTIC TERMINÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Rapport complet: $REPORT_FILE"
echo "Répertoire: $REPORT_DIR"
echo ""
echo -e "${YELLOW}Contenu du rapport:${NC}"
echo "  - Informations système"
echo "  - État des services"
echo "  - Logs d'erreurs"
echo "  - Configurations"
echo ""
echo -e "${GREEN}Diagnostic terminé!${NC}"
