#!/bin/bash
# ============================================================================
# Installation Toutes les Applications Scientifiques
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION APPLICATIONS SCIENTIFIQUES${NC}"
echo -e "${BLUE}========================================${NC}"

# Liste des applications
APPS=(
    "install-rstudio.sh"
    "install-julia.sh"
    "install-octave.sh"
    "install-scilab.sh"
    "install-maxima.sh"
    "install-r.sh"
    "install-python-packages.sh"
    "install-lammps.sh"
    "install-namd.sh"
    "install-cp2k.sh"
    "install-abinit.sh"
    "install-wrf.sh"
    "install-visit.sh"
    "install-vmd.sh"
    "install-amber.sh"
)

# Installation
for app in "${APPS[@]}"; do
    if [ -f "scripts/applications/$app" ]; then
        echo -e "\n${YELLOW}Installation: $app${NC}"
        bash "scripts/applications/$app" && {
            echo -e "${GREEN}  ✅ Installé${NC}"
        } || {
            echo -e "${YELLOW}  ⚠️  Installation partielle${NC}"
        }
    fi
done

echo -e "\n${BLUE}=== INSTALLATION TERMINÉE ===${NC}"
