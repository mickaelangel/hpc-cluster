#!/bin/bash
# ============================================================================
# Installation Prometheus Operator
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PROMETHEUS OPERATOR${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Helm (nécessite Kubernetes)
if command -v helm &> /dev/null && kubectl cluster-info &> /dev/null; then
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install prometheus prometheus-community/kube-prometheus-stack
    
    echo -e "${GREEN}✅ Prometheus Operator installé${NC}"
else
    echo -e "${YELLOW}⚠️  Kubernetes et Helm requis${NC}"
fi
