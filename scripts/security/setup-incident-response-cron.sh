#!/bin/bash
# ============================================================================
# Configuration Incident Response Automatisé (Monitoring)
# Surveillance continue et alertes
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION INCIDENT RESPONSE${NC}"
echo -e "${BLUE}========================================${NC}"

# Créer script de monitoring incidents
cat > /usr/local/bin/monitor-incidents.sh <<'EOF'
#!/bin/bash
# Monitoring incidents de sécurité
LOG_FILE="/var/log/incidents/monitoring.log"
ALERT_EMAIL="admin@cluster.local"

# Vérifier tentatives de connexion échouées
FAILED_LOGINS=$(grep -i "failed\|denied" /var/log/auth.log 2>/dev/null | wc -l)
if [ "$FAILED_LOGINS" -gt 100 ]; then
    echo "$(date): ALERTE - $FAILED_LOGINS tentatives de connexion échouées" >> "$LOG_FILE"
    # Envoyer alerte (si mail configuré)
    # echo "Alerte sécurité" | mail -s "Tentatives de connexion échouées" "$ALERT_EMAIL"
fi

# Vérifier IPs bannies par Fail2ban
if command -v fail2ban-client &> /dev/null; then
    BANNED_IPS=$(fail2ban-client status sshd 2>/dev/null | grep "Banned IP" | wc -l)
    if [ "$BANNED_IPS" -gt 10 ]; then
        echo "$(date): ALERTE - $BANNED_IPS IPs bannies" >> "$LOG_FILE"
    fi
fi

# Vérifier alertes IDS
if [ -f /var/log/suricata/fast.log ]; then
    ALERTS=$(tail -100 /var/log/suricata/fast.log | grep -i "alert" | wc -l)
    if [ "$ALERTS" -gt 50 ]; then
        echo "$(date): ALERTE - $ALERTS alertes Suricata" >> "$LOG_FILE"
    fi
fi
EOF

chmod +x /usr/local/bin/monitor-incidents.sh

# Ajouter au cron (toutes les heures)
(crontab -l 2>/dev/null; echo "0 * * * * /usr/local/bin/monitor-incidents.sh") | crontab -

echo -e "${GREEN}✅ Monitoring incidents configuré${NC}"
echo -e "${YELLOW}Exécution toutes les heures${NC}"
echo -e "${YELLOW}Logs: /var/log/incidents/monitoring.log${NC}"
