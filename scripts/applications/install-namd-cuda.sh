#!/bin/bash
# ============================================================================
# Installation NAMD avec Support CUDA
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NAMD CUDA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Spack avec CUDA
if command -v spack &> /dev/null; then
    spack install namd +cuda
    echo -e "${GREEN}✅ NAMD CUDA installé via Spack${NC}"
else
    echo -e "${YELLOW}⚠️  Spack requis${NC}"
fi
