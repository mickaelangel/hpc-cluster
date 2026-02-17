#!/bin/bash
# ============================================================================
# Installation cAdvisor - Container Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CADVISOR${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/cadvisor-compose.yml <<EOF
version: '3.8'
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped
EOF

docker-compose -f /tmp/cadvisor-compose.yml up -d

echo -e "${GREEN}✅ cAdvisor installé${NC}"
echo "cAdvisor: http://localhost:8080"
