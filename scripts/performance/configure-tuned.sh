#!/bin/bash
# ============================================================================
# Configuration Tuned - Profils Performance
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION TUNED${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Tuned...${NC}"

zypper install -y tuned || {
    echo -e "${RED}Erreur: Installation Tuned échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Tuned installé${NC}"

# ============================================================================
# 2. CONFIGURATION PROFIL HPC
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration profil HPC...${NC}"

# Créer profil personnalisé HPC
mkdir -p /etc/tuned/hpc-performance
cat > /etc/tuned/hpc-performance/tuned.conf <<EOF
[main]
summary=Optimized for HPC workloads

[cpu]
governor=performance
energy_perf_bias=performance
min_perf_pct=100

[vm]
transparent_huge_pages=always
swappiness=1

[sysctl]
vm.dirty_ratio=15
vm.dirty_background_ratio=5
kernel.sched_migration_cost_ns=5000000
kernel.sched_autogroup_enabled=0
EOF

echo -e "${GREEN}  ✅ Profil HPC créé${NC}"

# ============================================================================
# 3. ACTIVATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Activation profil...${NC}"

systemctl enable tuned
systemctl start tuned

tuned-adm profile hpc-performance || {
    echo -e "${YELLOW}  ⚠️  Activation profil échouée${NC}"
}

echo -e "${GREEN}  ✅ Profil activé${NC}"

echo -e "\n${GREEN}=== TUNED CONFIGURÉ ===${NC}"
echo "Profil actif: $(tuned-adm active)"
echo "Profils disponibles: $(tuned-adm list)"
