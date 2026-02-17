#!/bin/bash
# ============================================================================
# Installation ClickHouse - Analytics Database
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CLICKHOUSE${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/clickhouse-compose.yml <<EOF
version: '3.8'
services:
  clickhouse:
    image: clickhouse/clickhouse-server:latest
    container_name: clickhouse
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - clickhouse_data:/var/lib/clickhouse
    restart: unless-stopped

volumes:
  clickhouse_data:
EOF

docker-compose -f /tmp/clickhouse-compose.yml up -d

echo -e "${GREEN}✅ ClickHouse installé${NC}"
echo "HTTP: http://localhost:8123"
echo "Native: localhost:9000"
