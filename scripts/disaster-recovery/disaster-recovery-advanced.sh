#!/bin/bash
# ============================================================================
# Disaster Recovery Avancé Automatisé
# ============================================================================

set -euo pipefail

BACKUP_DIR="/backup/cluster-hpc"
RESTORE_DIR="/restore/cluster-hpc"

echo "Disaster recovery avancé..."

# Restaurer bases de données
if [ -f "$BACKUP_DIR/postgres-latest.sql" ]; then
    psql < "$BACKUP_DIR/postgres-latest.sql"
fi

if [ -d "$BACKUP_DIR/mongo-latest" ]; then
    mongorestore "$BACKUP_DIR/mongo-latest"
fi

# Restaurer configurations
if [ -f "$BACKUP_DIR/configs-latest.tar.gz" ]; then
    tar -xzf "$BACKUP_DIR/configs-latest.tar.gz" -C /
fi

# Restaurer données
if [ -f "$BACKUP_DIR/users-latest.tar.gz" ]; then
    tar -xzf "$BACKUP_DIR/users-latest.tar.gz" -C /
fi

# Redémarrer services
systemctl restart slurmctld
systemctl restart prometheus
systemctl restart grafana

echo "✅ Disaster recovery terminé"
