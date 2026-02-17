#!/bin/bash
# ============================================================================
# Script d'Installation Apptainer - Cluster HPC
# Conteneurs sécurisés pour Slurm
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
APPTAINER_VERSION="${APPTAINER_VERSION:-1.3.0}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION APPTAINER${NC}"
echo -e "${GREEN}Version: $APPTAINER_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc \
    make \
    libarchive-devel \
    libseccomp-devel \
    squashfs \
    cryptsetup \
    wget \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

# ============================================================================
# 2. INSTALLATION GO (si nécessaire)
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation Go...${NC}"

if ! command -v go > /dev/null 2>&1; then
    # Installation Go depuis binaire
    cd /tmp
    wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
    echo -e "${GREEN}  ✅ Go installé${NC}"
else
    echo -e "${GREEN}  ✅ Go déjà installé${NC}"
fi

# ============================================================================
# 3. COMPILATION APPTAINER
# ============================================================================
echo -e "\n${YELLOW}[3/4] Compilation Apptainer...${NC}"

cd /tmp
git clone https://github.com/apptainer/apptainer.git || {
    echo -e "${RED}Erreur: Clone Apptainer échoué${NC}"
    exit 1
}

cd apptainer
git checkout v${APPTAINER_VERSION}

./mconfig --prefix=/usr/local
cd builddir
make
make install

echo -e "${GREEN}  ✅ Apptainer compilé et installé${NC}"

# ============================================================================
# 4. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration...${NC}"

# Configuration Apptainer
mkdir -p /etc/apptainer
cat > /etc/apptainer/apptainer.conf <<'EOF'
# Configuration Apptainer
allow setuid = yes
max loop devices = 256
user bind control = yes
enable fusemount = yes
enable overlay = try
enable underlay = yes
EOF

# Vérification
if apptainer --version > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Apptainer fonctionnel${NC}"
    apptainer --version
else
    echo -e "${RED}  ❌ Apptainer non fonctionnel${NC}"
    exit 1
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== APPTAINER INSTALLÉ ===${NC}"
echo "Version: $APPTAINER_VERSION"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  # Construire une image"
echo "  apptainer build image.sif image.def"
echo ""
echo "  # Exécuter dans Slurm"
echo "  srun apptainer exec image.sif command"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
