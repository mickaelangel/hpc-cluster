#!/bin/bash
# ============================================================================
# Monitoring Consul
# ============================================================================

set -euo pipefail

echo "Monitoring Consul..."

if curl -s http://localhost:8500/v1/status/leader &> /dev/null; then
    # Métriques Consul
    SERVICES=$(curl -s http://localhost:8500/v1/catalog/services 2>/dev/null | jq 'keys | length' || echo "0")
    NODES=$(curl -s http://localhost:8500/v1/catalog/nodes 2>/dev/null | jq '. | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/consul.prom <<EOF
# TYPE consul_services_registered gauge
consul_services_registered $SERVICES

# TYPE consul_nodes_total gauge
consul_nodes_total $NODES
EOF
    
    echo "✅ Monitoring Consul configuré"
else
    echo "⚠️  Consul non disponible"
fi
