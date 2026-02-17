#!/bin/bash
# ============================================================================
# Configuration IPSec pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION IPSEC${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y strongswan || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration basique
cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="all"
    uniqueids=yes

conn cluster-vpn
    type=tunnel
    authby=secret
    left=172.20.0.101
    right=172.20.0.102
    ike=aes256-sha256-modp2048
    esp=aes256-sha256
    keyexchange=ikev2
    auto=start
EOF

echo -e "${GREEN}✅ IPSec configuré${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite clés partagées${NC}"
