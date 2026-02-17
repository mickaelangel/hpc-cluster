#!/bin/bash
# ============================================================================
# Script de Vérification de la Structure du Projet
# Vérifie que tous les fichiers nécessaires existent
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VÉRIFICATION STRUCTURE PROJET${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Fonction de vérification
check_file() {
    local file=$1
    local required=${2:-true}
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}  ✅ $file${NC}"
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}  ❌ $file (MANQUANT)${NC}"
            ((ERRORS++))
            return 1
        else
            echo -e "${YELLOW}  ⚠️  $file (optionnel)${NC}"
            ((WARNINGS++))
            return 1
        fi
    fi
}

# ============================================================================
# VÉRIFICATION FICHIERS DOCKER
# ============================================================================
echo -e "${BLUE}[1/6] Fichiers Docker...${NC}"

check_file "docker/docker-compose-opensource.yml"
check_file "docker/docker-compose.yml" false
check_file "docker/frontal/Dockerfile"
check_file "docker/client/Dockerfile"
check_file "docker/scripts/entrypoint-frontal.sh"
check_file "docker/scripts/entrypoint-slave.sh"
check_file "docker/scripts/entrypoint-client.sh" false

# ============================================================================
# VÉRIFICATION FICHIERS CONFIGURATION
# ============================================================================
echo -e "\n${BLUE}[2/6] Fichiers Configuration...${NC}"

check_file "configs/prometheus/prometheus.yml"
check_file "configs/prometheus/alerts.yml"
check_file "configs/grafana/provisioning/datasources/prometheus.yml"
check_file "configs/grafana/provisioning/dashboards/default.yml"
check_file "configs/telegraf/telegraf-frontal.conf"
check_file "configs/telegraf/telegraf-slave.conf"
check_file "configs/slurm/slurm.conf"
check_file "configs/slurm/cgroup.conf"
check_file "configs/loki/loki-config.yml"
check_file "configs/promtail/config.yml"
check_file "configs/jupyterhub/jupyterhub_config.py"

# ============================================================================
# VÉRIFICATION SCRIPTS PRINCIPAUX
# ============================================================================
echo -e "\n${BLUE}[3/6] Scripts Principaux...${NC}"

check_file "scripts/INSTALL.sh"
check_file "install-all.sh"
check_file "scripts/security/install-all-security.sh"

# ============================================================================
# VÉRIFICATION DOCUMENTATION
# ============================================================================
echo -e "\n${BLUE}[4/6] Documentation Principale...${NC}"

check_file "README.md"
check_file "docs/GUIDE_SECURITE_AVANCEE.md" false
check_file "AUDIT_PROJET_SENIOR.md" false

# ============================================================================
# VÉRIFICATION DASHBOARDS
# ============================================================================
echo -e "\n${BLUE}[5/6] Dashboards Grafana...${NC}"

if [ -d "grafana-dashboards" ] && [ "$(ls -A grafana-dashboards/*.json 2>/dev/null | wc -l)" -gt 0 ]; then
    DASHBOARD_COUNT=$(ls -1 grafana-dashboards/*.json 2>/dev/null | wc -l)
    echo -e "${GREEN}  ✅ $DASHBOARD_COUNT dashboards trouvés${NC}"
else
    echo -e "${YELLOW}  ⚠️  Aucun dashboard trouvé${NC}"
    ((WARNINGS++))
fi

# ============================================================================
# VÉRIFICATION COHÉRENCE DES CHEMINS
# ============================================================================
echo -e "\n${BLUE}[6/6] Vérification Cohérence Chemins...${NC}"

# Vérifier que les Dockerfiles référencent les bons fichiers
if grep -q "scripts/entrypoint-frontal.sh" docker/frontal/Dockerfile 2>/dev/null; then
    echo -e "${GREEN}  ✅ Dockerfile frontal référence entrypoint-frontal.sh${NC}"
else
    echo -e "${RED}  ❌ Dockerfile frontal ne référence pas entrypoint-frontal.sh${NC}"
    ((ERRORS++))
fi

if grep -q "scripts/entrypoint-slave.sh\|scripts/entrypoint-client.sh" docker/client/Dockerfile 2>/dev/null; then
    echo -e "${GREEN}  ✅ Dockerfile client référence entrypoint${NC}"
else
    echo -e "${RED}  ❌ Dockerfile client ne référence pas entrypoint${NC}"
    ((ERRORS++))
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Aucune erreur critique${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS avertissement(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ $ERRORS erreur(s) critique(s)${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS avertissement(s)${NC}"
    fi
    echo ""
    echo -e "${YELLOW}Corrigez les erreurs avant de continuer.${NC}"
    exit 1
fi
