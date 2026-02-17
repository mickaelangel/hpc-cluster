#!/bin/bash
# ============================================================================
# Installation Traefik - Reverse Proxy Avancé
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TRAEFIK${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/traefik-compose.yml <<EOF
version: '3.8'
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: unless-stopped
EOF

docker-compose -f /tmp/traefik-compose.yml up -d

echo -e "${GREEN}✅ Traefik installé${NC}"
echo "Dashboard: http://localhost:8080"
echo "HTTP: http://localhost:80"
