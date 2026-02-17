#!/bin/bash
# ============================================================================
# Monitoring Artifactory
# ============================================================================

set -euo pipefail

echo "Monitoring Artifactory..."

if curl -s -u admin:password http://localhost:8081/artifactory/api/system/ping &> /dev/null; then
    # Métriques Artifactory
    ARTIFACTS=$(curl -s -u admin:password "http://localhost:8081/artifactory/api/storageinfo" 2>/dev/null | jq -r '.artifactsCount' || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/artifactory.prom <<EOF
# TYPE artifactory_artifacts_total gauge
artifactory_artifacts_total $ARTIFACTS
EOF
    
    echo "✅ Monitoring Artifactory configuré"
else
    echo "⚠️  Artifactory non disponible"
fi
