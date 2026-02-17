#!/bin/bash
# ============================================================================
# Télécharge les images Docker puis lance l'export complet
# Usage: cd "cluster hpc" && bash scripts/deployment/pull-and-export-images.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PULL IMAGES + EXPORT COMPLET${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "\n${YELLOW}[1/2] Téléchargement des images Docker...${NC}"
docker pull prom/prometheus:v2.48.0
docker pull grafana/grafana:10.2.0
docker pull influxdb:2.7
docker pull grafana/loki:2.9.0
docker pull grafana/promtail:2.9.0
docker pull jupyterhub/jupyterhub:4.0
docker pull opensuse/leap:15.4
echo -e "${GREEN}  ✅ Images téléchargées${NC}"

echo -e "\n${YELLOW}[2/2] Export complet...${NC}"
bash "$SCRIPT_DIR/export-complete-demo.sh"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Terminé. Archive dans export-demo/hpc-cluster-demo-*.tar.gz${NC}"
echo -e "${GREEN}========================================${NC}"
