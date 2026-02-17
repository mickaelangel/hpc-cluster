#!/bin/bash
# ============================================================================
# Monitoring ClickHouse
# ============================================================================

set -euo pipefail

echo "Monitoring ClickHouse..."

if curl -s http://localhost:8123/ping &> /dev/null; then
    # Métriques ClickHouse
    QUERIES=$(curl -s "http://localhost:8123/?query=SELECT count() FROM system.query_log WHERE event_time > now() - INTERVAL 1 HOUR" 2>/dev/null || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/clickhouse.prom <<EOF
# TYPE clickhouse_queries_per_hour gauge
clickhouse_queries_per_hour $QUERIES
EOF
    
    echo "✅ Monitoring ClickHouse configuré"
else
    echo "⚠️  ClickHouse non disponible"
fi
