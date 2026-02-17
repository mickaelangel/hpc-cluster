#!/bin/bash
# ============================================================================
# Monitoring Kafka
# ============================================================================

set -euo pipefail

echo "Monitoring Kafka..."

if command -v kafka-topics.sh &> /dev/null; then
    # Métriques Kafka
    TOPICS=$(kafka-topics.sh --list --zookeeper localhost:2181 2>/dev/null | wc -l)
    
    cat > /var/lib/prometheus/node-exporter/kafka.prom <<EOF
# TYPE kafka_topics_total gauge
kafka_topics_total $TOPICS
EOF
    
    echo "✅ Monitoring Kafka configuré"
else
    echo "⚠️  Kafka non disponible"
fi
