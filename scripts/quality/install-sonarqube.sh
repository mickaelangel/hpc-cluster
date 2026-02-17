#!/bin/bash
# ============================================================================
# Installation SonarQube - Qualité Code
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SONARQUBE${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/sonarqube-compose.yml <<EOF
version: '3.8'
services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
    restart: unless-stopped

volumes:
  sonarqube_data:
  sonarqube_extensions:
EOF

docker-compose -f /tmp/sonarqube-compose.yml up -d

echo -e "${GREEN}✅ SonarQube installé${NC}"
echo "URL: http://localhost:9000"
echo "Login: admin / admin"
