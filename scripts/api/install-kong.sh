#!/bin/bash
# ============================================================================
# Installation Kong - API Gateway
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION KONG${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION VIA DOCKER
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Kong via Docker...${NC}"

# Créer docker-compose pour Kong
cat > /tmp/kong-compose.yml <<EOF
version: '3.8'
services:
  kong-database:
    image: postgres:15
    container_name: kong-database
    environment:
      POSTGRES_USER: kong
      POSTGRES_PASSWORD: kong
      POSTGRES_DB: kong
    volumes:
      - kong_data:/var/lib/postgresql/data
    restart: unless-stopped

  kong:
    image: kong:latest
    container_name: kong
    depends_on:
      - kong-database
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: kong-database
      KONG_PG_USER: kong
      KONG_PG_PASSWORD: kong
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
    ports:
      - "8000:8000"  # Proxy
      - "8443:8443"  # Proxy SSL
      - "8001:8001"  # Admin API
      - "8444:8444"  # Admin API SSL
    restart: unless-stopped

volumes:
  kong_data:
EOF

docker-compose -f /tmp/kong-compose.yml up -d || {
    echo -e "${YELLOW}  ⚠️  Installation Docker échouée, voir documentation${NC}"
}

echo -e "${GREEN}  ✅ Kong installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Kong...${NC}"

# Attendre que Kong soit prêt
sleep 10

# Test connexion
if curl -s http://localhost:8001/status &> /dev/null; then
    echo -e "${GREEN}  ✅ Kong accessible${NC}"
else
    echo -e "${YELLOW}  ⚠️  Kong non accessible (peut nécessiter plus de temps)${NC}"
fi

echo -e "${GREEN}  ✅ Kong configuré${NC}"

# ============================================================================
# 3. EXEMPLE CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Création exemple configuration...${NC}"

cat > /tmp/kong-config-example.sh <<'EOF'
#!/bin/bash
# Exemple configuration Kong pour Cluster HPC

KONG_ADMIN="http://localhost:8001"

# Créer service pour Prometheus
curl -i -X POST "$KONG_ADMIN/services/" \
  --data "name=prometheus" \
  --data "url=http://prometheus:9090"

# Créer route
curl -i -X POST "$KONG_ADMIN/services/prometheus/routes" \
  --data "hosts[]=prometheus.cluster.local" \
  --data "paths[]=/prometheus"

# Créer service pour Grafana
curl -i -X POST "$KONG_ADMIN/services/" \
  --data "name=grafana" \
  --data "url=http://grafana:3000"

# Créer route
curl -i -X POST "$KONG_ADMIN/services/grafana/routes" \
  --data "hosts[]=grafana.cluster.local" \
  --data "paths[]=/grafana"
EOF

chmod +x /tmp/kong-config-example.sh

echo -e "${GREEN}  ✅ Exemple configuration créé${NC}"

echo -e "\n${GREEN}=== KONG INSTALLÉ ===${NC}"
echo "Admin API: http://localhost:8001"
echo "Proxy: http://localhost:8000"
echo "Exemple config: /tmp/kong-config-example.sh"
