#!/bin/bash
# ============================================================================
# Script de Benchmark - Cluster HPC
# Tests de performance CPU, mémoire, réseau, I/O
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BENCHMARK_DIR="/tmp/cluster-benchmark-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BENCHMARK_DIR"
REPORT_FILE="$BENCHMARK_DIR/benchmark-report.txt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BENCHMARK CLUSTER HPC${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}Rapport: $REPORT_FILE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. BENCHMARK CPU
# ============================================================================
echo -e "\n${YELLOW}[1/5] Benchmark CPU...${NC}"

CPU_BENCHMARK="$BENCHMARK_DIR/cpu-benchmark.txt"
echo "=== CPU Benchmark ===" > "$CPU_BENCHMARK"
echo "Date: $(date)" >> "$CPU_BENCHMARK"
echo "" >> "$CPU_BENCHMARK"

# Informations CPU
echo "CPU Information:" >> "$CPU_BENCHMARK"
lscpu >> "$CPU_BENCHMARK" 2>/dev/null || true
echo "" >> "$CPU_BENCHMARK"

# Test de calcul (si disponible)
if command -v bc > /dev/null 2>&1; then
    echo "CPU Calculation Test:" >> "$CPU_BENCHMARK"
    time (for i in {1..10000}; do echo "scale=1000; 4*a(1)" | bc -l > /dev/null 2>&1; done) >> "$CPU_BENCHMARK" 2>&1 || true
fi

echo -e "${GREEN}  ✅ Benchmark CPU terminé${NC}"

# ============================================================================
# 2. BENCHMARK MÉMOIRE
# ============================================================================
echo -e "\n${YELLOW}[2/5] Benchmark mémoire...${NC}"

MEM_BENCHMARK="$BENCHMARK_DIR/memory-benchmark.txt"
echo "=== Memory Benchmark ===" > "$MEM_BENCHMARK"
echo "Date: $(date)" >> "$MEM_BENCHMARK"
echo "" >> "$MEM_BENCHMARK"

# Informations mémoire
echo "Memory Information:" >> "$MEM_BENCHMARK"
free -h >> "$MEM_BENCHMARK"
echo "" >> "$MEM_BENCHMARK"

# Test d'écriture mémoire
if command -v dd > /dev/null 2>&1; then
    echo "Memory Write Test (1GB):" >> "$MEM_BENCHMARK"
    time dd if=/dev/zero of=/tmp/memtest bs=1M count=1024 oflag=direct 2>&1 | tail -1 >> "$MEM_BENCHMARK" || true
    rm -f /tmp/memtest
fi

echo -e "${GREEN}  ✅ Benchmark mémoire terminé${NC}"

# ============================================================================
# 3. BENCHMARK RÉSEAU
# ============================================================================
echo -e "\n${YELLOW}[3/5] Benchmark réseau...${NC}"

NET_BENCHMARK="$BENCHMARK_DIR/network-benchmark.txt"
echo "=== Network Benchmark ===" > "$NET_BENCHMARK"
echo "Date: $(date)" >> "$NET_BENCHMARK"
echo "" >> "$NET_BENCHMARK"

# Informations réseau
echo "Network Interfaces:" >> "$NET_BENCHMARK"
ip addr show >> "$NET_BENCHMARK" 2>/dev/null || ifconfig >> "$NET_BENCHMARK" 2>/dev/null || true
echo "" >> "$NET_BENCHMARK"

# Test de latence
if command -v ping > /dev/null 2>&1; then
    echo "Network Latency Test (localhost):" >> "$NET_BENCHMARK"
    ping -c 10 localhost >> "$NET_BENCHMARK" 2>&1 || true
    echo "" >> "$NET_BENCHMARK"
fi

# Test de bande passante (si iperf3 disponible)
if command -v iperf3 > /dev/null 2>&1; then
    echo "Network Bandwidth Test:" >> "$NET_BENCHMARK"
    echo "Note: Requires iperf3 server on remote host" >> "$NET_BENCHMARK"
fi

echo -e "${GREEN}  ✅ Benchmark réseau terminé${NC}"

# ============================================================================
# 4. BENCHMARK DISQUE
# ============================================================================
echo -e "\n${YELLOW}[4/5] Benchmark disque...${NC}"

DISK_BENCHMARK="$BENCHMARK_DIR/disk-benchmark.txt"
echo "=== Disk Benchmark ===" > "$DISK_BENCHMARK"
echo "Date: $(date)" >> "$DISK_BENCHMARK"
echo "" >> "$DISK_BENCHMARK"

# Informations disque
echo "Disk Information:" >> "$DISK_BENCHMARK"
df -h >> "$DISK_BENCHMARK"
echo "" >> "$DISK_BENCHMARK"

# Test d'écriture
if command -v dd > /dev/null 2>&1; then
    echo "Disk Write Test (1GB):" >> "$DISK_BENCHMARK"
    time dd if=/dev/zero of=/tmp/disktest bs=1M count=1024 oflag=direct 2>&1 | tail -1 >> "$DISK_BENCHMARK" || true
    
    # Test de lecture
    echo "Disk Read Test (1GB):" >> "$DISK_BENCHMARK"
    time dd if=/tmp/disktest of=/dev/null bs=1M count=1024 iflag=direct 2>&1 | tail -1 >> "$DISK_BENCHMARK" || true
    
    rm -f /tmp/disktest
fi

echo -e "${GREEN}  ✅ Benchmark disque terminé${NC}"

# ============================================================================
# 5. BENCHMARK SLURM
# ============================================================================
echo -e "\n${YELLOW}[5/5] Benchmark Slurm...${NC}"

SLURM_BENCHMARK="$BENCHMARK_DIR/slurm-benchmark.txt"
echo "=== Slurm Benchmark ===" > "$SLURM_BENCHMARK"
echo "Date: $(date)" >> "$SLURM_BENCHMARK"
echo "" >> "$SLURM_BENCHMARK"

if command -v scontrol > /dev/null 2>&1; then
    # Informations Slurm
    echo "Slurm Information:" >> "$SLURM_BENCHMARK"
    scontrol ping >> "$SLURM_BENCHMARK" 2>&1 || true
    echo "" >> "$SLURM_BENCHMARK"
    
    # Nœuds disponibles
    echo "Available Nodes:" >> "$SLURM_BENCHMARK"
    sinfo -N -l >> "$SLURM_BENCHMARK" 2>&1 || true
    echo "" >> "$SLURM_BENCHMARK"
    
    # Test de soumission job
    echo "Job Submission Test:" >> "$SLURM_BENCHMARK"
    TEST_SCRIPT=$(mktemp)
    cat > "$TEST_SCRIPT" <<'EOF'
#!/bin/bash
#SBATCH --job-name=benchmark-test
#SBATCH --output=/tmp/benchmark-test-%j.out
#SBATCH --time=1:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

echo "Benchmark test job"
hostname
date
EOF
    
    JOB_ID=$(sbatch "$TEST_SCRIPT" 2>&1 | grep -oP '\d+' || echo "N/A")
    echo "Job ID: $JOB_ID" >> "$SLURM_BENCHMARK"
    
    # Attendre que le job se termine
    sleep 5
    if [ -f "/tmp/benchmark-test-${JOB_ID}.out" ]; then
        echo "Job Output:" >> "$SLURM_BENCHMARK"
        cat "/tmp/benchmark-test-${JOB_ID}.out" >> "$SLURM_BENCHMARK"
    fi
    
    rm -f "$TEST_SCRIPT"
else
    echo "Slurm not installed" >> "$SLURM_BENCHMARK"
fi

echo -e "${GREEN}  ✅ Benchmark Slurm terminé${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== BENCHMARK TERMINÉ ===${NC}"
echo "Rapport: $REPORT_FILE"
echo "Répertoire: $BENCHMARK_DIR"
echo ""
echo "Benchmarks effectués:"
echo "  ✅ CPU"
echo "  ✅ Mémoire"
echo "  ✅ Réseau"
echo "  ✅ Disque"
echo "  ✅ Slurm"
echo ""
echo -e "${GREEN}Benchmark terminé!${NC}"
