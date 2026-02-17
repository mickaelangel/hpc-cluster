#!/bin/bash
# ============================================================================
# Installation Mimir - Prometheus Long-Term Storage
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION MIMIR${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/mimir-compose.yml <<EOF
version: '3.8'
services:
  mimir:
    image: grafana/mimir:latest
    ports:
      - "9009:9009"
    command:
      - -target=all
      - -config.file=/etc/mimir/config.yaml
    volumes:
      - mimir_data:/mimir
    restart: unless-stopped

volumes:
  mimir_data:
EOF

docker-compose -f /tmp/mimir-compose.yml up -d

echo -e "${GREEN}✅ Mimir installé${NC}"
echo "Mimir: http://localhost:9009"
