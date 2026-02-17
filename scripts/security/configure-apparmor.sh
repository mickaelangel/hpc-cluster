#!/bin/bash
# ============================================================================
# Configuration AppArmor pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION APPARMOR${NC}"
echo -e "${GREEN}========================================${NC}"

# Vérifier si AppArmor disponible
if command -v aa-status &> /dev/null; then
    # Activer AppArmor
    systemctl enable apparmor
    systemctl start apparmor
    
    # Profils pour services cluster
    aa-enforce /etc/apparmor.d/* || {
        echo -e "${YELLOW}⚠️  AppArmor peut nécessiter configuration manuelle${NC}"
    }
    
    echo -e "${GREEN}✅ AppArmor configuré${NC}"
else
    echo -e "${YELLOW}⚠️  AppArmor non disponible${NC}"
fi
