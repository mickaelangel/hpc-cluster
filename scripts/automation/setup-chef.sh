#!/bin/bash
# ============================================================================
# Installation Chef - Configuration Management
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CHEF${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Chef Client
wget -q https://packages.chef.io/files/stable/chef/18.0.0/sles/15/chef-18.0.0-1.x86_64.rpm || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

rpm -ivh chef-18.0.0-1.x86_64.rpm

echo -e "${GREEN}✅ Chef installé${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite Chef Server${NC}"
