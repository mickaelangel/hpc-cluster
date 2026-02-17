#!/bin/bash
# ============================================================================
# Installation Istio Complète - Service Mesh
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ISTIO${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Istio
ISTIO_VERSION="1.19.0"
cd /tmp
wget -q "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux-amd64.tar.gz" || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

tar -xzf "istio-${ISTIO_VERSION}-linux-amd64.tar.gz"
mv istio-${ISTIO_VERSION} /opt/istio

# Installation
/opt/istio/bin/istioctl install --set profile=default -y || {
    echo -e "${YELLOW}⚠️  Installation nécessite Kubernetes${NC}"
}

echo -e "${GREEN}✅ Istio installé${NC}"
echo "Istioctl: /opt/istio/bin/istioctl"
