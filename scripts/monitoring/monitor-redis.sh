#!/bin/bash
# ============================================================================
# Monitoring Redis
# ============================================================================

set -euo pipefail

echo "Monitoring Redis..."

if command -v redis-cli &> /dev/null; then
    # Métriques Redis
    INFO=$(redis-cli INFO)
    
    USED_MEMORY=$(echo "$INFO" | grep "used_memory:" | awk -F: '{print $2}')
    CONNECTED_CLIENTS=$(echo "$INFO" | grep "connected_clients:" | awk -F: '{print $2}')
    KEYS=$(echo "$INFO" | grep "db0:keys=" | awk -F= '{print $2}' | awk '{print $1}')
    
    cat > /var/lib/prometheus/node-exporter/redis.prom <<EOF
# TYPE redis_memory_used_bytes gauge
redis_memory_used_bytes $USED_MEMORY

# TYPE redis_connected_clients gauge
redis_connected_clients $CONNECTED_CLIENTS

# TYPE redis_keys_total gauge
redis_keys_total $KEYS
EOF
    
    echo "✅ Monitoring Redis configuré"
else
    echo "⚠️  Redis non disponible"
fi
