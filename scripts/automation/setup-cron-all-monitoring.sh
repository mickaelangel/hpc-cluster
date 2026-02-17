#!/bin/bash
# ============================================================================
# Configuration Cron pour Tous les Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION CRON MONITORING${NC}"
echo -e "${GREEN}========================================${NC}"

# Ajouter tous les scripts monitoring au cron (toutes les 5 minutes)
MONITORING_SCRIPTS=(
    "scripts/monitoring/monitor-redis.sh"
    "scripts/monitoring/monitor-rabbitmq.sh"
    "scripts/monitoring/monitor-kafka.sh"
    "scripts/monitoring/monitor-postgresql.sh"
    "scripts/monitoring/monitor-mongodb.sh"
    "scripts/monitoring/monitor-influxdb.sh"
    "scripts/monitoring/monitor-clickhouse.sh"
    "scripts/monitoring/monitor-elasticsearch.sh"
    "scripts/monitoring/monitor-nginx.sh"
    "scripts/monitoring/monitor-gitlab.sh"
    "scripts/monitoring/monitor-vault.sh"
    "scripts/monitoring/monitor-consul.sh"
    "scripts/monitoring/monitor-minio.sh"
    "scripts/monitoring/monitor-ceph.sh"
    "scripts/monitoring/monitor-glusterfs.sh"
    "scripts/monitoring/monitor-sonarqube.sh"
    "scripts/monitoring/monitor-artifactory.sh"
    "scripts/monitoring/monitor-harbor.sh"
    "scripts/monitoring/monitor-traefik.sh"
    "scripts/monitoring/monitor-istio.sh"
    "scripts/monitoring/monitor-kubernetes.sh"
    "scripts/monitoring/monitor-spark.sh"
    "scripts/monitoring/monitor-hadoop.sh"
    "scripts/monitoring/monitor-tensorflow.sh"
    "scripts/monitoring/monitor-pytorch.sh"
    "scripts/monitoring/monitor-jupyterhub.sh"
    "scripts/monitoring/monitor-spack.sh"
    "scripts/monitoring/monitor-nexus.sh"
    "scripts/monitoring/monitor-apptainer.sh"
)

# Créer crontab
CRON_FILE="/tmp/cron-monitoring"
> "$CRON_FILE"

for script in "${MONITORING_SCRIPTS[@]}"; do
    FULL_PATH="$(pwd)/$script"
    if [ -f "$FULL_PATH" ]; then
        echo "*/5 * * * * /bin/bash \"$FULL_PATH\" >> /var/log/monitoring.log 2>&1" >> "$CRON_FILE"
    fi
done

# Retirer les anciennes lignes de monitoring (monitoring.log) puis installer les nouvelles
(crontab -l 2>/dev/null | grep -v "monitoring.log" || true; cat "$CRON_FILE") | crontab -

echo -e "${GREEN}✅ Cron monitoring configuré${NC}"
echo "Vérifier: crontab -l"
