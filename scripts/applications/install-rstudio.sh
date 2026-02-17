#!/bin/bash
# ============================================================================
# Installation RStudio Server
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION RSTUDIO SERVER${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/rstudio-compose.yml <<EOF
version: '3.8'
services:
  rstudio:
    image: rocker/rstudio:latest
    container_name: rstudio
    ports:
      - "8787:8787"
    environment:
      PASSWORD: rstudio
    volumes:
      - rstudio_data:/home/rstudio
    restart: unless-stopped

volumes:
  rstudio_data:
EOF

docker-compose -f /tmp/rstudio-compose.yml up -d

echo -e "${GREEN}✅ RStudio Server installé${NC}"
echo "URL: http://localhost:8787"
echo "Login: rstudio / rstudio"
