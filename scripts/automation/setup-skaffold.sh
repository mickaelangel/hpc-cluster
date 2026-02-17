#!/bin/bash
# ============================================================================
# Configuration Skaffold - CI/CD Kubernetes
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION SKAFFOLD${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Skaffold
cd /tmp
wget -q https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold-linux-amd64
mv skaffold-linux-amd64 /usr/local/bin/skaffold

# Configuration Skaffold
cat > skaffold.yaml <<EOF
apiVersion: skaffold/v4beta1
kind: Config
metadata:
  name: cluster-hpc
build:
  local:
    push: false
deploy:
  kubectl: {}
EOF

echo -e "${GREEN}✅ Skaffold configuré${NC}"
