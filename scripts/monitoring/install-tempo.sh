#!/bin/bash
# ============================================================================
# Installation Tempo - Distributed Tracing
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TEMPO${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/tempo-compose.yml <<EOF
version: '3.8'
services:
  tempo:
    image: grafana/tempo:latest
    ports:
      - "3200:3200"
    command:
      - -config.file=/etc/tempo/config.yaml
    volumes:
      - tempo_data:/tmp/tempo
    restart: unless-stopped

volumes:
  tempo_data:
EOF

docker-compose -f /tmp/tempo-compose.yml up -d

echo -e "${GREEN}✅ Tempo installé${NC}"
echo "Tempo: http://localhost:3200"
