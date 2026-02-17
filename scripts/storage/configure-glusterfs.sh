#!/bin/bash
# ============================================================================
# Configuration GlusterFS - Stockage Distribué
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION GLUSTERFS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y glusterfs glusterfs-server || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Démarrer service
systemctl enable glusterd
systemctl start glusterd

# Créer volume (exemple)
# gluster volume create gv0 replica 2 compute-01:/data compute-02:/data
# gluster volume start gv0

echo -e "${GREEN}✅ GlusterFS configuré${NC}"
echo -e "${YELLOW}⚠️  Configuration volume nécessite plusieurs nœuds${NC}"
