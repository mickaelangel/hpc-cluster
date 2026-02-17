#!/bin/bash
# ============================================================================
# Installation R
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION R${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y R R-base-devel

echo -e "${GREEN}✅ R installé${NC}"
echo "Test: R --version"
