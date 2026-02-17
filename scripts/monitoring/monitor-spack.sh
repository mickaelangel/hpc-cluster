#!/bin/bash
# ============================================================================
# Monitoring Spack
# ============================================================================

set -euo pipefail

echo "Monitoring Spack..."

if command -v spack &> /dev/null; then
    # Métriques Spack
    PACKAGES=$(spack find 2>/dev/null | wc -l || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/spack.prom <<EOF
# TYPE spack_installed_packages_total gauge
spack_installed_packages_total $PACKAGES
EOF
    
    echo "✅ Monitoring Spack configuré"
else
    echo "⚠️  Spack non disponible"
fi
