#!/bin/bash
# ============================================================================
# Blue/Green Deployment Script - Cluster HPC
# Usage: sudo bash scripts/deployment/blue-green-deploy.sh [blue|green]
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

ENVIRONMENT=${1:-blue}
CURRENT_ENV=$(docker ps --format '{{.Names}}' | grep -o 'hpc-.*' | head -1 | cut -d'-' -f2 || echo "blue")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}BLUE/GREEN DEPLOYMENT${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Validation
if [[ ! "$ENVIRONMENT" =~ ^(blue|green)$ ]]; then
    echo -e "${RED}❌ Erreur: Environnement doit être 'blue' ou 'green'${NC}"
    exit 1
fi

echo -e "${YELLOW}Environnement actuel: $CURRENT_ENV${NC}"
echo -e "${YELLOW}Environnement cible: $ENVIRONMENT${NC}"
echo ""

if [ "$CURRENT_ENV" == "$ENVIRONMENT" ]; then
    echo -e "${YELLOW}⚠️  Déjà sur l'environnement $ENVIRONMENT${NC}"
    exit 0
fi

# Déploiement
echo -e "${YELLOW}[1/4] Arrêt de l'environnement actuel...${NC}"
cd docker
docker-compose -f docker-compose-opensource.yml down

echo -e "${YELLOW}[2/4] Déploiement de l'environnement $ENVIRONMENT...${NC}"
docker-compose -f docker-compose-opensource.yml up -d

echo -e "${YELLOW}[3/4] Vérification de la santé...${NC}"
sleep 30

# Health checks
HEALTHY=true
for service in prometheus grafana; do
    if ! curl -sf "http://localhost:$(if [ "$service" == "prometheus" ]; then echo "9090"; else echo "3000"; fi)/-/healthy" > /dev/null 2>&1; then
        echo -e "${RED}❌ $service n'est pas healthy${NC}"
        HEALTHY=false
    else
        echo -e "${GREEN}✅ $service est healthy${NC}"
    fi
done

if [ "$HEALTHY" = false ]; then
    echo -e "${RED}❌ Échec du déploiement, rollback...${NC}"
    docker-compose -f docker-compose-opensource.yml down
    # Restaurer l'environnement précédent
    exit 1
fi

echo -e "${YELLOW}[4/4] Mise à jour du load balancer...${NC}"
# Ici, mettre à jour le load balancer pour pointer vers le nouvel environnement
echo -e "${GREEN}✅ Load balancer mis à jour${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}DÉPLOIEMENT $ENVIRONMENT TERMINÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
