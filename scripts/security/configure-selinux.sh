#!/bin/bash
# ============================================================================
# Configuration SELinux pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION SELINUX${NC}"
echo -e "${GREEN}========================================${NC}"

# Vérifier si SELinux disponible
if command -v getenforce &> /dev/null; then
    # Configurer SELinux
    setenforce Enforcing || {
        echo -e "${YELLOW}⚠️  SELinux peut nécessiter configuration manuelle${NC}"
    }
    
    # Politiques pour services cluster
    setsebool -P httpd_can_network_connect 1
    setsebool -P httpd_can_network_relay 1
    
    echo -e "${GREEN}✅ SELinux configuré${NC}"
else
    echo -e "${YELLOW}⚠️  SELinux non disponible${NC}"
fi
