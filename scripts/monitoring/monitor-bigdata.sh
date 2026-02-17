#!/bin/bash
# ============================================================================
# Monitoring Big Data - Spark, Hadoop
# ============================================================================

set -euo pipefail

echo "Monitoring Big Data..."

# Monitoring Spark
if command -v spark-submit &> /dev/null; then
    SPARK_JOBS=$(ps aux | grep -c spark-submit || echo "0")
    cat >> /var/lib/prometheus/node-exporter/bigdata.prom <<EOF
# TYPE spark_jobs_running gauge
spark_jobs_running $SPARK_JOBS
EOF
fi

# Monitoring Hadoop
if [ -d /opt/hadoop ]; then
    HADOOP_NODES=$(/opt/hadoop/bin/hdfs dfsadmin -report 2>/dev/null | grep -c "Live datanodes" || echo "0")
    cat >> /var/lib/prometheus/node-exporter/bigdata.prom <<EOF
# TYPE hadoop_datanodes_live gauge
hadoop_datanodes_live $HADOOP_NODES
EOF
fi

echo "✅ Monitoring Big Data configuré"
