#!/bin/bash
# ============================================================================
# Script d'Installation X2Go - Cluster HPC
# Remote Graphics Open-Source (Alternative à Exceed TurboX)
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
X2GO_PORT="${X2GO_PORT:-22}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION X2GO${NC}"
echo -e "${GREEN}Remote Graphics Open-Source${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION X2GO SERVER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation X2Go Server...${NC}"

# Ajouter repository X2Go
zypper addrepo https://download.opensuse.org/repositories/X11:/RemoteDesktop/openSUSE_Leap_15.4/X11:RemoteDesktop.repo || true
zypper refresh

# Installation
zypper install -y \
    x2goserver \
    x2goserver-xsession \
    xfce4-session \
    xfce4-terminal \
    xfce4-panel || {
    echo -e "${RED}Erreur: Installation X2Go échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ X2Go Server installé${NC}"

# ============================================================================
# 2. CONFIGURATION X2GO
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration X2Go...${NC}"

# Configuration X2Go
mkdir -p /etc/x2go
cat > /etc/x2go/x2goserver.conf <<EOF
# Configuration X2Go Server
X2GO_PORT=${X2GO_PORT}
X2GO_SSH_PORT=22
X2GO_ENABLE_SSH=yes
EOF

# Démarrer X2Go
systemctl enable x2goserver
systemctl start x2goserver

echo -e "${GREEN}  ✅ X2Go configuré${NC}"

# ============================================================================
# 3. CONFIGURATION DESKTOP ENVIRONMENTS
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration Desktop Environments...${NC}"

# Installer environnements de bureau légers
zypper install -y \
    xfce4 \
    xfce4-terminal \
    xfce4-panel \
    xfce4-settings || {
    echo -e "${YELLOW}  ⚠️  Installation desktop environments partielle${NC}"
}

echo -e "${GREEN}  ✅ Desktop environments configurés${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== X2GO INSTALLÉ ===${NC}"
echo "Port SSH: 22"
echo "Desktop: XFCE4"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  1. Installer client X2Go sur machine locale"
echo "  2. Connexion: ssh -X user@frontal-01"
echo "  3. Lancer applications graphiques"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
