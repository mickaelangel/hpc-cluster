#!/bin/bash
# ============================================================================
# Installation DPDK - Accélération Réseau
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION DPDK${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ make \
    kernel-devel kernel-source \
    numactl-devel \
    libpcap-devel || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT DPDK
# ============================================================================
echo -e "\n${YELLOW}[2/3] Téléchargement DPDK...${NC}"

DPDK_VERSION="23.11"
DPDK_TAR="dpdk-${DPDK_VERSION}.tar.xz"
DPDK_DIR="/opt/dpdk-${DPDK_VERSION}"

cd /tmp
if [ ! -f "$DPDK_TAR" ]; then
    wget -q "https://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

mkdir -p "$DPDK_DIR"
tar -xJf "$DPDK_TAR" -C "$DPDK_DIR" --strip-components=1

echo -e "${GREEN}  ✅ DPDK téléchargé${NC}"

# ============================================================================
# 3. COMPILATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Compilation DPDK...${NC}"

cd "$DPDK_DIR"
meson build
ninja -C build || {
    echo -e "${YELLOW}  ⚠️  Compilation échouée, voir documentation${NC}"
}

ninja -C build install || {
    echo -e "${YELLOW}  ⚠️  Installation échouée${NC}"
}

echo -e "${GREEN}  ✅ DPDK compilé${NC}"

echo -e "\n${GREEN}=== DPDK INSTALLÉ ===${NC}"
echo "Installation: $DPDK_DIR"
echo -e "${YELLOW}IMPORTANT: Configuration réseau requise pour utilisation${NC}"
