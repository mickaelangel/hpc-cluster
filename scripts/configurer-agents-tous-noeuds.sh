#!/bin/bash
# ============================================================================
# Configuration et Vérification des Agents sur Tous les Nœuds
# S'assure que Node Exporter et Telegraf fonctionnent sur tous les nœuds
# ============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION AGENTS - TOUS LES NŒUDS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Liste des nœuds
FRONTALS=("hpc-frontal-01" "hpc-frontal-02")
COMPUTES=("hpc-compute-01" "hpc-compute-02" "hpc-compute-03" "hpc-compute-04" "hpc-compute-05" "hpc-compute-06")
ALL_NODES=("${FRONTALS[@]}" "${COMPUTES[@]}")

# Fonction de vérification d'un agent
check_agent() {
    local container=$1
    local agent=$2
    local port=$3
    
    if docker exec "$container" pgrep -x "$agent" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $agent en cours d'exécution${NC}"
        
        # Vérifier que le port est accessible
        if docker exec "$container" netstat -tln 2>/dev/null | grep -q ":$port " || \
           docker exec "$container" ss -tln 2>/dev/null | grep -q ":$port "; then
            echo -e "${GREEN}    ✓ Port $port accessible${NC}"
            return 0
        else
            echo -e "${YELLOW}    ⚠ Port $port non détecté${NC}"
            return 1
        fi
    else
        echo -e "${RED}  ✗ $agent non démarré${NC}"
        return 1
    fi
}

# Fonction de démarrage d'un agent
start_agent() {
    local container=$1
    local agent=$2
    local config=$3
    
    echo -e "${YELLOW}  Démarrage de $agent...${NC}"
    
    if [ "$agent" = "node_exporter" ]; then
        docker exec -d "$container" /usr/local/bin/node_exporter \
            --web.listen-address=:9100 \
            --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)" || true
    elif [ "$agent" = "telegraf" ]; then
        if [ -f "$config" ]; then
            docker exec -d "$container" /usr/local/bin/telegraf --config "$config" || true
        else
            docker exec -d "$container" /usr/local/bin/telegraf --config /etc/telegraf/telegraf.conf || true
        fi
    fi
    
    sleep 2
}

# Fonction de test de connectivité HTTP
test_http_endpoint() {
    local container=$1
    local port=$2
    local path=${3:-/metrics}
    
    if docker exec "$container" wget -q -O- "http://localhost:$port$path" > /dev/null 2>&1 || \
       docker exec "$container" curl -s "http://localhost:$port$path" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Vérification et configuration pour chaque nœud
TOTAL_NODES=${#ALL_NODES[@]}
CURRENT=0
SUCCESS=0
FAILED=0

for node in "${ALL_NODES[@]}"; do
    ((CURRENT++))
    echo -e "\n${BLUE}[$CURRENT/$TOTAL_NODES] Vérification: $node${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Vérifier que le conteneur existe et est en cours d'exécution
    if ! docker ps --format '{{.Names}}' | grep -q "^${node}$"; then
        echo -e "${RED}  ✗ Conteneur $node non trouvé ou arrêté${NC}"
        ((FAILED++))
        continue
    fi
    
    NODE_OK=true
    
    # Vérifier Node Exporter
    if ! check_agent "$node" "node_exporter" "9100"; then
        start_agent "$node" "node_exporter" ""
        sleep 2
        if ! check_agent "$node" "node_exporter" "9100"; then
            NODE_OK=false
        fi
    fi
    
    # Test HTTP Node Exporter
    if test_http_endpoint "$node" "9100" "/metrics"; then
        echo -e "${GREEN}    ✓ Endpoint /metrics accessible${NC}"
    else
        echo -e "${YELLOW}    ⚠ Endpoint /metrics non accessible${NC}"
    fi
    
    # Vérifier Telegraf
    if [[ " ${FRONTALS[@]} " =~ " ${node} " ]]; then
        TELEGRAF_CONFIG="/etc/telegraf/telegraf.conf"
    else
        TELEGRAF_CONFIG="/etc/telegraf/telegraf.conf"
    fi
    
    if ! check_agent "$node" "telegraf" "9273"; then
        start_agent "$node" "telegraf" "$TELEGRAF_CONFIG"
        sleep 2
        if ! check_agent "$node" "telegraf" "9273"; then
            NODE_OK=false
        fi
    fi
    
    # Test HTTP Telegraf
    if test_http_endpoint "$node" "9273" "/metrics"; then
        echo -e "${GREEN}    ✓ Endpoint Telegraf /metrics accessible${NC}"
    else
        echo -e "${YELLOW}    ⚠ Endpoint Telegraf /metrics non accessible${NC}"
    fi
    
    if [ "$NODE_OK" = true ]; then
        ((SUCCESS++))
        echo -e "${GREEN}  ✅ $node: Tous les agents fonctionnent${NC}"
    else
        ((FAILED++))
        echo -e "${RED}  ❌ $node: Problèmes détectés${NC}"
    fi
done

# Résumé
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ Nœuds opérationnels: $SUCCESS/$TOTAL_NODES${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}  ❌ Nœuds avec problèmes: $FAILED/$TOTAL_NODES${NC}"
fi
echo ""

# Vérification Prometheus
echo -e "${BLUE}Vérification Prometheus...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^hpc-prometheus$"; then
    echo -e "${GREEN}  ✓ Prometheus en cours d'exécution${NC}"
    
    # Test des targets Prometheus
    echo -e "${YELLOW}  Vérification des targets Prometheus...${NC}"
    sleep 3
    
    if docker exec hpc-prometheus wget -q -O- "http://localhost:9090/api/v1/targets" 2>/dev/null | grep -q "health"; then
        echo -e "${GREEN}  ✓ API Prometheus accessible${NC}"
    else
        echo -e "${YELLOW}  ⚠ Impossible de vérifier les targets Prometheus${NC}"
    fi
else
    echo -e "${RED}  ✗ Prometheus non trouvé${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Configuration terminée !${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}Pour vérifier les métriques:${NC}"
echo -e "  - Prometheus: http://localhost:9090"
echo -e "  - Grafana: http://localhost:3000"
echo ""
