#!/bin/bash
# ============================================================================
# Installation Redis - Cache en Mémoire
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION REDIS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Redis...${NC}"

zypper install -y redis || {
    echo -e "${RED}Erreur: Installation Redis échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Redis installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Redis...${NC}"

# Configuration de base
sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf || {
    echo -e "${YELLOW}  ⚠️  Configuration partielle${NC}"
}

# Configuration mémoire
sed -i 's/^# maxmemory <bytes>/maxmemory 2gb/' /etc/redis/redis.conf || true
sed -i 's/^# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf || true

echo -e "${GREEN}  ✅ Redis configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage Redis...${NC}"

systemctl enable redis
systemctl start redis

echo -e "${GREEN}  ✅ Redis démarré${NC}"

echo -e "\n${GREEN}=== REDIS INSTALLÉ ===${NC}"
echo "Port: 6379"
echo "Test: redis-cli ping"
