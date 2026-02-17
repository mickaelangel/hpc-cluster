#!/bin/bash
# ============================================================================
# Installation Quantum ESPRESSO Plus
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION QUANTUM ESPRESSO PLUS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Spack avec optimisations
if command -v spack &> /dev/null; then
    spack install quantum-espresso +scalapack +elpa
    echo -e "${GREEN}✅ Quantum ESPRESSO Plus installé via Spack${NC}"
else
    echo -e "${YELLOW}⚠️  Spack requis${NC}"
fi
