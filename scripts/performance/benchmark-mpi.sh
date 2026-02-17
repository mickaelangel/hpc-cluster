#!/bin/bash
# ============================================================================
# Benchmark MPI - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Benchmark MPI..."

# Test OSU Benchmarks si disponible
if command -v osu_bw &> /dev/null; then
    mpirun -np 2 osu_bw > /tmp/osu-bw.log
    mpirun -np 2 osu_latency > /tmp/osu-latency.log
    echo "✅ Benchmark MPI terminé"
else
    echo "⚠️  OSU Benchmarks non installés"
fi
