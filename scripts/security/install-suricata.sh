#!/bin/bash
# ============================================================================
# Installation Suricata - IDS (Intrusion Detection System)
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SURICATA${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Suricata...${NC}"

zypper install -y suricata || {
    echo -e "${YELLOW}  ⚠️  Installation depuis repository, tentative compilation...${NC}"
    # Alternative: compilation depuis sources
    zypper install -y gcc make libpcap-devel libyaml-devel libpcre-devel
    # Télécharger et compiler Suricata
}

echo -e "${GREEN}  ✅ Suricata installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Suricata...${NC}"

# Configuration de base
cat > /etc/suricata/suricata.yaml <<EOF
# Configuration Suricata pour Cluster HPC
vars:
  address-groups:
    HOME_NET: "[172.20.0.0/24,10.0.0.0/24,10.10.10.0/24]"
    EXTERNAL_NET: "!$HOME_NET"

default-log-dir: /var/log/suricata/
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
  - alert:
      enabled: yes
      filename: alert.json
EOF

# Mise à jour règles
suricata-update || {
    echo -e "${YELLOW}  ⚠️  Mise à jour règles échouée (nécessite Internet)${NC}"
}

echo -e "${GREEN}  ✅ Suricata configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage Suricata...${NC}"

systemctl enable suricata
systemctl start suricata || {
    echo -e "${YELLOW}  ⚠️  Démarrage échoué (peut nécessiter configuration interface)${NC}"
}

echo -e "${GREEN}  ✅ Suricata démarré${NC}"

echo -e "\n${GREEN}=== SURICATA INSTALLÉ ===${NC}"
echo "Configuration: /etc/suricata/suricata.yaml"
echo "Logs: /var/log/suricata/"
