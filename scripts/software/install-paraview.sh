#!/bin/bash
# ============================================================================
# Script d'Installation ParaView - Cluster HPC
# Visualisation Scientifique - Open Source
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PARAVIEW_VERSION="${PARAVIEW_VERSION:-5.11.2}"
INSTALL_DIR="${INSTALL_DIR:-/opt/paraview}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PARAVIEW${NC}"
echo -e "${GREEN}Version: $PARAVIEW_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ cmake make \
    openmpi4-devel \
    qt5-devel \
    python3-devel \
    mesa-libGL-devel \
    libXt-devel \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT PARAVIEW
# ============================================================================
echo -e "\n${YELLOW}[2/4] Téléchargement ParaView...${NC}"

cd /tmp
if [ ! -f ParaView-v${PARAVIEW_VERSION}.tar.gz ]; then
    wget https://www.paraview.org/files/v${PARAVIEW_VERSION}/ParaView-v${PARAVIEW_VERSION}.tar.gz || {
        echo -e "${RED}Erreur: Téléchargement ParaView échoué${NC}"
        exit 1
    }
fi

tar xzf ParaView-v${PARAVIEW_VERSION}.tar.gz
cd ParaView-v${PARAVIEW_VERSION}

echo -e "${GREEN}  ✅ ParaView téléchargé${NC}"

# ============================================================================
# 3. COMPILATION PARAVIEW
# ============================================================================
echo -e "\n${YELLOW}[3/4] Compilation ParaView...${NC}"

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DPARAVIEW_USE_MPI=ON \
    -DPARAVIEW_USE_PYTHON=ON \
    -DPARAVIEW_BUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release || {
    echo -e "${RED}Erreur: Configuration CMake échouée${NC}"
    exit 1
}

make -j$(nproc) || {
    echo -e "${RED}Erreur: Compilation échouée${NC}"
    exit 1
}

make install || {
    echo -e "${RED}Erreur: Installation échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ ParaView compilé et installé${NC}"

# ============================================================================
# 4. CONFIGURATION MODULE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration module...${NC}"

mkdir -p /usr/share/modulefiles/paraview
cat > /usr/share/modulefiles/paraview/${PARAVIEW_VERSION} <<EOF
#%Module1.0
##
## ParaView ${PARAVIEW_VERSION} Module
##
proc ModulesHelp { } {
    puts stderr "ParaView ${PARAVIEW_VERSION} - Visualisation Scientifique"
}
module-whatis "ParaView ${PARAVIEW_VERSION}"

set PARAVIEW_ROOT ${INSTALL_DIR}
prepend-path PATH \$PARAVIEW_ROOT/bin
prepend-path LD_LIBRARY_PATH \$PARAVIEW_ROOT/lib
prepend-path PYTHONPATH \$PARAVIEW_ROOT/lib/python3.11/site-packages
EOF

echo -e "${GREEN}  ✅ Module configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== PARAVIEW INSTALLÉ ===${NC}"
echo "Version: $PARAVIEW_VERSION"
echo "Installation: $INSTALL_DIR"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  module load paraview/${PARAVIEW_VERSION}"
echo "  paraview --version"
echo "  # Pour visualisation à distance"
echo "  pvserver --help"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
