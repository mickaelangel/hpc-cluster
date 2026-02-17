#!/bin/bash
# ============================================================================
# Monitoring Hadoop
# ============================================================================

set -euo pipefail

echo "Monitoring Hadoop..."

if [ -d /opt/hadoop ]; then
    # Métriques Hadoop
    DATANODES=$(/opt/hadoop/bin/hdfs dfsadmin -report 2>/dev/null | grep -c "Live datanodes" || echo "0")
    
    cat > /var/lib/prometheus/node-exporter/hadoop.prom <<EOF
# TYPE hadoop_hdfs_datanodes_live gauge
hadoop_hdfs_datanodes_live $DATANODES
EOF
    
    echo "✅ Monitoring Hadoop configuré"
else
    echo "⚠️  Hadoop non disponible"
fi
