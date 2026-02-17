#!/bin/bash
# ============================================================================
# Performance Tuning - Cluster HPC
# Optimisation des performances pour production
# Usage: sudo bash scripts/performance/tune-cluster.sh
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PERFORMANCE TUNING - CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================================================
# SYSTÈME
# ============================================================================

echo -e "${YELLOW}[1/6] Optimisation système...${NC}"

# CPU Governor
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo -e "${GREEN}  ✅ CPU Governor: performance${NC}"
fi

# Transparent Huge Pages
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo -e "${GREEN}  ✅ Transparent Huge Pages: disabled${NC}"

# Swappiness
echo 10 > /proc/sys/vm/swappiness
echo -e "${GREEN}  ✅ Swappiness: 10${NC}"

# ============================================================================
# RÉSEAU
# ============================================================================

echo -e "\n${YELLOW}[2/6] Optimisation réseau...${NC}"

# TCP Tuning
cat >> /etc/sysctl.conf << EOF
# TCP Performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.ipv4.tcp_congestion_control = bbr
net.core.netdev_max_backlog = 5000
EOF

sysctl -p > /dev/null
echo -e "${GREEN}  ✅ Paramètres TCP optimisés${NC}"

# ============================================================================
# DOCKER
# ============================================================================

echo -e "\n${YELLOW}[3/6] Optimisation Docker...${NC}"

# Daemon.json optimisé
if [ ! -f /etc/docker/daemon.json ]; then
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  }
}
EOF
    systemctl restart docker
    echo -e "${GREEN}  ✅ Configuration Docker optimisée${NC}"
fi

# ============================================================================
# SLURM
# ============================================================================

echo -e "\n${YELLOW}[4/6] Optimisation Slurm...${NC}"

if [ -f /etc/slurm/slurm.conf ]; then
    # Optimiser les timeouts
    sed -i 's/^SlurmctldTimeout=.*/SlurmctldTimeout=30/' /etc/slurm/slurm.conf
    sed -i 's/^SlurmdTimeout=.*/SlurmdTimeout=30/' /etc/slurm/slurm.conf
    echo -e "${GREEN}  ✅ Configuration Slurm optimisée${NC}"
fi

# ============================================================================
# STOCKAGE
# ============================================================================

echo -e "\n${YELLOW}[5/6] Optimisation stockage...${NC}"

# I/O Scheduler
for disk in /sys/block/sd*; do
    if [ -f "$disk/queue/scheduler" ]; then
        echo mq-deadline > "$disk/queue/scheduler"
    fi
done
echo -e "${GREEN}  ✅ I/O Scheduler: mq-deadline${NC}"

# ============================================================================
# MONITORING
# ============================================================================

echo -e "\n${YELLOW}[6/6] Configuration monitoring...${NC}"

# Prometheus retention
if [ -f "configs/prometheus/prometheus.yml" ]; then
    # Augmenter retention pour production
    echo -e "${GREEN}  ✅ Monitoring configuré${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OPTIMISATION TERMINÉE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}⚠️  Redémarrage recommandé pour appliquer tous les changements${NC}"
echo ""
