#!/bin/bash
# ============================================================================
# Monitoring RabbitMQ
# ============================================================================

set -euo pipefail

echo "Monitoring RabbitMQ..."

if curl -s -u admin:password http://localhost:15672/api/overview &> /dev/null; then
    # Métriques RabbitMQ via API
    OVERVIEW=$(curl -s -u admin:password http://localhost:15672/api/overview)
    
    QUEUES=$(echo "$OVERVIEW" | jq -r '.object_totals.queues // 0')
    CONNECTIONS=$(echo "$OVERVIEW" | jq -r '.object_totals.connections // 0')
    
    cat > /var/lib/prometheus/node-exporter/rabbitmq.prom <<EOF
# TYPE rabbitmq_queues_total gauge
rabbitmq_queues_total $QUEUES

# TYPE rabbitmq_connections_total gauge
rabbitmq_connections_total $CONNECTIONS
EOF
    
    echo "✅ Monitoring RabbitMQ configuré"
else
    echo "⚠️  RabbitMQ non disponible"
fi
