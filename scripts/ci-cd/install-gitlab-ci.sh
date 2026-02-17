#!/bin/bash
# ============================================================================
# Installation GitLab CI - Pipeline CI/CD
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GITLAB CI${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION GITLAB RUNNER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation GitLab Runner...${NC}"

# Télécharger GitLab Runner
RUNNER_VERSION="16.7.0"
RUNNER_BIN="gitlab-runner-linux-amd64"
RUNNER_DIR="/usr/local/bin"

cd /tmp
wget -q "https://gitlab-runner-downloads.s3.amazonaws.com/v${RUNNER_VERSION}/${RUNNER_BIN}" || {
    echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
    exit 1
}

mv "$RUNNER_BIN" "$RUNNER_DIR/gitlab-runner"
chmod +x "$RUNNER_DIR/gitlab-runner"

echo -e "${GREEN}  ✅ GitLab Runner installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration GitLab Runner...${NC}"

# Créer utilisateur
useradd --comment 'GitLab Runner' --create-home --shell /bin/bash gitlab-runner

# Installer comme service
gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

echo -e "${GREEN}  ✅ GitLab Runner configuré${NC}"

# ============================================================================
# 3. FICHIER .gitlab-ci.yml EXEMPLE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Création exemple .gitlab-ci.yml...${NC}"

cat > /tmp/.gitlab-ci.yml.example <<'EOF'
# Exemple .gitlab-ci.yml pour Cluster HPC

stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - ./scripts/tests/test-cluster-health.sh
    - ./scripts/tests/test-infrastructure.sh
    - ./scripts/tests/test-applications.sh

build:
  stage: build
  script:
    - cd docker
    - docker-compose build
  only:
    - main

deploy:
  stage: deploy
  script:
    - cd docker
    - docker-compose up -d
  only:
    - main
  when: manual
EOF

echo -e "${GREEN}  ✅ Exemple .gitlab-ci.yml créé${NC}"

echo -e "\n${GREEN}=== GITLAB CI INSTALLÉ ===${NC}"
echo "Runner: gitlab-runner"
echo "Configuration: gitlab-runner register"
echo "Exemple: /tmp/.gitlab-ci.yml.example"
