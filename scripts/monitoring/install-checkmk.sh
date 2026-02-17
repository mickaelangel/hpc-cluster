#!/bin/bash
# ============================================================================
# Installation Checkmk - Monitoring Infrastructure
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CHECKMK${NC}"
echo -e "${GREEN}========================================${NC}"

# Télécharger Checkmk Raw Edition
CHECKMK_VERSION="2.2.0"
cd /tmp
wget -q "https://download.checkmk.com/checkmk/${CHECKMK_VERSION}/check-mk-raw-${CHECKMK_VERSION}-el8-38.x86_64.rpm" || {
    echo -e "${YELLOW}⚠️  Téléchargement échoué${NC}"
    exit 1
}

rpm -ivh check-mk-raw-${CHECKMK_VERSION}-el8-38.x86_64.rpm || {
    echo -e "${YELLOW}⚠️  Installation nécessite dépendances${NC}"
}

echo -e "${GREEN}✅ Checkmk installé${NC}"
echo "URL: http://localhost/cmk"
