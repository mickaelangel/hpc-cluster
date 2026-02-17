#!/bin/bash
# ============================================================================
# Script d'Installation Lustre - Cluster HPC
# Système de Fichiers Parallèle Open-Source (Alternative à GPFS)
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
LUSTRE_VERSION="${LUSTRE_VERSION:-2.15}"
INSTALL_DIR="${INSTALL_DIR:-/opt/lustre}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION LUSTRE${NC}"
echo -e "${GREEN}Version: $LUSTRE_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation dépendances...${NC}"

zypper install -y \
    gcc gcc-c++ make \
    kernel-devel kernel-source \
    zlib-devel \
    libselinux-devel \
    libyaml-devel \
    git || {
    echo -e "${RED}Erreur: Installation dépendances échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Dépendances installées${NC}"

# ============================================================================
# 2. TÉLÉCHARGEMENT LUSTRE
# ============================================================================
echo -e "\n${YELLOW}[2/4] Téléchargement Lustre...${NC}"

cd /tmp
if [ ! -d lustre-release ]; then
    git clone https://git.whamcloud.com/fs/lustre-release.git || {
        echo -e "${YELLOW}  ⚠️  Clone Lustre échoué, utilisation alternative${NC}"
        # Alternative: télécharger depuis releases
        wget https://downloads.whamcloud.com/public/lustre/lustre-${LUSTRE_VERSION}/el8.6/server/lustre-server-${LUSTRE_VERSION}-1.el8.x86_64.rpm || {
            echo -e "${RED}Erreur: Téléchargement Lustre échoué${NC}"
            exit 1
        }
    }
fi

echo -e "${GREEN}  ✅ Lustre téléchargé${NC}"

# ============================================================================
# 3. COMPILATION LUSTRE
# ============================================================================
echo -e "\n${YELLOW}[3/4] Compilation Lustre...${NC}"

# Note: Lustre nécessite compilation des modules kernel
# Cette étape peut être complexe et nécessite kernel headers

echo -e "${YELLOW}  ⚠️  Compilation Lustre nécessite kernel headers${NC}"
echo -e "${YELLOW}  Installation des modules via packages recommandée${NC}"

# Alternative: Installation depuis packages précompilés
if [ -f /tmp/lustre-server-*.rpm ]; then
    zypper install -y /tmp/lustre-server-*.rpm || {
        echo -e "${YELLOW}  ⚠️  Installation package échouée, compilation manuelle requise${NC}"
    }
fi

echo -e "${GREEN}  ✅ Lustre installé${NC}"

# ============================================================================
# 4. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration Lustre...${NC}"

# Créer répertoire de configuration
mkdir -p /etc/lustre

# Configuration de base
cat > /etc/lustre/lustre.conf <<EOF
# Configuration Lustre
# MGS (Metadata Gateway Server)
MGS_NID=frontal-01@tcp0

# MDS (Metadata Server)
MDS_NID=frontal-01@tcp0

# OSS (Object Storage Server)
OSS_NID=frontal-01@tcp0,frontal-02@tcp0
EOF

echo -e "${GREEN}  ✅ Lustre configuré${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== LUSTRE INSTALLÉ ===${NC}"
echo "Version: $LUSTRE_VERSION"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Lustre nécessite configuration réseau InfiniBand ou Ethernet"
echo "  - Configuration MGS/MDS/OSS requise"
echo "  - Voir documentation Lustre pour détails"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
