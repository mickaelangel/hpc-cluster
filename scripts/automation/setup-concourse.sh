#!/bin/bash
# ============================================================================
# Installation Concourse CI
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION CONCOURSE CI${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/concourse-compose.yml <<EOF
version: '3.8'
services:
  concourse-db:
    image: postgres:13
    environment:
      POSTGRES_USER: concourse
      POSTGRES_PASSWORD: concourse
    volumes:
      - concourse_db_data:/var/lib/postgresql/data

  concourse-web:
    image: concourse/concourse:latest
    command: web
    depends_on:
      - concourse-db
    ports:
      - "8080:8080"
    environment:
      CONCOURSE_BASIC_AUTH_USERNAME: admin
      CONCOURSE_BASIC_AUTH_PASSWORD: admin
    volumes:
      - concourse_keys:/concourse-keys

  concourse-worker:
    image: concourse/concourse:latest
    command: worker
    depends_on:
      - concourse-web
    privileged: true
    volumes:
      - concourse_keys:/concourse-keys

volumes:
  concourse_db_data:
  concourse_keys:
EOF

docker-compose -f /tmp/concourse-compose.yml up -d

echo -e "${GREEN}✅ Concourse CI installé${NC}"
echo "URL: http://localhost:8080"
echo "Login: admin / admin"
