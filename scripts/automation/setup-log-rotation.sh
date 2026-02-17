#!/bin/bash
# ============================================================================
# Configuration Rotation Logs Avancée
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION ROTATION LOGS${NC}"
echo -e "${GREEN}========================================${NC}"

# Configuration logrotate pour cluster
cat > /etc/logrotate.d/cluster-hpc <<EOF
/var/log/slurm/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0640 slurm slurm
}

/var/log/prometheus/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}

/var/log/grafana/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF

echo -e "${GREEN}✅ Rotation logs configurée${NC}"
