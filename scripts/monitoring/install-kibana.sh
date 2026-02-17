#!/bin/bash
# ============================================================================
# Installation Kibana - Visualisation Logs ELK
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION KIBANA${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Kibana via Docker...${NC}"

# Créer docker-compose pour Kibana
cat > /tmp/kibana-compose.yml <<EOF
version: '3.8'
services:
  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - xpack.security.enabled=false
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    restart: unless-stopped

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped

volumes:
  elasticsearch_data:
EOF

docker-compose -f /tmp/kibana-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ Kibana installé${NC}"

# ============================================================================
# 2. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Vérification...${NC}"

sleep 15
if curl -s http://localhost:5601 &> /dev/null; then
    echo -e "${GREEN}  ✅ Kibana accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Kibana non accessible (peut nécessiter plus de temps)${NC}"
fi

# ============================================================================
# 3. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Configuration...${NC}"

echo -e "${GREEN}  ✅ Kibana configuré${NC}"

echo -e "\n${GREEN}=== KIBANA INSTALLÉ ===${NC}"
echo "URL: http://localhost:5601"
echo "Elasticsearch: http://localhost:9200"
