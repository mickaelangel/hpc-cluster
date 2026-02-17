#!/bin/bash
# ============================================================================
# Installation NAMD - Molecular Dynamics
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NAMD${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Spack
if command -v spack &> /dev/null; then
    spack install namd
    echo -e "${GREEN}✅ NAMD installé via Spack${NC}"
else
    echo -e "${YELLOW}⚠️  Spack requis${NC}"
fi
