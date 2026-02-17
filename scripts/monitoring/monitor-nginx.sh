#!/bin/bash
# ============================================================================
# Monitoring Nginx
# ============================================================================

set -euo pipefail

echo "Monitoring Nginx..."

if systemctl is-active --quiet nginx; then
    # Métriques Nginx (nécessite stub_status module)
    if curl -s http://localhost/nginx_status &> /dev/null; then
        STATUS=$(curl -s http://localhost/nginx_status)
        ACTIVE=$(echo "$STATUS" | awk '/Active connections/ {print $3}')
        REQUESTS=$(echo "$STATUS" | awk '/server accepts handled requests/ {print $4}')
        
        cat > /var/lib/prometheus/node-exporter/nginx.prom <<EOF
# TYPE nginx_connections_active gauge
nginx_connections_active $ACTIVE

# TYPE nginx_requests_total counter
nginx_requests_total $REQUESTS
EOF
        
        echo "✅ Monitoring Nginx configuré"
    else
        echo "⚠️  Module stub_status non activé"
    fi
else
    echo "⚠️  Nginx non disponible"
fi
