#!/bin/bash
# ============================================================================
# Monitoring GlusterFS
# ============================================================================

set -euo pipefail

echo "Monitoring GlusterFS..."

if command -v gluster &> /dev/null; then
    # Métriques GlusterFS
    VOLUMES=$(gluster volume list 2>/dev/null | wc -l || echo "0")
    BRICKS=$(gluster volume info all 2>/dev/null | grep -c "Brick" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/glusterfs.prom <<EOF
# TYPE glusterfs_volumes_total gauge
glusterfs_volumes_total $VOLUMES

# TYPE glusterfs_bricks_total gauge
glusterfs_bricks_total $BRICKS
EOF
    
    echo "✅ Monitoring GlusterFS configuré"
else
    echo "⚠️  GlusterFS non disponible"
fi
