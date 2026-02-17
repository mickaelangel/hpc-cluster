#!/bin/bash
# ============================================================================
# Configuration WireGuard VPN
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION WIREGUARD${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y wireguard-tools || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Générer clés
mkdir -p /etc/wireguard
wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key

# Configuration basique
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(cat /etc/wireguard/private.key)
Address = 10.8.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <peer-public-key>
AllowedIPs = 10.8.0.2/32
EOF

echo -e "${GREEN}✅ WireGuard configuré${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite clés peers${NC}"
