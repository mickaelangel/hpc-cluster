#!/bin/bash
# ============================================================================
# Monitoring Performance Réseau MPI
# ============================================================================

set -euo pipefail

echo "Monitoring réseau MPI..."

# Test latence MPI
mpirun -np 2 pingpong

# Test bande passante MPI
mpirun -np 2 bandwidth

# Exporter métriques
cat > /var/lib/prometheus/node-exporter/mpi-network.prom <<EOF
# TYPE mpi_network_latency_seconds gauge
mpi_network_latency_seconds $(mpirun -np 2 pingpong 2>&1 | grep latency | awk '{print $NF}')

# TYPE mpi_network_bandwidth_bytes_per_second gauge
mpi_network_bandwidth_bytes_per_second $(mpirun -np 2 bandwidth 2>&1 | grep bandwidth | awk '{print $NF}')
EOF

echo "✅ Monitoring MPI configuré"
