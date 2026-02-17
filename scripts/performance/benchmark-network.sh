#!/bin/bash
# ============================================================================
# Benchmark Réseau - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Benchmark réseau..."

# Installer iperf3 si nécessaire
command -v iperf3 &> /dev/null || zypper install -y iperf3

# Test bande passante
for node in compute-01 compute-02; do
    echo "Test $node..."
    iperf3 -c "$node" -t 10 > "/tmp/iperf-$node.log" 2>&1
done

echo "✅ Benchmark réseau terminé"
echo "Résultats: /tmp/iperf-*.log"
