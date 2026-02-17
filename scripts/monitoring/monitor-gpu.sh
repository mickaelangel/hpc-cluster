#!/bin/bash
# ============================================================================
# Monitoring GPU si Disponible
# ============================================================================

set -euo pipefail

echo "Monitoring GPU..."

# Vérifier si NVIDIA GPU disponible
if command -v nvidia-smi &> /dev/null; then
    # Exporter métriques GPU
    nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits | while read line; do
        GPU_UTIL=$(echo $line | awk '{print $1}')
        MEM_USED=$(echo $line | awk '{print $2}')
        MEM_TOTAL=$(echo $line | awk '{print $3}')
        TEMP=$(echo $line | awk '{print $4}')
        
        cat >> /var/lib/prometheus/node-exporter/gpu.prom <<EOF
# TYPE gpu_utilization_percent gauge
gpu_utilization_percent $GPU_UTIL

# TYPE gpu_memory_used_bytes gauge
gpu_memory_used_bytes $MEM_USED

# TYPE gpu_memory_total_bytes gauge
gpu_memory_total_bytes $MEM_TOTAL

# TYPE gpu_temperature_celsius gauge
gpu_temperature_celsius $TEMP
EOF
    done
    
    echo "✅ Monitoring GPU configuré"
else
    echo "⚠️  GPU non disponible"
fi
