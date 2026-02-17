#!/bin/bash
# ============================================================================
# Configuration GitOps avec ArgoCD
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION GITOPS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation ArgoCD via kubectl (nécessite Kubernetes)
if kubectl cluster-info &> /dev/null; then
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo -e "${GREEN}✅ ArgoCD installé${NC}"
    echo "Accès: kubectl port-forward svc/argocd-server -n argocd 8080:443"
else
    echo -e "${YELLOW}⚠️  Kubernetes requis${NC}"
fi
