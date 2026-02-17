#!/bin/bash
# ============================================================================
# Installation Drone CI
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION DRONE CI${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/drone-compose.yml <<EOF
version: '3.8'
services:
  drone-server:
    image: drone/drone:latest
    ports:
      - "80:80"
    environment:
      DRONE_GITEA_SERVER: http://gitlab.cluster.local
      DRONE_RPC_SECRET: secret
    volumes:
      - drone_data:/var/lib/drone
    restart: unless-stopped

  drone-runner:
    image: drone/drone-runner-docker:latest
    depends_on:
      - drone-server
    environment:
      DRONE_RPC_HOST: drone-server
      DRONE_RPC_SECRET: secret
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

volumes:
  drone_data:
EOF

docker-compose -f /tmp/drone-compose.yml up -d

echo -e "${GREEN}✅ Drone CI installé${NC}"
echo "URL: http://localhost:80"
