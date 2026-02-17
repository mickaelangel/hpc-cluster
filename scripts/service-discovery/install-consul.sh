#!/bin/bash
# ============================================================================
# Installation Consul - Service Discovery
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CONSUL${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/consul-compose.yml <<EOF
version: '3.8'
services:
  consul:
    image: consul:latest
    container_name: consul
    command: agent -dev -client=0.0.0.0
    ports:
      - "8500:8500"
    volumes:
      - consul_data:/consul/data
    restart: unless-stopped

volumes:
  consul_data:
EOF

docker-compose -f /tmp/consul-compose.yml up -d

echo -e "${GREEN}✅ Consul installé${NC}"
echo "UI: http://localhost:8500"
echo "API: http://localhost:8500/v1"
