#!/bin/bash
# ============================================================================
# Script d'Import avec Validation - Cluster HPC
# Import et validation pour déploiement offline
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Vérification arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Usage: $0 <export-archive.tar.gz> [--validate-only]${NC}"
    exit 1
fi

EXPORT_ARCHIVE="$1"
VALIDATE_ONLY="${2:-}"

# Vérifier que l'archive existe
if [ ! -f "$EXPORT_ARCHIVE" ]; then
    echo -e "${RED}Erreur: Archive non trouvée: $EXPORT_ARCHIVE${NC}"
    exit 1
fi

# Créer répertoire temporaire
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}IMPORT CLUSTER HPC${NC}"
echo -e "${GREEN}Archive: $EXPORT_ARCHIVE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VALIDATION ARCHIVE
# ============================================================================
echo -e "\n${YELLOW}[1/4] Validation archive...${NC}"

# Vérifier l'intégrité
if tar -tzf "$EXPORT_ARCHIVE" > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Archive valide${NC}"
else
    echo -e "${RED}  ❌ Archive corrompue${NC}"
    exit 1
fi

# Extraire
tar -xzf "$EXPORT_ARCHIVE" -C "$TEMP_DIR" || {
    echo -e "${RED}Erreur: Extraction archive échouée${NC}"
    exit 1
}

# Trouver le répertoire d'export
EXPORT_DIR=$(find "$TEMP_DIR" -type d -name "20*" | head -1)
if [ -z "$EXPORT_DIR" ]; then
    echo -e "${RED}Erreur: Structure d'export invalide${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Archive extraite${NC}"

# ============================================================================
# 2. VALIDATION CONTENU
# ============================================================================
echo -e "\n${YELLOW}[2/4] Validation contenu...${NC}"

VALID=0
INVALID=0

# Vérifier images Docker
if [ -d "$EXPORT_DIR/docker-images" ] && [ "$(ls -A $EXPORT_DIR/docker-images)" ]; then
    echo -e "${GREEN}  ✅ Images Docker présentes${NC}"
    ((VALID++))
else
    echo -e "${YELLOW}  ⚠️  Images Docker manquantes${NC}"
    ((INVALID++))
fi

# Vérifier configurations
if [ -d "$EXPORT_DIR/configs" ] && [ "$(ls -A $EXPORT_DIR/configs)" ]; then
    echo -e "${GREEN}  ✅ Configurations présentes${NC}"
    ((VALID++))
else
    echo -e "${YELLOW}  ⚠️  Configurations manquantes${NC}"
    ((INVALID++))
fi

# Vérifier scripts
if [ -d "$EXPORT_DIR/scripts" ] && [ "$(ls -A $EXPORT_DIR/scripts)" ]; then
    echo -e "${GREEN}  ✅ Scripts présents${NC}"
    ((VALID++))
else
    echo -e "${YELLOW}  ⚠️  Scripts manquants${NC}"
    ((INVALID++))
fi

# Vérifier documentation
if [ -d "$EXPORT_DIR/docs" ] && [ "$(ls -A $EXPORT_DIR/docs)" ]; then
    echo -e "${GREEN}  ✅ Documentation présente${NC}"
    ((VALID++))
else
    echo -e "${YELLOW}  ⚠️  Documentation manquante${NC}"
    ((INVALID++))
fi

# ============================================================================
# 3. IMPORT (si non validation seule)
# ============================================================================
if [ "$VALIDATE_ONLY" != "--validate-only" ]; then
    echo -e "\n${YELLOW}[3/4] Import...${NC}"
    
    IMPORT_DIR="/opt/cluster-hpc"
    mkdir -p "$IMPORT_DIR"
    
    # Copier les fichiers
    cp -a "$EXPORT_DIR"/* "$IMPORT_DIR/" 2>/dev/null || {
        echo -e "${RED}Erreur: Import échoué${NC}"
        exit 1
    }
    
    echo -e "${GREEN}  ✅ Import terminé dans: $IMPORT_DIR${NC}"
else
    echo -e "\n${YELLOW}[3/4] Import ignoré (validation seule)${NC}"
fi

# ============================================================================
# 4. VALIDATION DÉPENDANCES
# ============================================================================
echo -e "\n${YELLOW}[4/4] Validation dépendances...${NC}"

# Vérifier Docker
if command -v docker > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Docker installé${NC}"
else
    echo -e "${YELLOW}  ⚠️  Docker non installé${NC}"
fi

# Vérifier packages système
REQUIRED_PACKAGES=("zypper" "systemctl")
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if command -v "$pkg" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ $pkg installé${NC}"
    else
        echo -e "${RED}  ❌ $pkg manquant${NC}"
    fi
done

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== IMPORT TERMINÉ ===${NC}"
echo "Archive: $EXPORT_ARCHIVE"
echo "Composants valides: $VALID"
echo "Composants manquants: $INVALID"
echo ""
if [ "$VALIDATE_ONLY" == "--validate-only" ]; then
    echo -e "${GREEN}Validation terminée (import non effectué)${NC}"
else
    echo -e "${GREEN}Import terminé dans: $IMPORT_DIR${NC}"
fi
echo ""
echo -e "${GREEN}Import terminé!${NC}"
