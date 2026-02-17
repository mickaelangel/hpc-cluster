#!/bin/bash
# ============================================================================
# Installation TensorFlow pour ML
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TENSORFLOW${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via pip
pip3 install tensorflow tensorflow-gpu || {
    echo -e "${YELLOW}⚠️  Installation échouée, voir documentation${NC}"
}

# Créer modulefile
mkdir -p /opt/modules/tensorflow
cat > /opt/modules/tensorflow/2.15.0 <<EOF
#%Module1.0
prepend-path PATH /usr/local/bin
prepend-path PYTHONPATH /usr/local/lib/python3.9/site-packages
EOF

echo -e "${GREEN}✅ TensorFlow installé${NC}"
echo "Module: module load tensorflow/2.15.0"
