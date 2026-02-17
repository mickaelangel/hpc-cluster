#!/bin/bash
# ============================================================================
# Tests d'Intégration - Cluster HPC
# Usage: sudo bash tests/integration/test_cluster_integration.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

test_service() {
    local service=$1
    local url=$2
    local name=$3
    
    if curl -sf "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ $name accessible${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}  ❌ $name non accessible${NC}"
        ((FAILED++))
        return 1
    fi
}

test_container() {
    local container=$1
    if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
        echo -e "${GREEN}  ✅ $container en cours d'exécution${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}  ❌ $container non démarré${NC}"
        ((FAILED++))
        return 1
    fi
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}TESTS D'INTÉGRATION CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Tests des services
echo -e "${YELLOW}[1/4] Tests des services...${NC}"
test_service "prometheus" "http://localhost:9090/-/healthy" "Prometheus"
test_service "grafana" "http://localhost:3000/api/health" "Grafana"
test_service "influxdb" "http://localhost:8086/health" "InfluxDB"
test_service "jupyterhub" "http://localhost:8000" "JupyterHub"

# Tests des conteneurs
echo -e "\n${YELLOW}[2/4] Tests des conteneurs...${NC}"
test_container "hpc-prometheus"
test_container "hpc-grafana"
test_container "hpc-frontal-01"
test_container "hpc-compute-01"

# Tests de connectivité réseau
echo -e "\n${YELLOW}[3/4] Tests de connectivité réseau...${NC}"
if docker exec hpc-frontal-01 ping -c 1 hpc-compute-01 > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Connectivité frontal-01 → compute-01${NC}"
    ((PASSED++))
else
    echo -e "${RED}  ❌ Connectivité frontal-01 → compute-01${NC}"
    ((FAILED++))
fi

# Tests de santé globale
echo -e "\n${YELLOW}[4/4] Tests de santé globale...${NC}"
if [ -f "scripts/tests/test-cluster-health.sh" ]; then
    if bash scripts/tests/test-cluster-health.sh > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ Santé globale OK${NC}"
        ((PASSED++))
    else
        echo -e "${RED}  ❌ Problèmes de santé détectés${NC}"
        ((FAILED++))
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Résultats:${NC}"
echo -e "${GREEN}Passés: $PASSED${NC}"
echo -e "${RED}Échoués: $FAILED${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
