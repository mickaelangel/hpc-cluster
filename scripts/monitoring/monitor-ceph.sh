#!/bin/bash
# ============================================================================
# Monitoring Ceph
# ============================================================================

set -euo pipefail

echo "Monitoring Ceph..."

if command -v ceph &> /dev/null; then
    # Métriques Ceph
    HEALTH=$(ceph health 2>/dev/null | awk '{print $1}' || echo "unknown")
    OSDs=$(ceph osd tree 2>/dev/null | grep -c "osd" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/ceph.prom <<EOF
# TYPE ceph_cluster_health gauge
ceph_cluster_health{status="$HEALTH"} 1

# TYPE ceph_osds_total gauge
ceph_osds_total $OSDs
EOF
    
    echo "✅ Monitoring Ceph configuré"
else
    echo "⚠️  Ceph non disponible"
fi
