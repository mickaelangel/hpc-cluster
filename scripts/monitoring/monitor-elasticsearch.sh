#!/bin/bash
# ============================================================================
# Monitoring Elasticsearch
# ============================================================================

set -euo pipefail

echo "Monitoring Elasticsearch..."

if curl -s http://localhost:9200/_cluster/health &> /dev/null; then
    # Métriques Elasticsearch
    HEALTH=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status' || echo "unknown")
    DOCS=$(curl -s http://localhost:9200/_cat/indices?v 2>/dev/null | awk '{sum+=$7} END {print sum}' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/elasticsearch.prom <<EOF
# TYPE elasticsearch_cluster_health_status gauge
elasticsearch_cluster_health_status{status="$HEALTH"} 1

# TYPE elasticsearch_documents_total gauge
elasticsearch_documents_total $DOCS
EOF
    
    echo "✅ Monitoring Elasticsearch configuré"
else
    echo "⚠️  Elasticsearch non disponible"
fi
