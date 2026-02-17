#!/bin/bash
# ============================================================================
# Monitoring Traefik
# ============================================================================

set -euo pipefail

echo "Monitoring Traefik..."

if curl -s http://localhost:8080/api/overview &> /dev/null; then
    # Métriques Traefik
    SERVICES=$(curl -s http://localhost:8080/api/http/services 2>/dev/null | jq -r '. | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/traefik.prom <<EOF
# TYPE traefik_services_total gauge
traefik_services_total $SERVICES
EOF
    
    echo "✅ Monitoring Traefik configuré"
else
    echo "⚠️  Traefik non disponible"
fi
