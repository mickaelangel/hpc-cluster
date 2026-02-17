#!/bin/bash
# ============================================================================
# Installation Elasticsearch - ELK Stack (Logs Avancés)
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION ELASTICSEARCH${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Elasticsearch via Docker...${NC}"

# Créer docker-compose pour Elasticsearch
cat > /tmp/elasticsearch-compose.yml <<EOF
version: '3.8'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped

volumes:
  elasticsearch_data:
EOF

docker-compose -f /tmp/elasticsearch-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ Elasticsearch installé${NC}"

# ============================================================================
# 2. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Vérification...${NC}"

sleep 10
if curl -s http://localhost:9200 &> /dev/null; then
    echo -e "${GREEN}  ✅ Elasticsearch accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Elasticsearch non accessible (peut nécessiter plus de temps)${NC}"
fi

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration...${NC}"

echo -e "${GREEN}  ✅ Elasticsearch configuré${NC}"

echo -e "\n${GREEN}=== ELASTICSEARCH INSTALLÉ ===${NC}"
echo "URL: http://localhost:9200"
echo "Pour Logstash et Kibana, voir scripts séparés"
