#!/bin/bash
# ============================================================================
# Configuration Mises à Jour Automatisées
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION MISES À JOUR AUTOMATISÉES${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer script mise à jour
cat > /usr/local/bin/auto-update-cluster.sh <<'EOF'
#!/bin/bash
# Mise à jour automatique cluster

# Mises à jour sécurité uniquement
zypper update --security -y

# Redémarrer services si nécessaire
systemctl daemon-reload
EOF

chmod +x /usr/local/bin/auto-update-cluster.sh

# Ajouter au cron (hebdomadaire)
(crontab -l 2>/dev/null; echo "0 4 * * 0 /usr/local/bin/auto-update-cluster.sh") | crontab -

echo -e "${GREEN}✅ Mises à jour automatisées configurées${NC}"
echo -e "${YELLOW}⚠️  Mises à jour sécurité uniquement${NC}"
