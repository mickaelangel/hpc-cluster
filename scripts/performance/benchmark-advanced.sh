#!/bin/bash
# ============================================================================
# Benchmark Avancé - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Benchmark avancé cluster..."

# CPU Benchmark
echo "CPU Benchmark..."
sysbench cpu --cpu-max-prime=20000 run

# Memory Benchmark
echo "Memory Benchmark..."
sysbench memory run

# Disk I/O Benchmark
echo "Disk I/O Benchmark..."
sysbench fileio --file-total-size=10G prepare
sysbench fileio --file-total-size=10G --file-test-mode=rndrw run
sysbench fileio --file-total-size=10G cleanup

echo "✅ Benchmark terminé"
