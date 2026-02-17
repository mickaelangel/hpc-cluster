#!/bin/bash
# ============================================================================
# Optimisation Automatique - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Optimisation automatique..."

# Optimiser CPU governor
CPU_UTIL=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%')
if [ $(echo "$CPU_UTIL < 50" | bc) -eq 1 ]; then
    cpupower frequency-set -g powersave
else
    cpupower frequency-set -g performance
fi

# Optimiser swappiness
MEM_AVAIL=$(free | grep Mem | awk '{print $7}')
MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
MEM_PERCENT=$(echo "scale=2; ($MEM_AVAIL / $MEM_TOTAL) * 100" | bc)

if [ $(echo "$MEM_PERCENT < 20" | bc) -eq 1 ]; then
    echo 10 > /proc/sys/vm/swappiness
else
    echo 60 > /proc/sys/vm/swappiness
fi

echo "✅ Optimisation terminée"
