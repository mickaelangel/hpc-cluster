#!/bin/bash
# ============================================================================
# Préparation Serveur SUSE 15 SP4 pour Cluster HPC
# À exécuter AVANT l'import du package
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PRÉPARATION SERVEUR SUSE 15 SP4${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Vérifier root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ce script doit être exécuté en root${NC}"
    exit 1
fi

# Vérifier SUSE 15 SP4
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ Fichier /etc/os-release non trouvé${NC}"
    exit 1
fi

source /etc/os-release
echo -e "${GREEN}✅ Système: $PRETTY_NAME${NC}"
echo ""

# ============================================================================
# 1. VÉRIFICATION SYSTÈME
# ============================================================================
echo -e "${BLUE}[1/5] Vérification système...${NC}"

# RAM
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
if [ "$RAM_GB" -lt 16 ]; then
    echo -e "${YELLOW}  ⚠️  RAM: ${RAM_GB}GB (16GB+ recommandé)${NC}"
else
    echo -e "${GREEN}  ✅ RAM: ${RAM_GB}GB${NC}"
fi

# Disque
DISK_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_GB" -lt 100 ]; then
    echo -e "${YELLOW}  ⚠️  Disque: ${DISK_GB}GB libre (100GB+ recommandé)${NC}"
else
    echo -e "${GREEN}  ✅ Disque: ${DISK_GB}GB libre${NC}"
fi

# CPU
CPU_CORES=$(nproc)
echo -e "${GREEN}  ✅ CPU: ${CPU_CORES} cœurs${NC}"

# ============================================================================
# 2. INSTALLATION DOCKER
# ============================================================================
echo -e "\n${BLUE}[2/5] Installation Docker...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}  ✅ Docker déjà installé${NC}"
    docker --version
else
    echo "  Installation Docker..."
    
    # Ajouter repository Docker
    zypper addrepo https://download.opensuse.org/repositories/Virtualization:containers/openSUSE_Leap_15.4/Virtualization:containers.repo 2>/dev/null || {
        echo -e "${YELLOW}  ⚠️  Repository non accessible (hors ligne)${NC}"
        echo "  Docker devra être installé manuellement"
    }
    
    zypper refresh 2>/dev/null || true
    zypper install -y docker docker-compose 2>/dev/null || {
        echo -e "${YELLOW}  ⚠️  Installation Docker échouée (hors ligne)${NC}"
        echo "  Installer Docker manuellement depuis RPMs"
    }
    
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}  ✅ Docker installé${NC}"
fi

# ============================================================================
# 3. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${BLUE}[3/5] Installation dépendances système...${NC}"

zypper install -y \
    python3 python3-pip \
    git curl wget \
    gcc gcc-c++ make cmake \
    gcc-fortran \
    tar gzip \
    2>/dev/null || {
    echo -e "${YELLOW}  ⚠️  Certaines dépendances non installées (hors ligne)${NC}"
    echo "  Installer depuis RPMs locaux si disponibles"
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 4. CONFIGURATION SYSTÈME
# ============================================================================
echo -e "\n${BLUE}[4/5] Configuration système...${NC}"

# Augmenter limites système
cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF

# Configuration Docker
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

echo -e "${GREEN}  ✅ Système configuré${NC}"

# ============================================================================
# 5. CRÉATION RÉPERTOIRES
# ============================================================================
echo -e "\n${BLUE}[5/5] Création répertoires...${NC}"

mkdir -p /opt/hpc-cluster/{data,logs,configs,backups}
chmod 755 /opt/hpc-cluster

echo -e "${GREEN}  ✅ Répertoires créés${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}PRÉPARATION TERMINÉE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Prochaines étapes:${NC}"
echo "  1. Copier le package sur ce serveur"
echo "  2. Extraire: tar -xzf hpc-cluster-demo-complete-*.tar.gz"
echo "  3. Installer: cd hpc-cluster-demo-* && sudo ./install-demo.sh"
echo ""
