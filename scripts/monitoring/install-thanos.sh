#!/bin/bash
# ============================================================================
# Installation Thanos - Prometheus Long-Term Storage
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION THANOS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/thanos-compose.yml <<EOF
version: '3.8'
services:
  thanos-sidecar:
    image: quay.io/thanos/thanos:v0.32.0
    command:
      - sidecar
      - --prometheus.url=http://prometheus:9090
      - --tsdb.path=/prometheus
    volumes:
      - prometheus_data:/prometheus
    restart: unless-stopped

  thanos-query:
    image: quay.io/thanos/thanos:v0.32.0
    command:
      - query
      - --http-address=0.0.0.0:10902
      - --grpc-address=0.0.0.0:10901
      - --query.auto-downsampling
    ports:
      - "10902:10902"
    restart: unless-stopped

volumes:
  prometheus_data:
EOF

docker-compose -f /tmp/thanos-compose.yml up -d

echo -e "${GREEN}✅ Thanos installé${NC}"
echo "Query: http://localhost:10902"
