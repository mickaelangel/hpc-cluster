#!/bin/bash
# ============================================================================
# Configuration BGP pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION BGP${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation FRR (Free Range Routing)
zypper install -y frr || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration BGP basique
cat > /etc/frr/bgpd.conf <<EOF
router bgp 65000
 bgp router-id 172.20.0.101
 neighbor 172.20.0.102 remote-as 65000
EOF

systemctl enable frr
systemctl start frr

echo -e "${GREEN}✅ BGP configuré${NC}"
