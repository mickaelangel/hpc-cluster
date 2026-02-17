#!/bin/bash
# ============================================================================
# Setup Tous les Scripts de Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SETUP TOUS LES MONITORING${NC}"
echo -e "${GREEN}========================================${NC}"

# Liste tous les scripts monitoring
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

# Exécuter tous les scripts
for script in "${MONITORING_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo -e "\n${YELLOW}Exécution: $script${NC}"
        bash "$script" || {
            echo -e "${YELLOW}  ⚠️  Échec partiel${NC}"
        }
    fi
done

echo -e "\n${GREEN}=== SETUP MONITORING TERMINÉ ===${NC}"
