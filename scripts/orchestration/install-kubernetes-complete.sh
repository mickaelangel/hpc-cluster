#!/bin/bash
# ============================================================================
# Installation Kubernetes Complète
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION KUBERNETES${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via kubeadm
zypper install -y kubernetes-kubeadm kubernetes-kubelet kubernetes-client || {
    echo -e "${YELLOW}⚠️  Installation depuis repository${NC}"
}

# Initialisation cluster (nécessite configuration)
echo -e "${YELLOW}⚠️  Kubernetes nécessite configuration réseau et swap désactivé${NC}"
echo -e "${YELLOW}Voir: kubeadm init${NC}"

echo -e "${GREEN}✅ Kubernetes installé${NC}"
