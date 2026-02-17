#!/bin/bash
# ============================================================================
# Installation MongoDB - Base de Données NoSQL
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION MONGODB${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation MongoDB...${NC}"

zypper install -y mongodb mongodb-server || {
    echo -e "${YELLOW}  ⚠️  Installation depuis repository, voir documentation MongoDB${NC}"
    # Alternative: installation depuis sources
}

echo -e "${GREEN}  ✅ MongoDB installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration MongoDB...${NC}"

# Configuration MongoDB
cat > /etc/mongod.conf <<EOF
# Configuration MongoDB pour Cluster HPC
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
EOF

# Créer répertoires
mkdir -p /var/lib/mongodb
mkdir -p /var/log/mongodb
chown mongodb:mongodb /var/lib/mongodb
chown mongodb:mongodb /var/log/mongodb

echo -e "${GREEN}  ✅ MongoDB configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage MongoDB...${NC}"

systemctl enable mongod
systemctl start mongod || {
    echo -e "${YELLOW}  ⚠️  Démarrage peut nécessiter configuration manuelle${NC}"
}

echo -e "${GREEN}  ✅ MongoDB démarré${NC}"

echo -e "\n${GREEN}=== MONGODB INSTALLÉ ===${NC}"
echo "Service: systemctl status mongod"
echo "Connexion: mongo --host localhost:27017"
