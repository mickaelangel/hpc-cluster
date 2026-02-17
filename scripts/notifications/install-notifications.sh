#!/bin/bash
# ============================================================================
# Installation Système de Notifications - Email, Slack
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NOTIFICATIONS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION POSTFIX (EMAIL)
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Postfix...${NC}"

zypper install -y postfix mailx || {
    echo -e "${RED}Erreur: Installation Postfix échouée${NC}"
    exit 1
}

# Configuration Postfix basique
cat > /etc/postfix/main.cf <<EOF
# Configuration Postfix pour Cluster HPC
myhostname = cluster.local
mydomain = cluster.local
myorigin = \$mydomain
inet_interfaces = localhost
mydestination = \$myhostname, localhost.\$mydomain, localhost
relayhost =
EOF

systemctl enable postfix
systemctl start postfix

echo -e "${GREEN}  ✅ Postfix installé${NC}"

# ============================================================================
# 2. INSTALLATION SLACK NOTIFIER
# ============================================================================
echo -e "\n${YELLOW}[2/3] Installation Slack notifier...${NC}"

# Script envoi Slack
cat > /usr/local/bin/slack-notify.sh <<'EOF'
#!/bin/bash
# Envoi notification Slack

WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
CHANNEL="${SLACK_CHANNEL:-#hpc-cluster}"
MESSAGE="$1"
SEVERITY="${2:-info}"

if [ -z "$WEBHOOK_URL" ]; then
    echo "SLACK_WEBHOOK_URL non configuré"
    exit 1
fi

# Couleur selon sévérité
case "$SEVERITY" in
    critical) COLOR="danger" ;;
    warning) COLOR="warning" ;;
    *) COLOR="good" ;;
esac

# Envoyer à Slack
curl -X POST -H 'Content-type: application/json' \
    --data "{\"channel\":\"$CHANNEL\",\"attachments\":[{\"color\":\"$COLOR\",\"text\":\"$MESSAGE\"}]}" \
    "$WEBHOOK_URL" &> /dev/null
EOF

chmod +x /usr/local/bin/slack-notify.sh

echo -e "${GREEN}  ✅ Slack notifier installé${NC}"

# ============================================================================
# 3. CONFIGURATION ALERTMANAGER
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration Alertmanager...${NC}"

# Créer configuration Alertmanager
mkdir -p /etc/alertmanager
cat > /etc/alertmanager/alertmanager.yml <<EOF
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical'
    - match:
        severity: warning
      receiver: 'warning'

receivers:
  - name: 'default'
    email_configs:
      - to: 'admin@cluster.local'
        from: 'alertmanager@cluster.local'
        smarthost: 'localhost:25'
  
  - name: 'critical'
    email_configs:
      - to: 'admin@cluster.local'
        from: 'alertmanager@cluster.local'
        smarthost: 'localhost:25'
    webhook_configs:
      - url: 'http://localhost:8080/slack'
        send_resolved: true
  
  - name: 'warning'
    email_configs:
      - to: 'admin@cluster.local'
        from: 'alertmanager@cluster.local'
        smarthost: 'localhost:25'
EOF

echo -e "${GREEN}  ✅ Alertmanager configuré${NC}"

echo -e "\n${GREEN}=== NOTIFICATIONS INSTALLÉES ===${NC}"
echo "Email: Postfix configuré"
echo "Slack: /usr/local/bin/slack-notify.sh"
echo "Alertmanager: /etc/alertmanager/alertmanager.yml"
