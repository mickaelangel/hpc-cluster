#!/bin/bash
# ============================================================================
# Installation Maxima
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION MAXIMA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y maxima

echo -e "${GREEN}✅ Maxima installé${NC}"
echo "Test: maxima --version"
