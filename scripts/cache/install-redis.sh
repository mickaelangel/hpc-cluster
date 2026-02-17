#!/bin/bash
# ============================================================================
# Installation Redis - Cache In-Memory
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION REDIS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y redis || {
    echo -e "${YELLOW}Installation depuis repository${NC}"
}

# Configuration
cat > /etc/redis/redis.conf <<EOF
# Configuration Redis pour Cluster HPC
bind 127.0.0.1
port 6379
maxmemory 2gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
EOF

# Démarrage
systemctl enable redis
systemctl start redis

echo -e "${GREEN}✅ Redis installé${NC}"
echo "Port: 6379"
echo "Test: redis-cli ping"
