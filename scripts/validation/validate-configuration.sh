#!/bin/bash
# ============================================================================
# Validation Configuration Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VALIDATION CONFIGURATION${NC}"
echo -e "${GREEN}========================================${NC}"

# Validation Slurm
echo -e "\n${YELLOW}[1/5] Validation Slurm...${NC}"
scontrol show config | grep -q "ClusterName" && echo -e "${GREEN}  ✅ Slurm configuré${NC}" || echo -e "${RED}  ❌ Slurm non configuré${NC}"

# Validation Prometheus
echo -e "\n${YELLOW}[2/5] Validation Prometheus...${NC}"
promtool check config /etc/prometheus/prometheus.yml && echo -e "${GREEN}  ✅ Prometheus configuré${NC}" || echo -e "${RED}  ❌ Prometheus non configuré${NC}"

# Validation Grafana
echo -e "\n${YELLOW}[3/5] Validation Grafana...${NC}"
[ -f /etc/grafana/grafana.ini ] && echo -e "${GREEN}  ✅ Grafana configuré${NC}" || echo -e "${RED}  ❌ Grafana non configuré${NC}"

# Validation Stockage
echo -e "\n${YELLOW}[4/5] Validation stockage...${NC}"
mountpoint -q /mnt/beegfs && echo -e "${GREEN}  ✅ BeeGFS monté${NC}" || echo -e "${RED}  ❌ BeeGFS non monté${NC}"

# Validation Réseau
echo -e "\n${YELLOW}[5/5] Validation réseau...${NC}"
ip addr show | grep -q "172.20.0" && echo -e "${GREEN}  ✅ Réseau configuré${NC}" || echo -e "${RED}  ❌ Réseau non configuré${NC}"

echo -e "\n${GREEN}=== VALIDATION TERMINÉE ===${NC}"
