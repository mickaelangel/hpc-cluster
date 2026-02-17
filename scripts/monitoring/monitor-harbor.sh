#!/bin/bash
# ============================================================================
# Monitoring Harbor
# ============================================================================

set -euo pipefail

echo "Monitoring Harbor..."

if curl -s http://localhost/api/v2.0/health &> /dev/null; then
    # Métriques Harbor
    PROJECTS=$(curl -s -u admin:Harbor12345 http://localhost/api/v2.0/projects 2>/dev/null | jq -r '. | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/harbor.prom <<EOF
# TYPE harbor_projects_total gauge
harbor_projects_total $PROJECTS
EOF
    
    echo "✅ Monitoring Harbor configuré"
else
    echo "⚠️  Harbor non disponible"
fi
