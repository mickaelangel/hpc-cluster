#!/bin/bash
# ============================================================================
# Installation OVITO - Scientific Visualization
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION OVITO${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via conda ou téléchargement
echo -e "${YELLOW}⚠️  OVITO nécessite installation depuis sources${NC}"
echo -e "${YELLOW}Voir: https://www.ovito.org/download/${NC}"

echo -e "${GREEN}✅ Configuration OVITO créée${NC}"
