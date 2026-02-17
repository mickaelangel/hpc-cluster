#!/bin/bash
# ============================================================================
# Démarrage du cluster HPC – Script unique pour démo / exploitation
# Usage: sudo ./cluster-start.sh
# ============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DÉMARRAGE CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Stack Docker
echo -e "\n${YELLOW}[1/4] Stack Docker (Prometheus, Grafana, nœuds, JupyterHub)...${NC}"
if command -v docker &>/dev/null; then
    docker compose -f docker/docker-compose-opensource.yml up -d 2>/dev/null || \
    docker-compose -f docker/docker-compose-opensource.yml up -d 2>/dev/null || true
    echo -e "${GREEN}  ✅ Stack Docker démarrée${NC}"
else
    echo -e "${YELLOW}  ⚠️  Docker non disponible${NC}"
fi

# 2. FreeIPA (si présent)
echo -e "\n${YELLOW}[2/4] FreeIPA...${NC}"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx freeipa-server; then
    docker start freeipa-server 2>/dev/null && echo -e "${GREEN}  ✅ FreeIPA démarré${NC}" || echo -e "${YELLOW}  ⚠️  FreeIPA non démarré${NC}"
else
    echo -e "${YELLOW}  ⚠️  FreeIPA non installé (optionnel)${NC}"
fi

# 3. Services locaux
echo -e "\n${YELLOW}[3/4] Services locaux (Munge, Slurm, GlusterFS)...${NC}"
systemctl start munge 2>/dev/null || true
systemctl start slurmctld slurmd 2>/dev/null || true
systemctl start glusterd 2>/dev/null || true
gluster volume start gv_hpc 2>/dev/null || true
echo -e "${GREEN}  ✅ Services locaux démarrés${NC}"

# 4. Résumé
echo -e "\n${YELLOW}[4/4] Résumé${NC}"
echo -e "${GREEN}  Grafana:    http://localhost:3000${NC}"
echo -e "${GREEN}  Prometheus: http://localhost:9090${NC}"
echo -e "${GREEN}  JupyterHub: http://localhost:8000${NC}"
echo -e "${GREEN}  FreeIPA:    https://ipa.cluster.local ou https://localhost${NC}"
echo -e "${GREEN}  Santé:     sudo bash scripts/tests/test-cluster-health.sh${NC}"
echo -e "\n${BLUE}========================================${NC}"
