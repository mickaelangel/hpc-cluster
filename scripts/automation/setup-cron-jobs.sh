#!/bin/bash
# ============================================================================
# Configuration Tâches Cron Automatisées
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION TÂCHES CRON${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer crontab pour root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

# Backup quotidien
(crontab -l 2>/dev/null; echo "0 2 * * * $SCRIPT_DIR/../backup/backup-advanced.sh") | crontab -

# Health check quotidien
(crontab -l 2>/dev/null; echo "0 6 * * * $SCRIPT_DIR/../monitoring/health-check-advanced.sh") | crontab -

# Maintenance hebdomadaire
(crontab -l 2>/dev/null; echo "0 3 * * 0 $SCRIPT_DIR/../maintenance/preventive-maintenance.sh") | crontab -

# Export métriques toutes les 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * $SCRIPT_DIR/../security/export-metrics-prometheus.sh") | crontab -

echo -e "${GREEN}✅ Tâches cron configurées${NC}"
echo "Vérifier: crontab -l"
