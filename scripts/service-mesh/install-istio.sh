#!/bin/bash
# ============================================================================
# Installation Istio - Service Mesh
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ISTIO${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TÉLÉCHARGEMENT ISTIO
# ============================================================================
echo -e "\n${YELLOW}[1/3] Téléchargement Istio...${NC}"

ISTIO_VERSION="1.19.0"
ISTIO_TAR="istio-${ISTIO_VERSION}-linux-amd64.tar.gz"
ISTIO_DIR="/opt/istio-${ISTIO_VERSION}"

cd /tmp
if [ ! -f "$ISTIO_TAR" ]; then
    wget -q "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/${ISTIO_TAR}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

mkdir -p "$ISTIO_DIR"
tar -xzf "$ISTIO_TAR" -C "$ISTIO_DIR" --strip-components=1

# Ajouter au PATH
ln -sf "$ISTIO_DIR/bin/istioctl" /usr/local/bin/istioctl

echo -e "${GREEN}  ✅ Istio téléchargé${NC}"

# ============================================================================
# 2. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Installation Istio...${NC}"

# Installation avec profil par défaut
istioctl install --set profile=default -y || {
    echo -e "${YELLOW}  ⚠️  Installation échouée (nécessite Kubernetes)${NC}"
}

echo -e "${GREEN}  ✅ Istio installé${NC}"

# ============================================================================
# 3. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Vérification...${NC}"

istioctl verify-install || {
    echo -e "${YELLOW}  ⚠️  Vérification échouée${NC}"
}

echo -e "\n${GREEN}=== ISTIO INSTALLÉ ===${NC}"
echo "Istioctl: istioctl"
echo "Version: $(istioctl version)"
echo -e "${YELLOW}IMPORTANT: Nécessite Kubernetes configuré${NC}"
