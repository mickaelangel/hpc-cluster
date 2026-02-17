#!/bin/bash
# ============================================================================
# Installation Tekton - CI/CD Pipelines
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TEKTON${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Tekton via kubectl
if kubectl cluster-info &> /dev/null; then
    kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    
    echo -e "${GREEN}✅ Tekton installé${NC}"
else
    echo -e "${YELLOW}⚠️  Kubernetes requis${NC}"
fi
