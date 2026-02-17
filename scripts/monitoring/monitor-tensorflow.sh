#!/bin/bash
# ============================================================================
# Monitoring TensorFlow
# ============================================================================

set -euo pipefail

echo "Monitoring TensorFlow..."

if command -v python3 &> /dev/null && python3 -c "import tensorflow" 2>/dev/null; then
    # Métriques TensorFlow
    JOBS=$(ps aux | grep -c "tensorflow" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/tensorflow.prom <<EOF
# TYPE tensorflow_training_jobs_running gauge
tensorflow_training_jobs_running $JOBS
EOF
    
    echo "✅ Monitoring TensorFlow configuré"
else
    echo "⚠️  TensorFlow non disponible"
fi
