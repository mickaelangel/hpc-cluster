#!/bin/bash
# ============================================================================
# Benchmark Stockage - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Benchmark stockage..."

# Test I/O séquentiel
fio --name=seq-read --rw=read --size=1G --output=/tmp/fio-seq-read.log

# Test I/O aléatoire
fio --name=rand-read --rw=randread --size=1G --output=/tmp/fio-rand-read.log

# Test écriture
fio --name=seq-write --rw=write --size=1G --output=/tmp/fio-seq-write.log

echo "✅ Benchmark stockage terminé"
echo "Résultats: /tmp/fio-*.log"
