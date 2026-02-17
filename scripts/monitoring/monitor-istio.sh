#!/bin/bash
# ============================================================================
# Monitoring Istio
# ============================================================================

set -euo pipefail

echo "Monitoring Istio..."

if command -v istioctl &> /dev/null; then
    # Métriques Istio
    SERVICES=$(istioctl proxy-status 2>/dev/null | grep -c "SYNCED" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/istio.prom <<EOF
# TYPE istio_services_synced gauge
istio_services_synced $SERVICES
EOF
    
    echo "✅ Monitoring Istio configuré"
else
    echo "⚠️  Istio non disponible"
fi
