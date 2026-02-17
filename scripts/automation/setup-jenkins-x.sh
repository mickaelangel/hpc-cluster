#!/bin/bash
# ============================================================================
# Installation Jenkins X
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION JENKINS X${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation jx CLI
cd /tmp
wget -q https://github.com/jenkins-x/jx/releases/download/v3.12.0/jx-linux-amd64.tar.gz
tar -xzf jx-linux-amd64.tar.gz
mv jx /usr/local/bin/

echo -e "${GREEN}✅ Jenkins X CLI installé${NC}"
echo -e "${YELLOW}⚠️  Bootstrap nécessite Kubernetes${NC}"
