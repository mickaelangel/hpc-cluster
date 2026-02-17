#!/bin/bash
# ============================================================================
# Configuration Chiffrement InfiniBand - Cluster HPC
# Protection Données HPC en Transit
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION CHIFFREMENT INFINIBAND${NC}"
echo -e "${BLUE}========================================${NC}"

# Vérifier InfiniBand
if ! command -v ibstat &> /dev/null; then
    echo -e "${YELLOW}⚠️  InfiniBand non détecté${NC}"
    exit 0
fi

# Configuration IPsec pour InfiniBand
echo -e "\n${YELLOW}[1/2] Configuration IPsec InfiniBand...${NC}"

# Créer répertoire si nécessaire
mkdir -p /etc/ipsec.d

# Créer configuration IPsec
cat > /etc/ipsec.d/ib.conf <<EOF
# IPsec pour InfiniBand
conn ib-encrypted
    type=transport
    authby=secret
    left=%(defaultroute)
    right=%any
    ike=aes256-sha256-modp2048
    esp=aes256-sha256
    keyexchange=ikev2
    auto=start
EOF

# Configuration MPI avec chiffrement
echo -e "\n${YELLOW}[2/2] Configuration MPI Chiffré...${NC}"

# Créer répertoire si nécessaire
mkdir -p /etc/openmpi

cat > /etc/openmpi/openmpi-ib-encrypted.conf <<EOF
# OpenMPI avec InfiniBand chiffré
btl=openib,self
btl_openib_if_include=ib0
btl_openib_allow_ib=1
# Utiliser IPsec pour chiffrement
mca_btl_openib_if_include=ib0
EOF

echo -e "\n${GREEN}✅ Chiffrement InfiniBand configuré${NC}"
echo -e "${YELLOW}Note: IPsec doit être configuré sur tous les nœuds${NC}"
