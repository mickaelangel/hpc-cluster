#!/bin/bash
# ============================================================================
# Installation Harbor - Registry Docker
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION HARBOR${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "${YELLOW}⚠️  Harbor nécessite configuration complexe${NC}"
echo -e "${YELLOW}Voir: https://goharbor.io/docs/${NC}"

# Installation via Docker Compose (exemple)
cat > /tmp/harbor-compose.yml <<EOF
version: '3.8'
services:
  harbor-core:
    image: goharbor/harbor-core:latest
    container_name: harbor-core
    ports:
      - "80:8080"
    depends_on:
      - redis
      - postgresql
    restart: unless-stopped
EOF

echo -e "${GREEN}✅ Configuration Harbor créée${NC}"
