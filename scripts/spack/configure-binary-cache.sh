#!/bin/bash
# ============================================================================
# Script de Configuration Spack Binary Cache - Cluster HPC
# Cache binaire partagé via NFS pour accélérer les installations
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SPACK_DIR="${SPACK_DIR:-/opt/spack}"
CACHE_DIR="${CACHE_DIR:-/gpfs/spack-cache}"
CACHE_MOUNT="${CACHE_MOUNT:-/gpfs/spack-cache}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION SPACK BINARY CACHE${NC}"
echo -e "${GREEN}Cache: $CACHE_DIR${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION SPACK
# ============================================================================
echo -e "\n${YELLOW}[1/4] Vérification Spack...${NC}"

if [ ! -d "$SPACK_DIR" ]; then
    echo -e "${YELLOW}  ⚠️  Spack non installé dans $SPACK_DIR${NC}"
    echo -e "${YELLOW}  Installation Spack recommandée d'abord${NC}"
fi

if [ ! -f "$SPACK_DIR/bin/spack" ]; then
    echo -e "${RED}Erreur: Spack non trouvé${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Spack trouvé${NC}"

# ============================================================================
# 2. CRÉATION CACHE DIRECTORY
# ============================================================================
echo -e "\n${YELLOW}[2/4] Création cache directory...${NC}"

# Créer le répertoire de cache
mkdir -p "$CACHE_DIR"
mkdir -p "$CACHE_DIR/build_cache"
mkdir -p "$CACHE_DIR/source_cache"

# Permissions
chmod 755 "$CACHE_DIR"
chmod 755 "$CACHE_DIR/build_cache"
chmod 755 "$CACHE_DIR/source_cache"

echo -e "${GREEN}  ✅ Cache directory créé${NC}"

# ============================================================================
# 3. CONFIGURATION SPACK
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration Spack...${NC}"

# Configuration Spack pour utiliser le cache
cat >> "$SPACK_DIR/etc/spack/config.yaml" <<EOF

# Binary Cache Configuration
config:
  install_tree:
    root: $SPACK_DIR/opt/spack
  build_stage:
    - $CACHE_DIR/build_cache
  source_cache: $CACHE_DIR/source_cache
EOF

# Configuration mirrors
cat >> "$SPACK_DIR/etc/spack/mirrors.yaml" <<EOF
mirrors:
  local:
    url: file://$CACHE_DIR/build_cache
    permissions:
      world_readable: true
EOF

echo -e "${GREEN}  ✅ Spack configuré${NC}"

# ============================================================================
# 4. CONFIGURATION NFS (si nécessaire)
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration NFS...${NC}"

# Si le cache est sur GPFS, il est déjà partagé
# Sinon, configurer NFS pour partager le cache

if mount | grep -q "$CACHE_MOUNT.*gpfs"; then
    echo -e "${GREEN}  ✅ Cache sur GPFS (déjà partagé)${NC}"
else
    echo -e "${YELLOW}  ⚠️  Cache local, NFS recommandé pour partage${NC}"
    echo -e "${YELLOW}  Configurer NFS pour exporter $CACHE_DIR${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== SPACK BINARY CACHE CONFIGURÉ ===${NC}"
echo "Cache directory: $CACHE_DIR"
echo "Build cache: $CACHE_DIR/build_cache"
echo "Source cache: $CACHE_DIR/source_cache"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  # Installer un package (sera mis en cache)"
echo "  spack install gcc"
echo ""
echo "  # Utiliser le cache"
echo "  spack install --use-cache gcc"
echo ""
echo -e "${GREEN}Configuration terminée!${NC}"
