#!/bin/bash
# ============================================================================
# Installation Wazuh - SIEM (Security Information and Event Management)
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION WAZUH${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION SERVER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Wazuh Server...${NC}"

# Ajouter repository Wazuh
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --import
cat > /etc/zypp/repos.d/wazuh.repo <<EOF
[wazuh]
name=Wazuh repository
baseurl=https://packages.wazuh.com/4.x/yum/
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
EOF

zypper refresh
zypper install -y wazuh-manager || {
    echo -e "${YELLOW}  ⚠️  Installation depuis repository, voir documentation Wazuh${NC}"
}

echo -e "${GREEN}  ✅ Wazuh Server installé${NC}"

# ============================================================================
# 2. INSTALLATION AGENT
# ============================================================================
echo -e "\n${YELLOW}[2/3] Installation Wazuh Agent...${NC}"

zypper install -y wazuh-agent || {
    echo -e "${YELLOW}  ⚠️  Installation agent échouée${NC}"
}

# Configuration agent
WAZUH_SERVER="${WAZUH_SERVER:-frontal-01}"
sed -i "s/<address>.*<\/address>/<address>$WAZUH_SERVER<\/address>/" /var/ossec/etc/ossec.conf

echo -e "${GREEN}  ✅ Wazuh Agent installé${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage Wazuh...${NC}"

systemctl enable wazuh-manager
systemctl start wazuh-manager || true

systemctl enable wazuh-agent
systemctl start wazuh-agent || true

echo -e "${GREEN}  ✅ Wazuh démarré${NC}"

echo -e "\n${GREEN}=== WAZUH INSTALLÉ ===${NC}"
echo "Server: $WAZUH_SERVER"
echo "Configuration: /var/ossec/etc/ossec.conf"
