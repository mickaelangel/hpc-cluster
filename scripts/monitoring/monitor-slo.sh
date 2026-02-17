#!/bin/bash
# ============================================================================
# Monitoring SLO - Service Level Objective
# ============================================================================

set -euo pipefail

echo "Monitoring SLO..."

# Calculer latence moyenne
LATENCY=$(ping -c 10 compute-01 | grep "avg" | awk -F'/' '{print $5}')

# Calculer erreur rate
ERROR_RATE=$(grep -c "ERROR" /var/log/slurm/slurmctld.log 2>/dev/null || echo "0")

# Exporter métriques
cat > /var/lib/prometheus/node-exporter/slo.prom <<EOF
# TYPE slo_latency_seconds gauge
slo_latency_seconds $LATENCY

# TYPE slo_error_rate gauge
slo_error_rate $ERROR_RATE
EOF

echo "✅ SLO monitoring configuré"
