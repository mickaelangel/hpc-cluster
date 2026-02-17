#!/bin/bash
# ============================================================================
# Installation Certbot - Certificats SSL/TLS Automatiques
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CERTBOT${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Certbot...${NC}"

zypper install -y certbot python3-certbot-nginx python3-certbot-apache || {
    echo -e "${RED}Erreur: Installation Certbot échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Certbot installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Certbot...${NC}"

# Créer répertoires
mkdir -p /etc/letsencrypt/renewal-hooks/deploy
mkdir -p /etc/letsencrypt/renewal-hooks/pre
mkdir -p /etc/letsencrypt/renewal-hooks/post

# Script de renouvellement automatique
cat > /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh <<'EOF'
#!/bin/bash
# Recharger services après renouvellement certificat

systemctl reload nginx || true
systemctl reload apache2 || true
systemctl reload haproxy || true
EOF

chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh

# Configuration Certbot
cat > /etc/letsencrypt/cli.ini <<EOF
# Configuration Certbot
email = admin@cluster.local
agree-tos = true
non-interactive = true
rsa-key-size = 4096
EOF

echo -e "${GREEN}  ✅ Certbot configuré${NC}"

# ============================================================================
# 3. RENOUVELLEMENT AUTOMATIQUE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration renouvellement automatique...${NC}"

# Timer systemd pour renouvellement
cat > /etc/systemd/system/certbot-renew.timer <<EOF
[Unit]
Description=Renew Let's Encrypt certificates
After=network-online.target

[Timer]
OnCalendar=daily
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat > /etc/systemd/system/certbot-renew.service <<EOF
[Unit]
Description=Renew Let's Encrypt certificates
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet --deploy-hook /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh
EOF

systemctl daemon-reload
systemctl enable certbot-renew.timer
systemctl start certbot-renew.timer

echo -e "${GREEN}  ✅ Renouvellement automatique configuré${NC}"

echo -e "\n${GREEN}=== CERTBOT INSTALLÉ ===${NC}"
echo "Obtenir certificat: certbot certonly --standalone -d example.com"
echo "Renouvellement: certbot renew"
echo "Timer: systemctl status certbot-renew.timer"
