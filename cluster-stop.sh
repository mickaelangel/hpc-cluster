#!/bin/bash
# ============================================================================
# Arrêt propre du cluster HPC
# Usage: sudo ./cluster-stop.sh
# ============================================================================

set -uo pipefail

YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ARRÊT CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"

echo y | gluster volume stop gv_hpc 2>/dev/null || true
systemctl stop slurmd slurmctld 2>/dev/null || true
systemctl stop glusterd 2>/dev/null || true

docker compose -f docker/docker-compose-opensource.yml down 2>/dev/null || \
docker-compose -f docker/docker-compose-opensource.yml down 2>/dev/null || true
docker stop freeipa-server 2>/dev/null || true

echo -e "${YELLOW}Cluster arrêté.${NC}"
