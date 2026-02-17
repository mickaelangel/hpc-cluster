#!/bin/bash
# ============================================================================
# Monitoring Apptainer
# ============================================================================

set -euo pipefail

echo "Monitoring Apptainer..."

if command -v apptainer &> /dev/null; then
    # Métriques Apptainer
    CONTAINERS=$(ps aux | grep -c "apptainer" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/apptainer.prom <<EOF
# TYPE apptainer_containers_running gauge
apptainer_containers_running $CONTAINERS
EOF
    
    echo "✅ Monitoring Apptainer configuré"
else
    echo "⚠️  Apptainer non disponible"
fi
