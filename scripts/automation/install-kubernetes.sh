#!/bin/bash
# ============================================================================
# Installation Kubernetes - Orchestration Containers
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION KUBERNETES${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION KUBERNETES
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Kubernetes...${NC}"

# Installation kubeadm, kubelet, kubectl
zypper addrepo https://download.opensuse.org/repositories/devel:/kubic:/openSUSE_Tumbleweed_Kubic/openSUSE_Tumbleweed/devel:kubic:openSUSE_Tumbleweed_Kubic.repo || true
zypper refresh

zypper install -y \
    kubernetes-kubeadm \
    kubernetes-kubelet \
    kubectl || {
    echo -e "${YELLOW}  ⚠️  Installation depuis repository, voir documentation Kubernetes${NC}"
}

echo -e "${GREEN}  ✅ Kubernetes installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Kubernetes...${NC}"

# Désactiver swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Configuration sysctl
cat >> /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

echo -e "${GREEN}  ✅ Kubernetes configuré${NC}"

# ============================================================================
# 3. INITIALISATION (OPTIONNEL)
# ============================================================================
echo -e "\n${YELLOW}[3/3] Initialisation (optionnel)...${NC}"

echo -e "${YELLOW}  ⚠️  Initialisation manuelle requise:${NC}"
echo -e "${YELLOW}  kubeadm init${NC}"

echo -e "\n${GREEN}=== KUBERNETES INSTALLÉ ===${NC}"
echo "Pour initialiser: kubeadm init"
echo "Pour joindre nœud: kubeadm join"
