#!/bin/bash
# ============================================================================
# Installation Netdata - Monitoring Temps Réel
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NETDATA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via script automatique
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --non-interactive || {
    echo -e "${YELLOW}⚠️  Installation échouée, voir documentation${NC}"
}

echo -e "${GREEN}✅ Netdata installé${NC}"
echo "URL: http://localhost:19999"
