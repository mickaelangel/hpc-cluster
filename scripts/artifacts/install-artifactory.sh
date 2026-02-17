#!/bin/bash
# ============================================================================
# Installation Artifactory - Gestion Artifacts
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ARTIFACTORY${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/artifactory-compose.yml <<EOF
version: '3.8'
services:
  artifactory:
    image: docker.bintray.io/jfrog/artifactory-oss:latest
    container_name: artifactory
    ports:
      - "8081:8081"
    volumes:
      - artifactory_data:/var/opt/jfrog/artifactory
    restart: unless-stopped

volumes:
  artifactory_data:
EOF

docker-compose -f /tmp/artifactory-compose.yml up -d

echo -e "${GREEN}✅ Artifactory installé${NC}"
echo "URL: http://localhost:8081"
echo "Login: admin / password"
