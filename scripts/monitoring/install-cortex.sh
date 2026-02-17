#!/bin/bash
# ============================================================================
# Installation Cortex - Prometheus Long-Term Storage
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CORTEX${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/cortex-compose.yml <<EOF
version: '3.8'
services:
  cortex:
    image: quay.io/cortexproject/cortex:latest
    ports:
      - "9009:9009"
    command:
      - -target=all
      - -config.file=/etc/cortex/config.yaml
    volumes:
      - cortex_data:/cortex
    restart: unless-stopped

volumes:
  cortex_data:
EOF

docker-compose -f /tmp/cortex-compose.yml up -d

echo -e "${GREEN}✅ Cortex installé${NC}"
echo "Cortex: http://localhost:9009"
