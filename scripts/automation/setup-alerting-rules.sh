#!/bin/bash
# ============================================================================
# Configuration Règles Alertes Avancées
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION RÈGLES ALERTES${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer règles alertes supplémentaires
cat > /etc/prometheus/alerts-custom.yml <<EOF
groups:
  - name: custom_alerts
    rules:
      - alert: HighJobFailureRate
        expr: rate(slurm_jobs_failed_total[5m]) > 0.1
        for: 5m
        annotations:
          summary: "Taux d'échec jobs élevé"
      
      - alert: StorageNearFull
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
        for: 5m
        annotations:
          summary: "Espace disque faible"
EOF

echo -e "${GREEN}✅ Règles alertes configurées${NC}"
