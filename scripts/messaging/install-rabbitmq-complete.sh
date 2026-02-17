#!/bin/bash
# ============================================================================
# Installation RabbitMQ Complète - Messaging
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION RABBITMQ${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker
cat > /tmp/rabbitmq-compose.yml <<EOF
version: '3.8'
services:
  rabbitmq:
    image: rabbitmq:3-management
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: password
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    restart: unless-stopped
volumes:
  rabbitmq_data:
EOF

docker-compose -f /tmp/rabbitmq-compose.yml up -d

echo -e "${GREEN}✅ RabbitMQ installé${NC}"
echo "AMQP: localhost:5672"
echo "Management UI: http://localhost:15672"
echo "Login: admin / password"
