#!/bin/bash
# ============================================================================
# Prédiction Charge - Cluster HPC
# ============================================================================

set -euo pipefail

echo "Prédiction charge basée sur historique..."

# Analyser historique jobs
HISTORICAL_JOBS=$(sacct -S $(date -d "30 days ago" +%Y-%m-%d) -E today --format=JobID,State --parsable2 | wc -l)

# Prédire charge future (simple moyenne)
PREDICTED_LOAD=$(echo "scale=2; $HISTORICAL_JOBS / 30" | bc)

# Exporter métrique
cat > /var/lib/prometheus/node-exporter/predicted-load.prom <<EOF
# TYPE predicted_daily_jobs gauge
predicted_daily_jobs $PREDICTED_LOAD
EOF

echo "✅ Prédiction: $PREDICTED_LOAD jobs/jour"
