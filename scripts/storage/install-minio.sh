#!/bin/bash
# ============================================================================
# Installation MinIO - Stockage Objet
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION MINIO${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/minio-compose.yml <<EOF
version: '3.8'
services:
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: password
volumes:
  minio_data:
EOF

docker-compose -f /tmp/minio-compose.yml up -d

echo -e "${GREEN}✅ MinIO installé${NC}"
echo "URL: http://localhost:9000"
echo "Console: http://localhost:9001"
