#!/bin/bash
# ============================================================================
# Script d'Installation OpenFOAM - Cluster HPC
# Computational Fluid Dynamics (CFD) - Open Source
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
OPENFOAM_VERSION="${OPENFOAM_VERSION:-2312}"
INSTALL_DIR="${INSTALL_DIR:-/opt/openfoam}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION OPENFOAM${NC}"
echo -e "${GREEN}Version: $OPENFOAM_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ cmake make \
    openmpi4-devel \
    flex bison \
    zlib-devel \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT OPENFOAM
# ============================================================================
echo -e "\n${YELLOW}[2/4] Téléchargement OpenFOAM...${NC}"

cd /tmp
if [ ! -d OpenFOAM-${OPENFOAM_VERSION} ]; then
    git clone https://github.com/OpenFOAM/OpenFOAM-${OPENFOAM_VERSION}.git || {
        echo -e "${RED}Erreur: Clone OpenFOAM échoué${NC}"
        exit 1
    }
fi

cd OpenFOAM-${OPENFOAM_VERSION}

echo -e "${GREEN}  ✅ OpenFOAM téléchargé${NC}"

# ============================================================================
# 3. INSTALLATION OPENFOAM
# ============================================================================
echo -e "\n${YELLOW}[3/4] Installation OpenFOAM...${NC}"

# Créer répertoire d'installation
mkdir -p ${INSTALL_DIR}
cp -r * ${INSTALL_DIR}/

cd ${INSTALL_DIR}

# Source OpenFOAM environment
source etc/bashrc || {
    echo -e "${RED}Erreur: Configuration OpenFOAM échouée${NC}"
    exit 1
}

# Compiler OpenFOAM
./Allwmake -j$(nproc) || {
    echo -e "${RED}Erreur: Compilation OpenFOAM échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ OpenFOAM compilé et installé${NC}"

# ============================================================================
# 4. CONFIGURATION MODULE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration module...${NC}"

mkdir -p /usr/share/modulefiles/openfoam
cat > /usr/share/modulefiles/openfoam/${OPENFOAM_VERSION} <<EOF
#%Module1.0
##
## OpenFOAM ${OPENFOAM_VERSION} Module
##
proc ModulesHelp { } {
    puts stderr "OpenFOAM ${OPENFOAM_VERSION} - Computational Fluid Dynamics"
}
module-whatis "OpenFOAM ${OPENFOAM_VERSION}"

set OPENFOAM_ROOT ${INSTALL_DIR}
setenv FOAM_INST_DIR ${INSTALL_DIR}
prepend-path PATH \${OPENFOAM_ROOT}/bin
prepend-path LD_LIBRARY_PATH \${OPENFOAM_ROOT}/lib
setenv WM_PROJECT_VERSION ${OPENFOAM_VERSION}
EOF

echo -e "${GREEN}  ✅ Module configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== OPENFOAM INSTALLÉ ===${NC}"
echo "Version: $OPENFOAM_VERSION"
echo "Installation: $INSTALL_DIR"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  module load openfoam/${OPENFOAM_VERSION}"
echo "  source \${FOAM_INST_DIR}/etc/bashrc"
echo "  simpleFoam --help"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
