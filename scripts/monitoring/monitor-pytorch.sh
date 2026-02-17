#!/bin/bash
# ============================================================================
# Monitoring PyTorch
# ============================================================================

set -euo pipefail

echo "Monitoring PyTorch..."

if command -v python3 &> /dev/null && python3 -c "import torch" 2>/dev/null; then
    # Métriques PyTorch
    JOBS=$(ps aux | grep -c "pytorch" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/pytorch.prom <<EOF
# TYPE pytorch_training_jobs_running gauge
pytorch_training_jobs_running $JOBS
EOF
    
    echo "✅ Monitoring PyTorch configuré"
else
    echo "⚠️  PyTorch non disponible"
fi
