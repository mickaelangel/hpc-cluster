#!/bin/bash
# ============================================================================
# Monitoring InfluxDB
# ============================================================================

set -euo pipefail

echo "Monitoring InfluxDB..."

OUTDIR="/var/lib/prometheus/node-exporter"
[ -w "$OUTDIR" ] || OUTDIR="/tmp/node-exporter"
mkdir -p "$OUTDIR" 2>/dev/null || true

if curl -s http://localhost:8086/health &> /dev/null; then
    # Métriques InfluxDB (jq optionnel)
    DATABASES=$(curl -s http://localhost:8086/api/v2/buckets 2>/dev/null | jq -r '.buckets | length' 2>/dev/null || echo "0")
    
    if [ -w "$OUTDIR" ]; then
        cat > "$OUTDIR/influxdb.prom" <<EOF
# TYPE influxdb_databases_total gauge
influxdb_databases_total $DATABASES
EOF
    fi
    echo "✅ InfluxDB OK"
else
    echo "⚠️  InfluxDB non disponible"
fi
