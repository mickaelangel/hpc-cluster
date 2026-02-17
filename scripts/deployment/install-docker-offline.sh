#!/bin/bash
# ============================================================================
# Installe Docker à partir de RPM locaux (sans Internet)
# SUSE 15 SP4 / openSUSE Leap 15.4
# Usage: sudo bash scripts/deployment/install-docker-offline.sh
#        ou depuis l'export: sudo ./install-docker-offline.sh
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Dossier des RPM : (pwd)/docker-offline-rpms ou (répertoire du script)/docker-offline-rpms
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_CURRENT_RPMS="$(pwd)/docker-offline-rpms"
DIR_SCRIPT_RPMS="$SCRIPT_DIR/docker-offline-rpms"
# Si le script est dans scripts/deployment/, le dossier RPM est à la racine du projet (2 niveaux au-dessus)
DIR_PROJECT_RPMS="$(cd "$SCRIPT_DIR/../.." && pwd)/docker-offline-rpms"

if [ -d "$DIR_CURRENT_RPMS" ] && [ -n "$(ls -A "$DIR_CURRENT_RPMS"/*.rpm 2>/dev/null)" ]; then
    RPM_DIR="$DIR_CURRENT_RPMS"
elif [ -d "$DIR_SCRIPT_RPMS" ] && [ -n "$(ls -A "$DIR_SCRIPT_RPMS"/*.rpm 2>/dev/null)" ]; then
    RPM_DIR="$DIR_SCRIPT_RPMS"
elif [ -d "$DIR_PROJECT_RPMS" ] && [ -n "$(ls -A "$DIR_PROJECT_RPMS"/*.rpm 2>/dev/null)" ]; then
    RPM_DIR="$DIR_PROJECT_RPMS"
else
    echo -e "${RED}❌ Aucun dossier docker-offline-rpms/ contenant des .rpm trouvé.${NC}"
    echo "   Placez les RPM Docker (téléchargés avec download-docker-rpms-suse15sp4.sh) dans:"
    echo "   - ./docker-offline-rpms/ (à la racine du projet ou de l'export)"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION DOCKER HORS LIGNE${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Source RPM: $RPM_DIR"
echo ""

if command -v docker &>/dev/null; then
    echo -e "${GREEN}Docker est déjà installé: $(docker --version)${NC}"
    systemctl enable docker 2>/dev/null || true
    systemctl start docker 2>/dev/null || true
    exit 0
fi

echo -e "${YELLOW}[1/2] Installation des RPM...${NC}"
# zypper install avec --no-refresh pour ne pas contacter les dépôts
zypper install -y --no-refresh "$RPM_DIR"/*.rpm 2>/dev/null || {
    echo -e "${YELLOW}  zypper impossible, tentative rpm -Uvh...${NC}"
    rpm -Uvh --nodeps "$RPM_DIR"/*.rpm 2>/dev/null || rpm -Uvh "$RPM_DIR"/*.rpm
}

echo -e "${YELLOW}[2/2] Démarrage du service Docker...${NC}"
systemctl enable docker
systemctl start docker

if command -v docker &>/dev/null; then
    echo -e "${GREEN}  ✅ Docker installé: $(docker --version)${NC}"
    docker run --rm hello-world 2>/dev/null && echo -e "${GREEN}  ✅ Test Docker OK${NC}" || true
else
    echo -e "${RED}  ❌ Docker non trouvé après installation. Vérifiez les RPM (dépendances).${NC}"
    exit 1
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Docker est prêt pour l'installation du cluster.${NC}"
echo -e "${GREEN}========================================${NC}"
