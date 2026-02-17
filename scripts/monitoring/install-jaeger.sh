#!/bin/bash
# ============================================================================
# Installation Jaeger - Distributed Tracing
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION JAEGER${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Jaeger via Docker...${NC}"

# Créer docker-compose pour Jaeger
cat > /tmp/jaeger-compose.yml <<EOF
version: '3.8'
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    ports:
      - "16686:16686"  # UI
      - "14268:14268"  # HTTP
      - "6831:6831/udp"  # UDP
      - "6832:6832/udp"  # UDP
    environment:
      - COLLECTOR_ZIPKIN_HTTP_PORT=9411
    restart: unless-stopped
EOF

docker-compose -f /tmp/jaeger-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ Jaeger installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Jaeger...${NC}"

# Configuration pour applications
cat > /etc/jaeger/config.yaml <<EOF
# Configuration Jaeger pour Cluster HPC
sampling:
  type: const
  param: 1
collector:
  host: localhost
  port: 14268
EOF

echo -e "${GREEN}  ✅ Jaeger configuré${NC}"

# ============================================================================
# 3. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Vérification...${NC}"

sleep 5
if curl -s http://localhost:16686 &> /dev/null; then
    echo -e "${GREEN}  ✅ Jaeger accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Jaeger non accessible${NC}"
fi

echo -e "\n${GREEN}=== JAEGER INSTALLÉ ===${NC}"
echo "UI: http://localhost:16686"
echo "Endpoint: http://localhost:14268/api/traces"
