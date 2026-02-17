#!/bin/bash
# ============================================================================
# Installation Kafka Complète - Streaming
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION KAFKA${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation via Docker Compose
cat > /tmp/kafka-compose.yml <<EOF
version: '3.8'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:latest
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

volumes:
  kafka_data:
EOF

docker-compose -f /tmp/kafka-compose.yml up -d

echo -e "${GREEN}✅ Kafka installé${NC}"
echo "Broker: localhost:9092"
echo "Zookeeper: localhost:2181"
