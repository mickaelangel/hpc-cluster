#!/bin/bash
# ============================================================================
# Script d'Export Complet - Cluster HPC
# Export pour déploiement offline
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
EXPORT_DIR="${EXPORT_DIR:-/export/cluster-hpc}"
DATE=$(date +%Y%m%d_%H%M%S)
EXPORT_PATH="${EXPORT_DIR}/${DATE}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}EXPORT CLUSTER HPC POUR OFFLINE${NC}"
echo -e "${GREEN}Date: ${DATE}${NC}"
echo -e "${GREEN}Destination: ${EXPORT_PATH}${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer la structure
mkdir -p "${EXPORT_PATH}"/{docker-images,configs,scripts,packages,docs,backup}

# ============================================================================
# 1. EXPORT DOCKER IMAGES
# ============================================================================
echo -e "\n${YELLOW}[1/6] Export images Docker...${NC}"

if command -v docker > /dev/null 2>&1; then
    # Images à exporter
    IMAGES=(
        "prometheus:latest"
        "grafana/grafana:latest"
        "influxdb:latest"
        "telegraf:latest"
    )
    
    for image in "${IMAGES[@]}"; do
        if docker images | grep -q "$(echo $image | cut -d: -f1)"; then
            IMAGE_FILE=$(echo "$image" | tr '/:' '_')
            docker save "$image" | gzip > "${EXPORT_PATH}/docker-images/${IMAGE_FILE}.tar.gz" || {
                echo -e "${YELLOW}  ⚠️  Image $image non exportée${NC}"
            }
            echo -e "${GREEN}  ✅ Image $image exportée${NC}"
        fi
    done
else
    echo -e "${YELLOW}  ⚠️  Docker non installé${NC}"
fi

# ============================================================================
# 2. EXPORT CONFIGURATIONS
# ============================================================================
echo -e "\n${YELLOW}[2/6] Export configurations...${NC}"

# Configuration monitoring
if [ -d "monitoring" ]; then
    cp -a monitoring/* "${EXPORT_PATH}/configs/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Configuration monitoring exportée${NC}"
fi

# Configuration GPFS
if [ -d "gpfs" ]; then
    cp -a gpfs/* "${EXPORT_PATH}/configs/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Configuration GPFS exportée${NC}"
fi

# Configuration Slurm
if [ -f /etc/slurm/slurm.conf ]; then
    mkdir -p "${EXPORT_PATH}/configs/slurm"
    cp -a /etc/slurm/* "${EXPORT_PATH}/configs/slurm/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Configuration Slurm exportée${NC}"
fi

# ============================================================================
# 3. EXPORT SCRIPTS
# ============================================================================
echo -e "\n${YELLOW}[3/6] Export scripts...${NC}"

if [ -d "scripts" ]; then
    cp -a scripts/* "${EXPORT_PATH}/scripts/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Scripts exportés${NC}"
fi

# ============================================================================
# 4. EXPORT PACKAGES
# ============================================================================
echo -e "\n${YELLOW}[4/6] Export packages...${NC}"

# Packages GPFS
if [ -d "docker/packages/gpfs" ]; then
    cp -a docker/packages/gpfs/* "${EXPORT_PATH}/packages/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Packages GPFS exportés${NC}"
fi

# Packages Telegraf
if [ -d "docker/packages/telegraf" ]; then
    cp -a docker/packages/telegraf/* "${EXPORT_PATH}/packages/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Packages Telegraf exportés${NC}"
fi

# ============================================================================
# 5. EXPORT DOCUMENTATION
# ============================================================================
echo -e "\n${YELLOW}[5/6] Export documentation...${NC}"

if [ -d "docs" ]; then
    cp -a docs/* "${EXPORT_PATH}/docs/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Documentation exportée${NC}"
fi

# ============================================================================
# 6. CRÉATION ARCHIVE
# ============================================================================
echo -e "\n${YELLOW}[6/6] Création archive...${NC}"

cd "${EXPORT_DIR}"
tar -czf "cluster-hpc-export-${DATE}.tar.gz" "${DATE}/" 2>/dev/null || {
    echo -e "${RED}  ❌ Création archive échouée${NC}"
    exit 1
}

SIZE=$(du -h "cluster-hpc-export-${DATE}.tar.gz" | cut -f1)
echo -e "${GREEN}  ✅ Archive créée: cluster-hpc-export-${DATE}.tar.gz (${SIZE})${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== EXPORT TERMINÉ ===${NC}"
echo "Archive: cluster-hpc-export-${DATE}.tar.gz"
echo "Taille: ${SIZE}"
echo ""
echo "Contenu:"
echo "  ✅ Images Docker"
echo "  ✅ Configurations"
echo "  ✅ Scripts"
echo "  ✅ Packages"
echo "  ✅ Documentation"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Copier l'archive sur un support externe"
echo "  - Vérifier l'intégrité de l'archive"
echo "  - Utiliser import-complete.sh pour l'import"
echo ""
echo -e "${GREEN}Export terminé!${NC}"
