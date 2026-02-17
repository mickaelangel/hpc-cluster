#!/bin/bash
# ============================================================================
# Installation Grafana Operator
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GRAFANA OPERATOR${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Helm (nécessite Kubernetes)
if command -v helm &> /dev/null && kubectl cluster-info &> /dev/null; then
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    helm install grafana-operator grafana/grafana-operator
    
    echo -e "${GREEN}✅ Grafana Operator installé${NC}"
else
    echo -e "${YELLOW}⚠️  Kubernetes et Helm requis${NC}"
fi
