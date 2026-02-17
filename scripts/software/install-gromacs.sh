#!/bin/bash
# ============================================================================
# Script d'Installation GROMACS - Cluster HPC
# Simulation Moléculaire - Open Source
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
GROMACS_VERSION="${GROMACS_VERSION:-2023.2}"
INSTALL_DIR="${INSTALL_DIR:-/opt/gromacs}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GROMACS${NC}"
echo -e "${GREEN}Version: $GROMACS_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ cmake make \
    fftw3-devel fftw3-threads-devel \
    openmpi4-devel \
    libxml2-devel \
    hwloc-devel \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT GROMACS
# ============================================================================
echo -e "\n${YELLOW}[2/4] Téléchargement GROMACS...${NC}"

cd /tmp
if [ ! -f gromacs-${GROMACS_VERSION}.tar.gz ]; then
    wget https://ftp.gromacs.org/gromacs/gromacs-${GROMACS_VERSION}.tar.gz || {
        echo -e "${RED}Erreur: Téléchargement GROMACS échoué${NC}"
        exit 1
    }
fi

tar xzf gromacs-${GROMACS_VERSION}.tar.gz
cd gromacs-${GROMACS_VERSION}

echo -e "${GREEN}  ✅ GROMACS téléchargé${NC}"

# ============================================================================
# 3. COMPILATION GROMACS
# ============================================================================
echo -e "\n${YELLOW}[3/4] Compilation GROMACS...${NC}"

mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
    -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_MPI=ON \
    -DGMX_GPU=OFF \
    -DGMX_BUILD_MANUAL=OFF \
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

echo -e "${GREEN}  ✅ GROMACS compilé et installé${NC}"

# ============================================================================
# 4. CONFIGURATION MODULE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration module...${NC}"

mkdir -p /usr/share/modulefiles/gromacs
cat > /usr/share/modulefiles/gromacs/${GROMACS_VERSION} <<EOF
#%Module1.0
##
## GROMACS ${GROMACS_VERSION} Module
##
proc ModulesHelp { } {
    puts stderr "GROMACS ${GROMACS_VERSION} - Simulation Moléculaire"
}
module-whatis "GROMACS ${GROMACS_VERSION}"

set GROMACS_ROOT ${INSTALL_DIR}
prepend-path PATH \$GROMACS_ROOT/bin
prepend-path LD_LIBRARY_PATH \$GROMACS_ROOT/lib64
prepend-path MANPATH \$GROMACS_ROOT/share/man
EOF

echo -e "${GREEN}  ✅ Module configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== GROMACS INSTALLÉ ===${NC}"
echo "Version: $GROMACS_VERSION"
echo "Installation: $INSTALL_DIR"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  module load gromacs/${GROMACS_VERSION}"
echo "  gmx --version"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
