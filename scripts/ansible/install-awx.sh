#!/bin/bash
# ============================================================================
# Script d'Installation Ansible AWX - Cluster HPC
# Infrastructure as Code pour gestion de configuration
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
AWX_VERSION="${AWX_VERSION:-23.0.0}"
AWX_PORT="${AWX_PORT:-8052}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ANSIBLE AWX${NC}"
echo -e "${GREEN}Version: $AWX_VERSION${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/4] Vérification Docker...${NC}"

if ! command -v docker > /dev/null 2>&1; then
    echo -e "${RED}Erreur: Docker requis pour AWX${NC}"
    echo -e "${YELLOW}Installer Docker d'abord${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Docker disponible${NC}"

# ============================================================================
# 2. INSTALLATION ANSIBLE
# ============================================================================
echo -e "\n${YELLOW}[2/4] Installation Ansible...${NC}"

zypper install -y python3-pip
pip3 install ansible || {
    echo -e "${RED}Erreur: Installation Ansible échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Ansible installé${NC}"

# ============================================================================
# 3. INSTALLATION AWX VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[3/4] Installation AWX via Docker...${NC}"

# Créer docker-compose pour AWX
mkdir -p /opt/awx
cat > /opt/awx/docker-compose.yml <<EOF
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: awx
      POSTGRES_USER: awx
      POSTGRES_PASSWORD: awxpassword
    volumes:
      - postgres-data:/var/lib/postgresql/data

  awx:
    image: quay.io/ansible/awx:${AWX_VERSION}
    depends_on:
      - postgres
    environment:
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: awx
      DATABASE_USER: awx
      DATABASE_PASSWORD: awxpassword
      SECRET_KEY: awx-secret-key-change-me
    ports:
      - "${AWX_PORT}:8052"
    volumes:
      - awx-data:/var/lib/awx
    command: >
      bash -c "awx-manage migrate --noinput &&
              awx-manage createsuperuser --noinput --username admin --email admin@cluster.local &&
              awx-manage create_preload_data &&
              supervisorctl -c /etc/supervisord.conf start all"

volumes:
  postgres-data:
  awx-data:
EOF

# Démarrer AWX
cd /opt/awx
docker-compose up -d || {
    echo -e "${RED}Erreur: Démarrage AWX échoué${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ AWX installé${NC}"

# ============================================================================
# 4. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration...${NC}"

# Attendre que AWX soit prêt
sleep 30

# Vérifier l'accès
if curl -s http://localhost:${AWX_PORT} > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ AWX accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  AWX en cours de démarrage...${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== ANSIBLE AWX INSTALLÉ ===${NC}"
echo "URL: http://$(hostname):${AWX_PORT}"
echo "Username: admin"
echo "Password: (à définir lors de la première connexion)"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  1. Accéder à l'interface web"
echo "  2. Créer des inventaires"
echo "  3. Créer des playbooks"
echo "  4. Lancer des jobs"
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
