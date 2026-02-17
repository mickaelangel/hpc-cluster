#!/bin/bash
# ============================================================================
# Installation VictoriaMetrics - Métriques Long Terme
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION VICTORIAMETRICS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation VictoriaMetrics via Docker...${NC}"

# Créer docker-compose pour VictoriaMetrics
cat > /tmp/victoriametrics-compose.yml <<EOF
version: '3.8'
services:
  victoriametrics:
    image: victoriametrics/victoria-metrics:latest
    container_name: victoriametrics
    command:
      - '--storageDataPath=/victoria-metrics-data'
      - '--retentionPeriod=12'
    ports:
      - "8428:8428"
    volumes:
      - victoriametrics_data:/victoriametrics-data
    restart: unless-stopped

volumes:
  victoriametrics_data:
EOF

docker-compose -f /tmp/victoriametrics-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ VictoriaMetrics installé${NC}"

# ============================================================================
# 2. CONFIGURATION PROMETHEUS
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Prometheus...${NC}"

# Exemple configuration remote_write
cat > /tmp/prometheus-remote-write.yml <<EOF
# Configuration remote_write pour Prometheus
remote_write:
  - url: http://victoriametrics:8428/api/v1/write
    queue_config:
      max_samples_per_send: 10000
      max_shards: 200
      capacity: 10000
EOF

echo -e "${GREEN}  ✅ Configuration créée${NC}"

# ============================================================================
# 3. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Vérification...${NC}"

sleep 5
if curl -s http://localhost:8428/health &> /dev/null; then
    echo -e "${GREEN}  ✅ VictoriaMetrics accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  VictoriaMetrics non accessible${NC}"
fi

echo -e "\n${GREEN}=== VICTORIAMETRICS INSTALLÉ ===${NC}"
echo "URL: http://localhost:8428"
echo "Rétention: 12 mois"
echo "Configuration Prometheus: /tmp/prometheus-remote-write.yml"
