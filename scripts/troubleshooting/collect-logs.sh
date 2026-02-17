#!/bin/bash
# ============================================================================
# Script de Collection de Logs - Cluster HPC
# Collection automatique de tous les logs pour dépannage
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
LOG_DIR="/tmp/cluster-logs-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}COLLECTION LOGS CLUSTER HPC${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}Destination: $LOG_DIR${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. LOGS SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/6] Collection logs système...${NC}"

mkdir -p "$LOG_DIR/system"
journalctl --no-pager > "$LOG_DIR/system/journalctl.log" 2>/dev/null || true
dmesg > "$LOG_DIR/system/dmesg.log" 2>/dev/null || true
sysctl -a > "$LOG_DIR/system/sysctl.log" 2>/dev/null || true

echo -e "${GREEN}  ✅ Logs système collectés${NC}"

# ============================================================================
# 2. LOGS LDAP
# ============================================================================
echo -e "\n${YELLOW}[2/6] Collection logs LDAP...${NC}"

if [ -d /var/log/dirsrv ]; then
    mkdir -p "$LOG_DIR/ldap"
    cp -a /var/log/dirsrv/* "$LOG_DIR/ldap/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Logs LDAP collectés${NC}"
else
    echo -e "${YELLOW}  ⚠️  Logs LDAP non disponibles${NC}"
fi

# ============================================================================
# 3. LOGS KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[3/6] Collection logs Kerberos...${NC}"

mkdir -p "$LOG_DIR/kerberos"
[ -f /var/log/krb5kdc.log ] && cp /var/log/krb5kdc.log "$LOG_DIR/kerberos/" 2>/dev/null || true
[ -f /var/log/kadmin.log ] && cp /var/log/kadmin.log "$LOG_DIR/kerberos/" 2>/dev/null || true
[ -f /var/log/krb5lib.log ] && cp /var/log/krb5lib.log "$LOG_DIR/kerberos/" 2>/dev/null || true

echo -e "${GREEN}  ✅ Logs Kerberos collectés${NC}"

# ============================================================================
# 4. LOGS SLURM
# ============================================================================
echo -e "\n${YELLOW}[4/6] Collection logs Slurm...${NC}"

if [ -d /var/log/slurm ]; then
    mkdir -p "$LOG_DIR/slurm"
    cp -a /var/log/slurm/* "$LOG_DIR/slurm/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Logs Slurm collectés${NC}"
else
    echo -e "${YELLOW}  ⚠️  Logs Slurm non disponibles${NC}"
fi

# ============================================================================
# 5. LOGS MONITORING
# ============================================================================
echo -e "\n${YELLOW}[5/6] Collection logs monitoring...${NC}"

mkdir -p "$LOG_DIR/monitoring"

# Prometheus
if docker ps | grep -q prometheus; then
    docker logs prometheus > "$LOG_DIR/monitoring/prometheus.log" 2>&1 || true
fi

# Grafana
if docker ps | grep -q grafana; then
    docker logs grafana > "$LOG_DIR/monitoring/grafana.log" 2>&1 || true
fi

# Telegraf
if [ -f /var/log/telegraf/telegraf.log ]; then
    cp /var/log/telegraf/telegraf.log "$LOG_DIR/monitoring/" 2>/dev/null || true
fi

echo -e "${GREEN}  ✅ Logs monitoring collectés${NC}"

# ============================================================================
# 6. CONFIGURATIONS
# ============================================================================
echo -e "\n${YELLOW}[6/6] Collection configurations...${NC}"

mkdir -p "$LOG_DIR/configs"

# Configurations système
[ -f /etc/hosts ] && cp /etc/hosts "$LOG_DIR/configs/" 2>/dev/null || true
[ -f /etc/resolv.conf ] && cp /etc/resolv.conf "$LOG_DIR/configs/" 2>/dev/null || true
[ -f /etc/krb5.conf ] && cp /etc/krb5.conf "$LOG_DIR/configs/" 2>/dev/null || true
[ -f /etc/ssh/sshd_config ] && cp /etc/ssh/sshd_config "$LOG_DIR/configs/" 2>/dev/null || true

# Configurations Slurm
if [ -d /etc/slurm ]; then
    cp -a /etc/slurm/* "$LOG_DIR/configs/slurm/" 2>/dev/null || true
fi

# Configurations LDAP
if [ -d /etc/dirsrv ]; then
    cp -a /etc/dirsrv/* "$LOG_DIR/configs/ldap/" 2>/dev/null || true
fi

echo -e "${GREEN}  ✅ Configurations collectées${NC}"

# ============================================================================
# CRÉATION ARCHIVE
# ============================================================================
echo -e "\n${YELLOW}Création archive...${NC}"

cd /tmp
ARCHIVE_NAME="cluster-logs-$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$ARCHIVE_NAME" "$(basename $LOG_DIR)" 2>/dev/null || {
    echo -e "${RED}  ❌ Création archive échouée${NC}"
    exit 1
}

SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)
echo -e "${GREEN}  ✅ Archive créée: $ARCHIVE_NAME (${SIZE})${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== COLLECTION TERMINÉE ===${NC}"
echo "Répertoire: $LOG_DIR"
echo "Archive: /tmp/$ARCHIVE_NAME"
echo ""
echo "Contenu:"
echo "  ✅ Logs système"
echo "  ✅ Logs LDAP"
echo "  ✅ Logs Kerberos"
echo "  ✅ Logs Slurm"
echo "  ✅ Logs monitoring"
echo "  ✅ Configurations"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - L'archive contient des informations sensibles"
echo "  - Ne pas partager sans vérification"
echo "  - Supprimer après analyse"
echo ""
echo -e "${GREEN}Collection terminée!${NC}"
