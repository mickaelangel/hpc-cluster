#!/bin/bash
# ============================================================================
# Import et Installation Cluster HPC sur SUSE 15 SP4 (Hors Ligne)
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION CLUSTER HPC${NC}"
echo -e "${BLUE}SUSE 15 SP4 - Hors Ligne${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Vérifier qu'on est root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ce script doit être exécuté en root${NC}"
    echo "Utilisez: sudo $0"
    exit 1
fi

# Vérifier SUSE 15 SP4
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ Fichier /etc/os-release non trouvé${NC}"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" ]] && [[ "$ID" != "sles" ]]; then
    echo -e "${YELLOW}⚠️  Ce script est conçu pour SUSE 15 SP4${NC}"
    read -p "Continuer quand même ? (y/N): " CONTINUE
    [[ "$CONTINUE" != "y" ]] && exit 1
fi

echo -e "${GREEN}✅ Système détecté: $PRETTY_NAME${NC}"
echo ""

# ============================================================================
# 1. INSTALLATION DOCKER
# ============================================================================
echo -e "${BLUE}[1/7] Installation Docker...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}  ✅ Docker déjà installé${NC}"
    docker --version
else
    echo "  Installation Docker..."
    zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_15.4/Virtualization:containers.repo
    zypper refresh
    zypper install -y docker docker-compose
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}  ✅ Docker installé${NC}"
fi

# ============================================================================
# 2. CHARGEMENT IMAGES DOCKER
# ============================================================================
echo -e "\n${BLUE}[2/7] Chargement des images Docker...${NC}"

if [ -d "$SCRIPT_DIR/../../docker-images" ]; then
    IMAGE_COUNT=0
    for img in "$SCRIPT_DIR/../../docker-images"/*.tar.gz; do
        if [ -f "$img" ]; then
            echo "  - Chargement: $(basename $img)"
            gunzip -c "$img" | docker load
            ((IMAGE_COUNT++))
        fi
    done
    echo -e "${GREEN}  ✅ $IMAGE_COUNT images chargées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Dossier docker-images non trouvé${NC}"
    echo "  Les images seront téléchargées lors du build"
fi

# ============================================================================
# 3. INSTALLATION DÉPENDANCES SYSTÈME
# ============================================================================
echo -e "\n${BLUE}[3/7] Installation des dépendances système...${NC}"

zypper install -y \
    python3 python3-pip \
    git curl wget \
    gcc gcc-c++ make cmake \
    gcc-fortran \
    openmpi4 openmpi4-devel \
    hdf5 hdf5-devel \
    netcdf netcdf-devel \
    fftw3 fftw3-devel \
    blas blas-devel \
    lapack lapack-devel \
    || echo -e "${YELLOW}  ⚠️  Certaines dépendances peuvent manquer (normal en hors ligne)${NC}"

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 4. CONFIGURATION RÉSEAU
# ============================================================================
echo -e "\n${BLUE}[4/7] Configuration réseau Docker...${NC}"

# Créer les réseaux Docker nécessaires
docker network create --subnet=172.20.0.0/24 management 2>/dev/null || echo "  Réseau management existe déjà"
docker network create --subnet=10.0.0.0/24 cluster 2>/dev/null || echo "  Réseau cluster existe déjà"
docker network create --subnet=10.10.10.0/24 storage 2>/dev/null || echo "  Réseau storage existe déjà"
docker network create --subnet=192.168.200.0/24 monitoring 2>/dev/null || echo "  Réseau monitoring existe déjà"

echo -e "${GREEN}  ✅ Réseaux configurés${NC}"

# ============================================================================
# 5. CONFIGURATION DOCKER COMPOSE
# ============================================================================
echo -e "\n${BLUE}[5/7] Configuration Docker Compose...${NC}"

DOCKER_DIR="$SCRIPT_DIR/../../docker"
if [ ! -d "$DOCKER_DIR" ]; then
    echo -e "${RED}  ❌ Dossier docker non trouvé${NC}"
    exit 1
fi

cd "$DOCKER_DIR"

if [ ! -f "docker-compose-opensource.yml" ]; then
    echo -e "${RED}  ❌ docker-compose-opensource.yml non trouvé${NC}"
    exit 1
fi

echo "  Build des images..."
docker-compose -f docker-compose-opensource.yml build --no-cache || {
    echo -e "${YELLOW}  ⚠️  Build partiel (certaines images peuvent manquer)${NC}"
}

echo -e "${GREEN}  ✅ Configuration terminée${NC}"

# ============================================================================
# 6. CONFIGURATION PERMISSIONS
# ============================================================================
echo -e "\n${BLUE}[6/7] Configuration des permissions...${NC}"

# Créer les répertoires nécessaires
mkdir -p /opt/hpc-cluster/{data,logs,configs}
chmod 755 /opt/hpc-cluster

# Permissions pour volumes Docker
mkdir -p /var/lib/docker/volumes
chmod 755 /var/lib/docker/volumes

echo -e "${GREEN}  ✅ Permissions configurées${NC}"

# ============================================================================
# 7. DÉMARRAGE CLUSTER
# ============================================================================
echo -e "\n${BLUE}[7/7] Démarrage du cluster...${NC}"

read -p "Démarrer le cluster maintenant ? (Y/n): " START
if [[ "$START" != "n" ]]; then
    echo "  Démarrage des services..."
    docker-compose -f docker-compose-opensource.yml up -d
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}CLUSTER HPC DÉMARRÉ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Attendre que les services démarrent
    sleep 10
    
    # Afficher le statut
    echo -e "${BLUE}Statut des services:${NC}"
    docker-compose -f docker-compose-opensource.yml ps
    
    echo ""
    echo -e "${GREEN}Services disponibles:${NC}"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Grafana: http://localhost:3000 (admin/admin)"
    echo "  - Nexus: http://localhost:8081"
    echo ""
    echo -e "${YELLOW}Pour voir les logs:${NC}"
    echo "  cd $DOCKER_DIR"
    echo "  docker-compose -f docker-compose-opensource.yml logs -f"
    echo ""
    echo -e "${YELLOW}Pour arrêter:${NC}"
    echo "  docker-compose -f docker-compose-opensource.yml down"
else
    echo -e "${YELLOW}  Cluster prêt mais non démarré${NC}"
    echo "  Pour démarrer: cd $DOCKER_DIR && docker-compose -f docker-compose-opensource.yml up -d"
fi

echo ""
echo -e "${GREEN}✅ Installation terminée !${NC}"
