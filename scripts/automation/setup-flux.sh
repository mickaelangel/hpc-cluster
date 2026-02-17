#!/bin/bash
# ============================================================================
# Configuration Flux GitOps
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION FLUX${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Flux CLI
if command -v kubectl &> /dev/null; then
    curl -s https://fluxcd.io/install.sh | bash
    
    # Bootstrap Flux
    flux bootstrap github --owner=cluster-hpc --repository=cluster-config || {
        echo -e "${YELLOW}⚠️  Bootstrap nécessite repository Git${NC}"
    }
    
    echo -e "${GREEN}✅ Flux installé${NC}"
else
    echo -e "${YELLOW}⚠️  Kubernetes requis${NC}"
fi
