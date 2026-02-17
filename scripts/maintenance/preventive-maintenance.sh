#!/bin/bash
# ============================================================================
# Maintenance Préventive Automatisée - Cluster HPC
# Tâches de maintenance préventive automatiques
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_DIR="/var/log/maintenance"
DATE=$(date +%Y%m%d)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MAINTENANCE PRÉVENTIVE${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$LOG_DIR"

# ============================================================================
# 1. NETTOYAGE SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/6] Nettoyage système...${NC}"

# Nettoyer packages inutilisés
zypper clean --all >> "$LOG_DIR/cleanup-$DATE.log" 2>&1

# Nettoyer cache
rm -rf /tmp/* >> "$LOG_DIR/cleanup-$DATE.log" 2>&1
rm -rf /var/tmp/* >> "$LOG_DIR/cleanup-$DATE.log" 2>&1

# Nettoyer logs anciens (garder 30 jours)
find /var/log -name "*.log" -mtime +30 -delete 2>/dev/null || true

echo -e "${GREEN}  ✅ Nettoyage terminé${NC}"

# ============================================================================
# 2. ROTATION LOGS
# ============================================================================
echo -e "\n${YELLOW}[2/6] Rotation logs...${NC}"

# Rotation logs Slurm
if [ -d /var/log/slurm ]; then
    find /var/log/slurm -name "*.log" -mtime +7 -exec gzip {} \; 2>/dev/null || true
    find /var/log/slurm -name "*.log.gz" -mtime +30 -delete 2>/dev/null || true
fi

# Rotation logs système
logrotate -f /etc/logrotate.conf 2>/dev/null || true

echo -e "${GREEN}  ✅ Rotation terminée${NC}"

# ============================================================================
# 3. VÉRIFICATION DISQUE
# ============================================================================
echo -e "\n${YELLOW}[3/6] Vérification espace disque...${NC}"

# Vérifier espace disque
df -h | while read line; do
    USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    if [ "$USAGE" -gt 80 ] 2>/dev/null; then
        echo -e "${YELLOW}  ⚠️  Espace disque > 80%: $line${NC}"
    fi
done

echo -e "${GREEN}  ✅ Vérification terminée${NC}"

# ============================================================================
# 4. VÉRIFICATION INTÉGRITÉ
# ============================================================================
echo -e "\n${YELLOW}[4/6] Vérification intégrité fichiers...${NC}"

if [ -f /var/lib/aide/aide.db ]; then
    aide --check >> "$LOG_DIR/aide-$DATE.log" 2>&1 || {
        echo -e "${RED}  ⚠️  Violations d'intégrité détectées !${NC}"
    }
fi

echo -e "${GREEN}  ✅ Vérification terminée${NC}"

# ============================================================================
# 5. MISE À JOUR SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[5/6] Vérification mises à jour sécurité...${NC}"

# Vérifier mises à jour sécurité
zypper list-updates --security >> "$LOG_DIR/updates-$DATE.log" 2>&1 || true

echo -e "${GREEN}  ✅ Vérification terminée${NC}"

# ============================================================================
# 6. OPTIMISATION BASE DE DONNÉES
# ============================================================================
echo -e "\n${YELLOW}[6/6] Optimisation bases de données...${NC}"

# PostgreSQL
if systemctl is-active --quiet postgresql; then
    su - postgres -c "vacuumdb --all --analyze" >> "$LOG_DIR/postgres-$DATE.log" 2>&1 || true
fi

# MongoDB
if systemctl is-active --quiet mongod; then
    mongo --eval "db.runCommand({compact: 'cluster_hpc'})" >> "$LOG_DIR/mongo-$DATE.log" 2>&1 || true
fi

echo -e "${GREEN}  ✅ Optimisation terminée${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== MAINTENANCE PRÉVENTIVE TERMINÉE ===${NC}"
echo "Logs: $LOG_DIR/"
echo "Date: $DATE"
