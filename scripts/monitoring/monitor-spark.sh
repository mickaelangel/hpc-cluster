#!/bin/bash
# ============================================================================
# Monitoring Spark
# ============================================================================

set -euo pipefail

echo "Monitoring Spark..."

if command -v spark-submit &> /dev/null; then
    # Métriques Spark (nécessite Spark History Server)
    APPS=$(ps aux | grep -c "spark" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/spark.prom <<EOF
# TYPE spark_applications_active gauge
spark_applications_active $APPS
EOF
    
    echo "✅ Monitoring Spark configuré"
else
    echo "⚠️  Spark non disponible"
fi
