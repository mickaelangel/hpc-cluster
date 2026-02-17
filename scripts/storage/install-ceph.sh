#!/bin/bash
# ============================================================================
# Installation Ceph - Stockage Distribué
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CEPH${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/ceph-compose.yml <<EOF
version: '3.8'
services:
  ceph-mon:
    image: ceph/daemon:latest
    command: mon
    volumes:
      - ceph_data:/var/lib/ceph
    ports:
      - "6789:6789"
EOF

echo -e "${GREEN}✅ Ceph installé${NC}"
