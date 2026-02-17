#!/bin/bash
# ============================================================================
# Script d'Installation Automatisée - TrinityX + Warewulf
# Compatible SUSE 15 SP7 / openSUSE Leap 15.4
# ============================================================================

set -euo pipefail

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SUSE_VERSION=${1:-15.7}
INSTALL_DIR="/opt/warewulf"
TRINITYX_DIR="/opt/trinityx"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TRINITYX + WAREWULF${NC}"
echo -e "${GREEN}Version SUSE: ${SUSE_VERSION}${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION PRÉREQUIS
# ============================================================================
echo -e "\n${YELLOW}[1/8] Vérification des prérequis...${NC}"

# Vérifier que nous sommes root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erreur: Ce script doit être exécuté en tant que root${NC}"
    exit 1
fi

# Vérifier la version de SUSE
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Erreur: Fichier /etc/os-release introuvable${NC}"
    exit 1
fi

source /etc/os-release
echo -e "${GREEN}OS détecté: ${NAME} ${VERSION}${NC}"

# ============================================================================
# 2. ACTIVATION DES MODULES SUSE
# ============================================================================
echo -e "\n${YELLOW}[2/8] Activation des modules SUSE...${NC}"

zypper refresh

# Activation PackageHub
if command -v SUSEConnect &> /dev/null; then
    SUSEConnect -p PackageHub/${SUSE_VERSION}/x86_64 || true
    SUSEConnect -p sle-module-containers/${SUSE_VERSION}/x86_64 || true
    SUSEConnect -p sle-module-hpc/${SUSE_VERSION}/x86_64 || true
fi

# ============================================================================
# 3. INSTALLATION DES DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[3/8] Installation des dépendances...${NC}"

zypper install -y \
    git make gcc gcc-c++ \
    python3 python3-pip python3-devel \
    golang go \
    docker docker-compose \
    tftp-server dhcp-server \
    nfs-kernel-server \
    openssh openssh-server \
    vim htop wget curl jq \
    systemd-devel

# ============================================================================
# 4. CONFIGURATION DOCKER
# ============================================================================
echo -e "\n${YELLOW}[4/8] Configuration Docker...${NC}"

systemctl enable --now docker

# Ajouter l'utilisateur courant au groupe docker
if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER"
    echo -e "${GREEN}Utilisateur $SUDO_USER ajouté au groupe docker${NC}"
fi

# ============================================================================
# 5. INSTALLATION WAREWULF
# ============================================================================
echo -e "\n${YELLOW}[5/8] Installation Warewulf...${NC}"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [ ! -d "warewulf" ]; then
    echo "Clonage de Warewulf..."
    git clone https://github.com/hpcng/warewulf.git
fi

cd warewulf
git pull || true

echo "Compilation de Warewulf..."
make
make install

echo "Configuration initiale..."
wwctl configure --all || true

# Vérification
if command -v wwctl &> /dev/null; then
    echo -e "${GREEN}Warewulf installé: $(wwctl version)${NC}"
else
    echo -e "${RED}Erreur: Warewulf non installé correctement${NC}"
    exit 1
fi

# ============================================================================
# 6. INSTALLATION TRINITYX
# ============================================================================
echo -e "\n${YELLOW}[6/8] Installation TrinityX...${NC}"

mkdir -p "$TRINITYX_DIR"
cd "$TRINITYX_DIR"

if [ ! -d "trinityx" ]; then
    echo "Clonage de TrinityX..."
    git clone https://github.com/TrinityX/trinityx.git
fi

cd trinityx
git pull || true

# Configuration Docker Compose
if [ ! -f "docker-compose.yml" ]; then
    if [ -f "docker-compose.yml.example" ]; then
        cp docker-compose.yml.example docker-compose.yml
        echo -e "${YELLOW}Éditez docker-compose.yml avec vos paramètres${NC}"
    fi
fi

# Démarrage TrinityX
if [ -f "docker-compose.yml" ]; then
    docker-compose up -d || true
    echo -e "${GREEN}TrinityX démarré (si docker-compose.yml configuré)${NC}"
else
    echo -e "${YELLOW}docker-compose.yml non trouvé - configuration manuelle requise${NC}"
fi

# ============================================================================
# 7. CONFIGURATION DES SERVICES
# ============================================================================
echo -e "\n${YELLOW}[7/8] Configuration des services...${NC}"

# Activation des services Warewulf
systemctl enable warewulfd || true
systemctl start warewulfd || true

# Activation TFTP
systemctl enable tftp || true
systemctl start tftp || true

# Configuration DHCP (à adapter selon votre réseau)
if [ ! -f /etc/dhcpd.conf.warewulf ]; then
    echo -e "${YELLOW}Configuration DHCP requise manuellement${NC}"
    echo "Éditez /etc/dhcpd.conf pour ajouter les options PXE"
fi

# ============================================================================
# 8. VÉRIFICATION FINALE
# ============================================================================
echo -e "\n${YELLOW}[8/8] Vérification finale...${NC}"

echo -e "\n${GREEN}=== RÉSUMÉ DE L'INSTALLATION ===${NC}"
echo "Warewulf: $(wwctl version 2>/dev/null || echo 'Non installé')"
echo "Docker: $(docker --version 2>/dev/null || echo 'Non installé')"
echo "TrinityX: $(docker-compose -f $TRINITYX_DIR/trinityx/docker-compose.yml ps 2>/dev/null | grep -q trinityx && echo 'Démarré' || echo 'Non démarré')"

echo -e "\n${GREEN}=== PROCHAINES ÉTAPES ===${NC}"
echo "1. Configurer le réseau PXE dans /etc/warewulf/warewulf.conf"
echo "2. Configurer DHCP pour PXE boot"
echo "3. Créer les images système avec: wwctl image create"
echo "4. Configurer les nœuds avec: wwctl node set"
echo "5. Accéder à TrinityX (si configuré): http://localhost:8080"

echo -e "\n${GREEN}Installation terminée!${NC}"
