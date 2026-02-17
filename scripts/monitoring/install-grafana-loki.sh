#!/bin/bash
# ============================================================================
# Installation Grafana Loki - Log Aggregation
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GRAFANA LOKI${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/loki-compose.yml <<EOF
version: '3.8'
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    restart: unless-stopped

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log:ro
      - ./promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
    restart: unless-stopped

volumes:
  loki_data:
EOF

docker-compose -f /tmp/loki-compose.yml up -d

echo -e "${GREEN}✅ Grafana Loki installé${NC}"
echo "Loki: http://localhost:3100"
