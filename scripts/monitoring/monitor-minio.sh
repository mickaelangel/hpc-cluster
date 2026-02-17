#!/bin/bash
# ============================================================================
# Monitoring MinIO
# ============================================================================

set -euo pipefail

echo "Monitoring MinIO..."

if curl -s http://localhost:9000/minio/health/live &> /dev/null; then
    # Métriques MinIO (nécessite API)
    BUCKETS=$(mc ls local 2>/dev/null | wc -l || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/minio.prom <<EOF
# TYPE minio_buckets_total gauge
minio_buckets_total $BUCKETS
EOF
    
    echo "✅ Monitoring MinIO configuré"
else
    echo "⚠️  MinIO non disponible"
fi
