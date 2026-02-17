#!/bin/bash
# ============================================================================
# Backup Avancé Automatisé - Cluster HPC
# ============================================================================

set -euo pipefail

BACKUP_DIR="/backup/cluster-hpc"
DATE=$(date +%Y%m%d-%H%M%S)

echo "Backup avancé cluster..."

# Backup bases de données
if systemctl is-active --quiet postgresql; then
    pg_dumpall > "$BACKUP_DIR/postgres-$DATE.sql"
fi

if systemctl is-active --quiet mongod; then
    mongodump --out "$BACKUP_DIR/mongo-$DATE"
fi

# Backup configurations
tar -czf "$BACKUP_DIR/configs-$DATE.tar.gz" /etc/slurm /etc/prometheus /etc/grafana

# Backup données utilisateurs
tar -czf "$BACKUP_DIR/users-$DATE.tar.gz" /home /mnt/beegfs /mnt/lustre

# Nettoyer backups anciens (garder 30 jours)
find "$BACKUP_DIR" -name "*.sql" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete

echo "✅ Backup terminé: $BACKUP_DIR"
