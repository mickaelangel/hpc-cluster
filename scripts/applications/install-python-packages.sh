#!/bin/bash
# ============================================================================
# Installation Packages Python Scientifiques
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PACKAGES PYTHON${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation packages scientifiques
pip3 install numpy scipy matplotlib pandas scikit-learn scikit-image sympy statsmodels seaborn plotly bokeh jupyter ipython

echo -e "${GREEN}✅ Packages Python installés${NC}"
