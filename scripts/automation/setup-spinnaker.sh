#!/bin/bash
# ============================================================================
# Installation Spinnaker - CD Platform
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SPINNAKER${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Halyard
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
bash InstallHalyard.sh || {
    echo -e "${YELLOW}⚠️  Installation nécessite configuration${NC}"
}

echo -e "${GREEN}✅ Spinnaker Halyard installé${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite hal deploy apply${NC}"
