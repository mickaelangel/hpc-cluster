#!/bin/bash
# ============================================================================
# Télécharge les RPM Docker + dépendances pour SUSE 15 SP4 / openSUSE Leap 15.4
# À exécuter sur une machine AVEC INTERNET (même SUSE 15 SP4 ou Leap 15.4)
# Produit le dossier docker-offline-rpms/ à copier sur la clé USB
# Usage: sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-$PROJECT_ROOT/docker-offline-rpms}"
OUTPUT_DIR="$(cd "$(dirname "$OUTPUT_DIR")" && pwd)/$(basename "$OUTPUT_DIR")"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}TÉLÉCHARGEMENT RPM DOCKER - SUSE 15 SP4${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Dossier de sortie: $OUTPUT_DIR"
echo ""

if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ /etc/os-release non trouvé${NC}"
    exit 1
fi

source /etc/os-release
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# Repos Docker pour openSUSE Leap 15.4 / SUSE
echo -e "${YELLOW}[1/3] Configuration des dépôts...${NC}"
if [[ "$ID" == "opensuse-leap" ]] || [[ "$ID" == "sles" ]]; then
    if [[ "$VERSION_ID" =~ ^15\. ]]; then
        zypper addrepo -f "https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_${VERSION_ID}/Virtualization:containers.repo" 2>/dev/null || true
    fi
    zypper refresh 2>/dev/null || true
else
    echo -e "${YELLOW}  OS non SUSE/Leap. Pour RPM compatibles, exécutez sur SUSE 15 SP4 ou Leap 15.4.${NC}"
fi

# Télécharger Docker + dépendances (sans installer)
echo -e "\n${YELLOW}[2/3] Téléchargement des paquets Docker et dépendances...${NC}"
PACKAGES="docker"
zypper search -t package docker-compose 2>/dev/null | grep -q docker-compose && PACKAGES="$PACKAGES docker-compose" || true
zypper search -t package docker-compose-plugin 2>/dev/null | grep -q docker-compose-plugin && PACKAGES="$PACKAGES docker-compose-plugin" || true

zypper --no-refresh download -d . $PACKAGES 2>/dev/null || {
    echo -e "${YELLOW}  Tentative avec refresh...${NC}"
    zypper refresh
    zypper download -d . $PACKAGES
}

echo -e "${GREEN}  ✅ RPM téléchargés dans $OUTPUT_DIR${NC}"
echo ""

# Résumé
echo -e "${YELLOW}[3/3] Résumé${NC}"
RPM_COUNT=$(find "$OUTPUT_DIR" -maxdepth 1 -name '*.rpm' 2>/dev/null | wc -l)
echo "  Fichiers RPM: $RPM_COUNT"
ls -la "$OUTPUT_DIR"/*.rpm 2>/dev/null | head -20
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Copiez le dossier entier sur la clé USB:${NC}"
echo -e "  ${BLUE}$OUTPUT_DIR${NC}"
echo -e "  (ou placez-le dans l'export cluster puis refaites l'archive)${NC}"
echo -e "${GREEN}========================================${NC}"
