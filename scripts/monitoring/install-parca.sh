#!/bin/bash
# ============================================================================
# Installation Parca - Continuous Profiling
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PARCA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/parca-compose.yml <<EOF
version: '3.8'
services:
  parca:
    image: ghcr.io/parca-dev/parca:latest
    ports:
      - "7070:7070"
    volumes:
      - parca_data:/data
    restart: unless-stopped

volumes:
  parca_data:
EOF

docker-compose -f /tmp/parca-compose.yml up -d

echo -e "${GREEN}✅ Parca installé${NC}"
echo "Parca: http://localhost:7070"
