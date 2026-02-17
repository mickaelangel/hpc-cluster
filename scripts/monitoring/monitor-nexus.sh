#!/bin/bash
# ============================================================================
# Monitoring Nexus
# ============================================================================

set -euo pipefail

echo "Monitoring Nexus..."

if curl -s http://localhost:8081/service/rest/v1/status &> /dev/null; then
    # Métriques Nexus
    REPOS=$(curl -s -u admin:admin123 http://localhost:8081/service/rest/v1/repositories 2>/dev/null | jq -r '. | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/nexus.prom <<EOF
# TYPE nexus_repositories_total gauge
nexus_repositories_total $REPOS
EOF
    
    echo "✅ Monitoring Nexus configuré"
else
    echo "⚠️  Nexus non disponible"
fi
