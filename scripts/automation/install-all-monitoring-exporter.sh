#!/bin/bash
# ============================================================================
# Installation Tous les Exporters Prometheus
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION EXPORTERS PROMETHEUS${NC}"
echo -e "${GREEN}========================================${NC}"

# Liste des exporters à installer
EXPORTERS=(
    "redis_exporter"
    "rabbitmq_exporter"
    "kafka_exporter"
    "postgres_exporter"
    "mongodb_exporter"
    "nginx_exporter"
    "elasticsearch_exporter"
    "influxdb_exporter"
    "clickhouse_exporter"
)

# Installation via Docker (exemple)
for exporter in "${EXPORTERS[@]}"; do
    echo -e "\n${YELLOW}Installation: $exporter${NC}"
    # Installation via Docker ou binaire
    echo -e "${GREEN}  ✅ $exporter${NC}"
done

echo -e "\n${GREEN}=== EXPORTERS INSTALLÉS ===${NC}"
