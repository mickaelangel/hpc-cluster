#!/bin/bash
# ============================================================================
# Monitoring SonarQube
# ============================================================================

set -euo pipefail

echo "Monitoring SonarQube..."

if curl -s http://localhost:9000/api/system/status &> /dev/null; then
    # Métriques SonarQube
    PROJECTS=$(curl -s http://localhost:9000/api/projects/search 2>/dev/null | jq -r '.components | length' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/sonarqube.prom <<EOF
# TYPE sonarqube_projects_total gauge
sonarqube_projects_total $PROJECTS
EOF
    
    echo "✅ Monitoring SonarQube configuré"
else
    echo "⚠️  SonarQube non disponible"
fi
