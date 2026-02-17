#!/bin/bash
# ============================================================================
# Installation Zabbix - Monitoring Enterprise
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ZABBIX${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/zabbix-compose.yml <<EOF
version: '3.8'
services:
  zabbix-server:
    image: zabbix/zabbix-server-mysql:latest
    ports:
      - "10051:10051"
    environment:
      DB_SERVER_HOST: zabbix-db
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbix
    depends_on:
      - zabbix-db

  zabbix-web:
    image: zabbix/zabbix-web-nginx-mysql:latest
    ports:
      - "80:8080"
    environment:
      DB_SERVER_HOST: zabbix-db
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbix
    depends_on:
      - zabbix-db
      - zabbix-server

  zabbix-db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: zabbix
      MYSQL_USER: zabbix
      MYSQL_PASSWORD: zabbix
    volumes:
      - zabbix_db_data:/var/lib/mysql

volumes:
  zabbix_db_data:
EOF

docker-compose -f /tmp/zabbix-compose.yml up -d

echo -e "${GREEN}✅ Zabbix installé${NC}"
echo "URL: http://localhost:80"
echo "Login: Admin / zabbix"
