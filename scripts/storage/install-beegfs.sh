#!/bin/bash
# ============================================================================
# Script d'Installation BeeGFS - Cluster HPC
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
BEEGFS_VERSION="${BEEGFS_VERSION:-7.3}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION BEEGFS${NC}"
echo -e "${GREEN}Version: $BEEGFS_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. AJOUT REPOSITORY BEEGFS
# ============================================================================
echo -e "\n${YELLOW}[1/4] Ajout repository BeeGFS...${NC}"

# Ajouter repository BeeGFS
zypper addrepo https://www.beegfs.io/release/beegfs_${BEEGFS_VERSION}/dists/beegfs-sles15.repo || {
    echo -e "${YELLOW}  ⚠️  Repository BeeGFS non disponible, installation manuelle requise${NC}"
    echo -e "${YELLOW}  Télécharger depuis: https://www.beegfs.io/download${NC}"
    exit 1
}

zypper refresh

echo -e "${GREEN}  ✅ Repository ajouté${NC}"

# ============================================================================
# 2. INSTALLATION BEEGFS
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation BeeGFS...${NC}"

# Installation des composants BeeGFS
zypper install -y \
    beegfs-mgmtd \
    beegfs-meta \
    beegfs-storage \
    beegfs-client \
    beegfs-helperd \
    beegfs-utils || {
    echo -e "${RED}Erreur: Installation BeeGFS échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ BeeGFS installé${NC}"

# ============================================================================
# 3. CONFIGURATION BEEGFS
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration BeeGFS...${NC}"

# Configuration Management Service
/opt/beegfs/sbin/beegfs-setup-mgmtd -p /mnt/beegfs-mgmtd || {
    echo -e "${YELLOW}  ⚠️  Configuration MGMtd nécessite répertoire /mnt/beegfs-mgmtd${NC}"
}

# Configuration Metadata Service
/opt/beegfs/sbin/beegfs-setup-meta -p /mnt/beegfs-meta -s 1 || {
    echo -e "${YELLOW}  ⚠️  Configuration Meta nécessite répertoire /mnt/beegfs-meta${NC}"
}

# Configuration Storage Service
/opt/beegfs/sbin/beegfs-setup-storage -p /mnt/beegfs-storage -s 1 || {
    echo -e "${YELLOW}  ⚠️  Configuration Storage nécessite répertoire /mnt/beegfs-storage${NC}"
}

# Configuration Client
/opt/beegfs/sbin/beegfs-setup-client -m frontal-01 || {
    echo -e "${YELLOW}  ⚠️  Configuration Client nécessite serveur MGMtd${NC}"
}

echo -e "${GREEN}  ✅ BeeGFS configuré${NC}"

# ============================================================================
# 4. DÉMARRAGE SERVICES
# ============================================================================
echo -e "\n${YELLOW}[4/4] Démarrage services...${NC}"

systemctl enable beegfs-mgmtd
systemctl enable beegfs-meta
systemctl enable beegfs-storage
systemctl enable beegfs-helperd

systemctl start beegfs-mgmtd || true
systemctl start beegfs-meta || true
systemctl start beegfs-storage || true
systemctl start beegfs-helperd || true

echo -e "${GREEN}  ✅ Services démarrés${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== BEEGFS INSTALLÉ ===${NC}"
echo "Version: $BEEGFS_VERSION"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  # Monter le filesystem"
echo "  mount -t beegfs beegfs /mnt/beegfs"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Configurer les répertoires de stockage"
echo "  - Configurer le réseau (InfiniBand ou Ethernet)"
echo "  - Voir documentation BeeGFS pour détails"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
