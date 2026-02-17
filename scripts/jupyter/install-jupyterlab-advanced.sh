#!/bin/bash
# ============================================================================
# Installation JupyterLab Avancé
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION JUPYTERLAB AVANCÉ${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation extensions
pip3 install jupyterlab jupyterlab-git jupyterlab-lsp jupyterlab-widgets || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration
jupyter lab --generate-config

echo -e "${GREEN}✅ JupyterLab avancé installé${NC}"
echo "Démarrer: jupyter lab --ip=0.0.0.0 --port=8888"
