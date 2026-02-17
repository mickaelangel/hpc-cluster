#!/bin/bash
# ============================================================================
# Installation VictoriaMetrics Complète
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION VICTORIAMETRICS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/victoriametrics-compose.yml <<EOF
version: '3.8'
services:
  victoriametrics:
    image: victoriametrics/victoria-metrics:latest
    container_name: victoriametrics
    ports:
      - "8428:8428"
    command:
      - '--storageDataPath=/victoria-metrics-data'
      - '--httpListenAddr=:8428'
    volumes:
      - victoriametrics_data:/victoria-metrics-data
    restart: unless-stopped

volumes:
  victoriametrics_data:
EOF

docker-compose -f /tmp/victoriametrics-compose.yml up -d

echo -e "${GREEN}✅ VictoriaMetrics installé${NC}"
echo "URL: http://localhost:8428"
