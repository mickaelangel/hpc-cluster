#!/bin/bash
# ============================================================================
# Installation Icinga - Monitoring Open Source
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ICINGA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/icinga-compose.yml <<EOF
version: '3.8'
services:
  icinga2:
    image: icinga/icinga2:latest
    ports:
      - "5665:5665"
    volumes:
      - icinga_data:/var/lib/icinga2
    restart: unless-stopped

  icingaweb2:
    image: icinga/icingaweb2:latest
    ports:
      - "8080:80"
    depends_on:
      - icinga2
    restart: unless-stopped

volumes:
  icinga_data:
EOF

docker-compose -f /tmp/icinga-compose.yml up -d

echo -e "${GREEN}✅ Icinga installé${NC}"
echo "URL: http://localhost:8080"
