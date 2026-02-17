#!/bin/bash
# ============================================================================
# Configuration Kustomize
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION KUSTOMIZE${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Kustomize
cd /tmp
wget -q https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.1.1/kustomize_v5.1.1_linux_amd64.tar.gz
tar -xzf kustomize_v5.1.1_linux_amd64.tar.gz
mv kustomize /usr/local/bin/

# Créer structure Kustomize
mkdir -p kustomize/base kustomize/overlays/production

cat > kustomize/base/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
EOF

echo -e "${GREEN}✅ Kustomize configuré${NC}"
