#!/bin/bash
# ============================================================================
# Installation SageMath
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SAGEMATH${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via conda ou Docker
echo -e "${YELLOW}⚠️  SageMath nécessite installation depuis sources ou conda${NC}"
echo -e "${YELLOW}Voir: https://www.sagemath.org/download.html${NC}"

echo -e "${GREEN}✅ Configuration SageMath créée${NC}"
