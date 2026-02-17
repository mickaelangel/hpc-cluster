#!/bin/bash
# ============================================================================
# Export hors ligne COMPLET – tire les images puis exporte tout
# À lancer sur une machine AVEC Internet avant de copier sur clé USB
# Usage: sudo bash scripts/deployment/export-hors-ligne-complet.sh
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
echo -e "${BLUE}EXPORT HORS LIGNE COMPLET (avec images)${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Pull des images du compose open-source
echo -e "\n${YELLOW}[1/2] Téléchargement des images Docker...${NC}"
docker compose -f docker/docker-compose-opensource.yml pull 2>/dev/null || \
docker-compose -f docker/docker-compose-opensource.yml pull 2>/dev/null || true

# Images utilisées par le compose (pour export même si pas dans le compose build)
for img in opensuse/leap:15.4 prom/prometheus:v2.48.0 grafana/grafana:10.2.0 influxdb:2.7 grafana/loki:2.9.0 grafana/promtail:2.9.0 jupyterhub/jupyterhub:4.0; do
    docker pull "$img" 2>/dev/null || true
done

echo -e "${GREEN}  ✅ Images prêtes${NC}"

# 2. Export complet (configs + scripts + images)
echo -e "\n${YELLOW}[2/2] Export (configs, scripts, docs, images)...${NC}"
bash "$SCRIPT_DIR/export-complete-demo.sh"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Copiez l'archive export-demo/hpc-cluster-demo-*.tar.gz sur la clé USB${NC}"
echo -e "${GREEN}Sur le serveur SUSE 15 SP4: tar -xzf ... && cd hpc-cluster-demo-* && sudo ./install-demo.sh${NC}"
echo -e "${GREEN}========================================${NC}"
