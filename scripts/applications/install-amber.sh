#!/bin/bash
# ============================================================================
# Installation AMBER - Molecular Dynamics
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION AMBER${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Spack
if command -v spack &> /dev/null; then
    spack install amber
    echo -e "${GREEN}✅ AMBER installé via Spack${NC}"
else
    echo -e "${YELLOW}⚠️  Spack requis${NC}"
fi
