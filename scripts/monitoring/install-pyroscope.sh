#!/bin/bash
# ============================================================================
# Installation Pyroscope - Continuous Profiling
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PYROSCOPE${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/pyroscope-compose.yml <<EOF
version: '3.8'
services:
  pyroscope:
    image: pyroscope/pyroscope:latest
    ports:
      - "4040:4040"
    command:
      - server
    volumes:
      - pyroscope_data:/var/lib/pyroscope
    restart: unless-stopped

volumes:
  pyroscope_data:
EOF

docker-compose -f /tmp/pyroscope-compose.yml up -d

echo -e "${GREEN}✅ Pyroscope installé${NC}"
echo "Pyroscope: http://localhost:4040"
