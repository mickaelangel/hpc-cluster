#!/bin/bash
# ============================================================================
# Installation InfluxDB - Time-Series Database
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION INFLUXDB${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/influxdb-compose.yml <<EOF
version: '3.8'
services:
  influxdb:
    image: influxdb:2.7
    container_name: influxdb
    ports:
      - "8086:8086"
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME: admin
      DOCKER_INFLUXDB_INIT_PASSWORD: password
      DOCKER_INFLUXDB_INIT_ORG: cluster-hpc
      DOCKER_INFLUXDB_INIT_BUCKET: metrics
    volumes:
      - influxdb_data:/var/lib/influxdb2
    restart: unless-stopped

volumes:
  influxdb_data:
EOF

docker-compose -f /tmp/influxdb-compose.yml up -d

echo -e "${GREEN}✅ InfluxDB installé${NC}"
echo "URL: http://localhost:8086"
echo "Login: admin / password"
