#!/bin/bash
# ============================================================================
# Installation Julia
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION JULIA${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Julia
JULIA_VERSION="1.9.3"
cd /opt
wget -q "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

tar -xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
mv julia-${JULIA_VERSION} julia
ln -s /opt/julia/bin/julia /usr/local/bin/

echo -e "${GREEN}✅ Julia installé${NC}"
echo "Test: julia --version"
