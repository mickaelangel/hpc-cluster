#!/bin/bash
# ============================================================================
# Configuration Helm Charts pour Cluster
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION HELM CHARTS${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer structure Helm charts
mkdir -p helm-charts/cluster-hpc

cat > helm-charts/cluster-hpc/Chart.yaml <<EOF
apiVersion: v2
name: cluster-hpc
description: Helm chart for HPC Cluster
type: application
version: 0.1.0
appVersion: "1.0"
EOF

cat > helm-charts/cluster-hpc/values.yaml <<EOF
replicaCount: 1
image:
  repository: cluster-hpc
  tag: latest
service:
  type: ClusterIP
  port: 80
EOF

echo -e "${GREEN}✅ Helm charts créés${NC}"
