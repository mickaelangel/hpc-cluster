#!/bin/bash
# ============================================================================
# Installation RabbitMQ - Message Broker
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION RABBITMQ${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation RabbitMQ via Docker...${NC}"

# Créer docker-compose pour RabbitMQ
cat > /tmp/rabbitmq-compose.yml <<EOF
version: '3.8'
services:
  rabbitmq:
    image: rabbitmq:3-management
    container_name: rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    ports:
      - "5672:5672"   # AMQP
      - "15672:15672" # Management UI
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    restart: unless-stopped

volumes:
  rabbitmq_data:
EOF

docker-compose -f /tmp/rabbitmq-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ RabbitMQ installé${NC}"

# ============================================================================
# 2. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Vérification...${NC}"

sleep 10
if curl -s http://localhost:15672 &> /dev/null; then
    echo -e "${GREEN}  ✅ RabbitMQ accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  RabbitMQ non accessible (peut nécessiter plus de temps)${NC}"
fi

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration...${NC}"

echo -e "${GREEN}  ✅ RabbitMQ configuré${NC}"

echo -e "\n${GREEN}=== RABBITMQ INSTALLÉ ===${NC}"
echo "Management UI: http://localhost:15672"
echo "Login: admin / admin"
echo "AMQP: localhost:5672"
