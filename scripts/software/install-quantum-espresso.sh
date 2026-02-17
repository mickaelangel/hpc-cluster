#!/bin/bash
# ============================================================================
# Script d'Installation Quantum ESPRESSO - Cluster HPC
# Calculs Quantiques - Open Source
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
QE_VERSION="${QE_VERSION:-7.2}"
INSTALL_DIR="${INSTALL_DIR:-/opt/quantum-espresso}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION QUANTUM ESPRESSO${NC}"
echo -e "${GREEN}Version: $QE_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ gcc-fortran \
    openmpi4-devel \
    fftw3-devel fftw3-threads-devel \
    lapack-devel blas-devel \
    scalapack-openmpi4-devel \
    hdf5-openmpi4-devel \
    libxc-devel \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT QUANTUM ESPRESSO
# ============================================================================
echo -e "\n${YELLOW}[2/4] Téléchargement Quantum ESPRESSO...${NC}"

cd /tmp
if [ ! -d qe-${QE_VERSION}-release ]; then
    git clone https://github.com/QEF/q-e.git qe-${QE_VERSION}-release || {
        echo -e "${RED}Erreur: Clone Quantum ESPRESSO échoué${NC}"
        exit 1
    }
    cd qe-${QE_VERSION}-release
    git checkout qe-${QE_VERSION}-release || {
        echo -e "${YELLOW}  ⚠️  Tag non trouvé, utilisation de master${NC}"
    }
else
    cd qe-${QE_VERSION}-release
fi

echo -e "${GREEN}  ✅ Quantum ESPRESSO téléchargé${NC}"

# ============================================================================
# 3. COMPILATION QUANTUM ESPRESSO
# ============================================================================
echo -e "\n${YELLOW}[3/4] Compilation Quantum ESPRESSO...${NC}"

# Configuration
./configure \
    --prefix=${INSTALL_DIR} \
    --with-scalapack=yes \
    --enable-parallel=yes \
    MPIF90=mpif90 \
    F90=mpif90 || {
    echo -e "${RED}Erreur: Configuration échouée${NC}"
    exit 1
}

# Compilation
make all -j$(nproc) || {
    echo -e "${RED}Erreur: Compilation échouée${NC}"
    exit 1
}

# Installation
make install || {
    echo -e "${RED}Erreur: Installation échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Quantum ESPRESSO compilé et installé${NC}"

# ============================================================================
# 4. CONFIGURATION MODULE
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration module...${NC}"

mkdir -p /usr/share/modulefiles/quantum-espresso
cat > /usr/share/modulefiles/quantum-espresso/${QE_VERSION} <<EOF
#%Module1.0
##
## Quantum ESPRESSO ${QE_VERSION} Module
##
proc ModulesHelp { } {
    puts stderr "Quantum ESPRESSO ${QE_VERSION} - Calculs Quantiques"
}
module-whatis "Quantum ESPRESSO ${QE_VERSION}"

set QE_ROOT ${INSTALL_DIR}
prepend-path PATH \$QE_ROOT/bin
prepend-path LD_LIBRARY_PATH \$QE_ROOT/lib
EOF

echo -e "${GREEN}  ✅ Module configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== QUANTUM ESPRESSO INSTALLÉ ===${NC}"
echo "Version: $QE_VERSION"
echo "Installation: $INSTALL_DIR"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  module load quantum-espresso/${QE_VERSION}"
echo "  pw.x --help"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
