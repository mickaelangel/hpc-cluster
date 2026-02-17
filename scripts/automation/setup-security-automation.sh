#!/bin/bash
# ============================================================================
# Configuration Automatisation Sécurité
# Timer systemd pour tâches sécurité quotidiennes
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION AUTOMATISATION SÉCURITÉ${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. CRÉER SERVICE TÂCHES QUOTIDIENNES
# ============================================================================
echo -e "\n${YELLOW}[1/3] Création service tâches quotidiennes...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAILY_SCRIPT="$SCRIPT_DIR/security-daily-tasks.sh"

cat > /etc/systemd/system/security-daily-tasks.service <<EOF
[Unit]
Description=Security Daily Tasks
After=network.target

[Service]
Type=oneshot
ExecStart=$DAILY_SCRIPT
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# ============================================================================
# 2. CRÉER TIMER QUOTIDIEN
# ============================================================================
echo -e "\n${YELLOW}[2/3] Création timer quotidien...${NC}"

cat > /etc/systemd/system/security-daily-tasks.timer <<EOF
[Unit]
Description=Security Daily Tasks Timer
Requires=security-daily-tasks.service

[Timer]
OnCalendar=daily
OnBootSec=5min
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

# ============================================================================
# 3. ACTIVER TIMER
# ============================================================================
echo -e "\n${YELLOW}[3/3] Activation timer...${NC}"

systemctl daemon-reload
systemctl enable security-daily-tasks.timer
systemctl start security-daily-tasks.timer

echo -e "${GREEN}  ✅ Timer activé${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== AUTOMATISATION CONFIGURÉE ===${NC}"
echo "Timer: systemctl status security-daily-tasks.timer"
echo "Prochaine exécution: systemctl list-timers security-daily-tasks.timer"
