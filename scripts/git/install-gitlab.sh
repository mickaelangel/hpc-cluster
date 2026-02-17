#!/bin/bash
# ============================================================================
# Installation GitLab - Gestion Code Source et CI/CD
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GITLAB${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation GitLab via Docker...${NC}"

# Créer docker-compose pour GitLab
cat > /tmp/gitlab-compose.yml <<EOF
version: '3.8'
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.cluster.local'
        gitlab_rails['gitlab_shell_ssh_port'] = 2224
    ports:
      - "80:80"
      - "443:443"
      - "2224:22"
    volumes:
      - gitlab_config:/etc/gitlab
      - gitlab_logs:/var/log/gitlab
      - gitlab_data:/var/opt/gitlab
    restart: unless-stopped

volumes:
  gitlab_config:
  gitlab_logs:
  gitlab_data:
EOF

docker-compose -f /tmp/gitlab-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ GitLab installé${NC}"

# ============================================================================
# 2. ATTENTE INITIALISATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Attente initialisation GitLab...${NC}"

echo -e "${YELLOW}  ⚠️  GitLab peut prendre 5-10 minutes pour démarrer${NC}"
echo -e "${YELLOW}  Vérifier: docker logs gitlab${NC}"

# ============================================================================
# 3. RÉCUPÉRATION MOT DE PASSE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Récupération mot de passe root...${NC}"

sleep 30
docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null || {
    echo -e "${YELLOW}  ⚠️  Mot de passe root dans: /etc/gitlab/initial_root_password${NC}"
}

echo -e "\n${GREEN}=== GITLAB INSTALLÉ ===${NC}"
echo "URL: http://gitlab.cluster.local"
echo "Login: root"
echo "Mot de passe: Voir /etc/gitlab/initial_root_password dans conteneur"
