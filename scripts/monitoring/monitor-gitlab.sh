#!/bin/bash
# ============================================================================
# Monitoring GitLab
# ============================================================================

set -euo pipefail

echo "Monitoring GitLab..."

if curl -s http://gitlab.cluster.local/api/v4/version &> /dev/null; then
    # Métriques GitLab via API
    PROJECTS=$(curl -s -H "PRIVATE-TOKEN: token" http://gitlab.cluster.local/api/v4/projects 2>/dev/null | jq '. | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/gitlab.prom <<EOF
# TYPE gitlab_projects_total gauge
gitlab_projects_total $PROJECTS
EOF
    
    echo "✅ Monitoring GitLab configuré"
else
    echo "⚠️  GitLab non disponible"
fi
