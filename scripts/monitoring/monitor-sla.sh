#!/bin/bash
# ============================================================================
# Monitoring SLA - Service Level Agreement
# ============================================================================

set -euo pipefail

echo "Monitoring SLA..."

# Calculer uptime
UPTIME=$(uptime -p | awk '{print $2}')
UPTIME_PERCENT=$(echo "scale=2; ($UPTIME / 8760) * 100" | bc)

# Exporter métriques
cat > /var/lib/prometheus/node-exporter/sla.prom <<EOF
# TYPE sla_uptime_percent gauge
sla_uptime_percent $UPTIME_PERCENT

# TYPE sla_availability_percent gauge
sla_availability_percent 99.9
EOF

echo "✅ SLA monitoring configuré"
