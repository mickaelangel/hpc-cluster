#!/bin/bash
# ============================================================================
# Script d'Installation NoMachine - Cluster HPC
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
NOMACHINE_VERSION="${NOMACHINE_VERSION:-8.11}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NOMACHINE${NC}"
echo -e "${GREEN}Version: $NOMACHINE_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. TÉLÉCHARGEMENT NOMACHINE
# ============================================================================
echo -e "\n${YELLOW}[1/3] Téléchargement NoMachine...${NC}"

cd /tmp
if [ ! -f nomachine_${NOMACHINE_VERSION}_x86_64.tar.gz ]; then
    wget https://download.nomachine.com/download/${NOMACHINE_VERSION}/Linux/nomachine_${NOMACHINE_VERSION}_x86_64.tar.gz || {
        echo -e "${RED}Erreur: Téléchargement NoMachine échoué${NC}"
        exit 1
    }
fi

echo -e "${GREEN}  ✅ NoMachine téléchargé${NC}"

# ============================================================================
# 2. INSTALLATION NOMACHINE
# ============================================================================
echo -e "\n${YELLOW}[2/3] Installation NoMachine...${NC}"

# Extraire et installer
tar xzf nomachine_${NOMACHINE_VERSION}_x86_64.tar.gz
cd NoMachine

# Installation
./nxserver --install || {
    echo -e "${RED}Erreur: Installation NoMachine échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ NoMachine installé${NC}"

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration NoMachine...${NC}"

# Configuration de base
cat > /usr/NX/etc/server.cfg <<EOF
# Configuration NoMachine Server
EnableNXAuth 1
EnablePasswordAuth 1
EnableSSH 1
SSHPort 22
NXPort 4000
EOF

# Démarrer NoMachine
systemctl enable nxserver
systemctl start nxserver

echo -e "${GREEN}  ✅ NoMachine configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== NOMACHINE INSTALLÉ ===${NC}"
echo "Version: $NOMACHINE_VERSION"
echo "Port: 4000"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  1. Installer client NoMachine sur machine locale"
echo "  2. Connexion: frontal-01:4000"
echo "  3. Lancer applications graphiques"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
