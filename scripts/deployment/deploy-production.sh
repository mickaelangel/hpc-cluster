#!/bin/bash
# ============================================================================
# Script de Déploiement Production - Cluster HPC Enterprise
# Usage: sudo ./scripts/deployment/deploy-production.sh
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DÉPLOIEMENT PRODUCTION - CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================================================
# VÉRIFICATIONS PRÉ-DÉPLOIEMENT
# ============================================================================

echo -e "${CYAN}[1/8] Vérifications pré-déploiement...${NC}"

# Vérifier SUSE 15 SP4
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ Fichier /etc/os-release non trouvé${NC}"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" ]] && [[ "$ID" != "sles" ]]; then
    echo -e "${YELLOW}⚠️  Ce script est conçu pour SUSE 15 SP4${NC}"
    read -p "Continuer quand même ? (y/N): " CONTINUE
    [[ "$CONTINUE" != "y" ]] && exit 1
fi

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

# Vérifier l'espace disque (minimum 50GB)
AVAILABLE_SPACE=$(df -BG "$PROJECT_ROOT" | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 50 ]; then
    echo -e "${YELLOW}⚠️  Espace disque disponible: ${AVAILABLE_SPACE}GB (50GB minimum recommandé)${NC}"
    read -p "Continuer quand même ? (y/N): " CONTINUE
    [[ "$CONTINUE" != "y" ]] && exit 1
fi

echo -e "${GREEN}✅ Vérifications pré-déploiement OK${NC}"

# ============================================================================
# CONFIGURATION PRODUCTION
# ============================================================================

echo -e "\n${CYAN}[2/8] Configuration production...${NC}"

# Demander confirmation
echo -e "${YELLOW}⚠️  DÉPLOIEMENT EN MODE PRODUCTION${NC}"
echo -e "${YELLOW}   - Ressources limitées${NC}"
echo -e "${YELLOW}   - Logging structuré${NC}"
echo -e "${YELLOW}   - Healthchecks renforcés${NC}"
echo -e "${YELLOW}   - Restart policies strictes${NC}"
read -p "Confirmer le déploiement production ? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo -e "${RED}Déploiement annulé${NC}"
    exit 0
fi

# ============================================================================
# SAUVEGARDE PRÉ-DÉPLOIEMENT
# ============================================================================

echo -e "\n${CYAN}[3/8] Sauvegarde pré-déploiement...${NC}"

BACKUP_DIR="/var/backups/hpc-cluster/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Sauvegarder les configurations
if [ -d "configs" ]; then
    cp -r configs "$BACKUP_DIR/"
    echo -e "${GREEN}  ✅ Configurations sauvegardées${NC}"
fi

# Sauvegarder les volumes Docker (si existants)
if docker volume ls | grep -q "hpc-"; then
    echo -e "${YELLOW}  ⚠️  Volumes Docker détectés - sauvegarde recommandée${NC}"
    echo -e "${YELLOW}     Exécuter: sudo bash scripts/backup/backup-cluster.sh${NC}"
fi

# ============================================================================
# ARRÊT DES SERVICES EXISTANTS
# ============================================================================

echo -e "\n${CYAN}[4/8] Arrêt des services existants...${NC}"

cd docker
if docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}  Arrêt des conteneurs existants...${NC}"
    docker-compose -f docker-compose-opensource.yml down || true
    echo -e "${GREEN}  ✅ Services arrêtés${NC}"
else
    echo -e "${GREEN}  ✅ Aucun service en cours d'exécution${NC}"
fi

# ============================================================================
# BUILD DES IMAGES
# ============================================================================

echo -e "\n${CYAN}[5/8] Build des images Docker...${NC}"

docker-compose -f docker-compose-opensource.yml build --no-cache
echo -e "${GREEN}  ✅ Images buildées${NC}"

# ============================================================================
# DÉPLOIEMENT AVEC CONFIGURATION PRODUCTION
# ============================================================================

echo -e "\n${CYAN}[6/8] Déploiement avec configuration production...${NC}"

# Utiliser docker-compose avec override production
if [ -f "docker-compose.prod.yml" ]; then
    docker-compose -f docker-compose-opensource.yml -f docker-compose.prod.yml up -d
else
    docker-compose -f docker-compose-opensource.yml up -d
fi

echo -e "${GREEN}  ✅ Services déployés${NC}"

# ============================================================================
# VÉRIFICATION DE SANTÉ
# ============================================================================

echo -e "\n${CYAN}[7/8] Vérification de santé...${NC}"

sleep 10

# Vérifier les conteneurs
FAILED_CONTAINERS=$(docker-compose ps | grep -c "Exit" || true)
if [ "$FAILED_CONTAINERS" -gt 0 ]; then
    echo -e "${RED}  ❌ $FAILED_CONTAINERS conteneur(s) en échec${NC}"
    docker-compose ps
    exit 1
fi

# Vérifier les services critiques
echo -e "${YELLOW}  Vérification Prometheus...${NC}"
if curl -sf http://localhost:9090/-/healthy > /dev/null; then
    echo -e "${GREEN}    ✅ Prometheus OK${NC}"
else
    echo -e "${RED}    ❌ Prometheus non accessible${NC}"
fi

echo -e "${YELLOW}  Vérification Grafana...${NC}"
if curl -sf http://localhost:3000/api/health > /dev/null; then
    echo -e "${GREEN}    ✅ Grafana OK${NC}"
else
    echo -e "${RED}    ❌ Grafana non accessible${NC}"
fi

echo -e "${GREEN}  ✅ Vérification de santé terminée${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================

echo -e "\n${CYAN}[8/8] Résumé du déploiement...${NC}"

cd "$PROJECT_ROOT"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}DÉPLOIEMENT PRODUCTION TERMINÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}Services disponibles:${NC}"
echo -e "  - Prometheus:  http://localhost:9090"
echo -e "  - Grafana:     http://localhost:3000"
echo -e "  - InfluxDB:    http://localhost:8086"
echo -e "  - JupyterHub:  http://localhost:8000"
echo ""
echo -e "${CYAN}Commandes utiles:${NC}"
echo -e "  - Statut:      cd docker && docker-compose ps"
echo -e "  - Logs:        cd docker && docker-compose logs -f"
echo -e "  - Arrêt:       cd docker && docker-compose down"
echo ""
echo -e "${CYAN}Sauvegarde:${NC}"
echo -e "  - Emplacement: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}⚠️  PROCHAINES ÉTAPES:${NC}"
echo -e "  1. Changer tous les mots de passe par défaut"
echo -e "  2. Configurer les certificats SSL/TLS"
echo -e "  3. Configurer le firewall"
echo -e "  4. Activer les sauvegardes automatiques"
echo -e "  5. Voir: docs/GUIDE_DEPLOIEMENT_PRODUCTION.md"
echo ""
