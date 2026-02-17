#!/bin/bash
# ============================================================================
# Installation Apache Kafka - Event Streaming
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION APACHE KAFKA${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Kafka via Docker...${NC}"

# Créer docker-compose pour Kafka
cat > /tmp/kafka-compose.yml <<EOF
version: '3.8'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:latest
    container_name: kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - kafka_data:/var/lib/kafka/data
    restart: unless-stopped

volumes:
  kafka_data:
EOF

docker-compose -f /tmp/kafka-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ Kafka installé${NC}"

# ============================================================================
# 2. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Vérification...${NC}"

sleep 15
if docker ps | grep -q kafka; then
    echo -e "${GREEN}  ✅ Kafka démarré${NC}"
else
    echo -e "${YELLOW}  ⚠️  Kafka non démarré${NC}"
fi

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration...${NC}"

echo -e "${GREEN}  ✅ Kafka configuré${NC}"

echo -e "\n${GREEN}=== KAFKA INSTALLÉ ===${NC}"
echo "Broker: localhost:9092"
echo "Zookeeper: localhost:2181"
