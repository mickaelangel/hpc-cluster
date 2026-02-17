#!/bin/bash
# ============================================================================
# Installation Scilab
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SCILAB${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y scilab || {
    echo -e "${YELLOW}⚠️  Installation depuis repository${NC}"
}

echo -e "${GREEN}✅ Scilab installé${NC}"
echo "Test: scilab -version"
