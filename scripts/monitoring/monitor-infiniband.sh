#!/bin/bash
# ============================================================================
# Monitoring InfiniBand
# ============================================================================

set -euo pipefail

echo "Monitoring InfiniBand..."

# Vérifier si InfiniBand disponible
if command -v ibstat &> /dev/null; then
    # Exporter métriques IB
    cat > /var/lib/prometheus/node-exporter/infiniband.prom <<EOF
# TYPE infiniband_port_state gauge
infiniband_port_state{port="1"} $(ibstat | grep -c "Active" || echo "0")

# TYPE infiniband_link_width gauge
infiniband_link_width{port="1"} $(ibstat | grep "Link width" | awk '{print $NF}' | tr -d 'x' || echo "0")
EOF
    
    echo "✅ Monitoring InfiniBand configuré"
else
    echo "⚠️  InfiniBand non disponible"
fi
