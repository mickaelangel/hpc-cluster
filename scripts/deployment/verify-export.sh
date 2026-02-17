#!/bin/bash
# ============================================================================
# Vérification de l'Export - Cluster HPC
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

EXPORT_DIR="${1:-export-demo}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VÉRIFICATION EXPORT CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Trouver le dernier export
LATEST_EXPORT=$(ls -td "$EXPORT_DIR"/hpc-cluster-demo-* 2>/dev/null | head -1)

if [ -z "$LATEST_EXPORT" ]; then
    echo -e "${RED}❌ Aucun export trouvé dans $EXPORT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Export trouvé: $(basename $LATEST_EXPORT)${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Vérifier structure
echo -e "${BLUE}[1/6] Vérification structure...${NC}"
REQUIRED_DIRS=("docker-images" "configs" "scripts" "docker" "docs" "grafana-dashboards")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$LATEST_EXPORT/$dir" ]; then
        echo -e "${GREEN}  ✅ $dir${NC}"
    else
        echo -e "${RED}  ❌ $dir manquant${NC}"
        ((ERRORS++))
    fi
done

# Vérifier fichiers essentiels
echo -e "\n${BLUE}[2/6] Vérification fichiers essentiels...${NC}"
REQUIRED_FILES=("install-demo.sh" "README-EXPORT.md" "docker/docker-compose-opensource.yml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$LATEST_EXPORT/$file" ]; then
        echo -e "${GREEN}  ✅ $file${NC}"
    else
        echo -e "${RED}  ❌ $file manquant${NC}"
        ((ERRORS++))
    fi
done

# Vérifier images Docker
echo -e "\n${BLUE}[3/6] Vérification images Docker...${NC}"
IMAGE_COUNT=$(find "$LATEST_EXPORT/docker-images" -name "*.tar.gz" 2>/dev/null | wc -l)
if [ "$IMAGE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}  ✅ $IMAGE_COUNT images trouvées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Aucune image Docker (sera téléchargée sur serveur)${NC}"
    ((WARNINGS++))
fi

# Vérifier configurations
echo -e "\n${BLUE}[4/6] Vérification configurations...${NC}"
CONFIG_FILES=$(find "$LATEST_EXPORT/configs" -type f 2>/dev/null | wc -l)
if [ "$CONFIG_FILES" -gt 0 ]; then
    echo -e "${GREEN}  ✅ $CONFIG_FILES fichiers de configuration${NC}"
else
    echo -e "${RED}  ❌ Aucune configuration trouvée${NC}"
    ((ERRORS++))
fi

# Vérifier scripts
echo -e "\n${BLUE}[5/6] Vérification scripts...${NC}"
SCRIPT_COUNT=$(find "$LATEST_EXPORT/scripts" -name "*.sh" 2>/dev/null | wc -l)
if [ "$SCRIPT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}  ✅ $SCRIPT_COUNT scripts trouvés${NC}"
else
    echo -e "${RED}  ❌ Aucun script trouvé${NC}"
    ((ERRORS++))
fi

# Vérifier documentation
echo -e "\n${BLUE}[6/6] Vérification documentation...${NC}"
DOC_COUNT=$(find "$LATEST_EXPORT/docs" -name "*.md" 2>/dev/null | wc -l)
if [ "$DOC_COUNT" -gt 0 ]; then
    echo -e "${GREEN}  ✅ $DOC_COUNT documents trouvés${NC}"
else
    echo -e "${YELLOW}  ⚠️  Documentation limitée${NC}"
    ((WARNINGS++))
fi

# Résumé
echo -e "\n${BLUE}========================================${NC}"
if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✅ EXPORT VALIDE${NC}"
    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS avertissement(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ EXPORT INCOMPLET${NC}"
    echo -e "${RED}   $ERRORS erreur(s) trouvée(s)${NC}"
    exit 1
fi
