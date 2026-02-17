#!/bin/bash
# ============================================================================
# Configuration OSPF pour Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION OSPF${NC}"
echo -e "${GREEN}========================================${NC}"

# Configuration OSPF dans FRR
cat > /etc/frr/ospfd.conf <<EOF
router ospf
 network 172.20.0.0/24 area 0
 network 10.0.0.0/24 area 0
EOF

systemctl restart frr

echo -e "${GREEN}✅ OSPF configuré${NC}"
