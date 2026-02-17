#!/bin/bash
# ============================================================================
# Script de Vérification et Préparation du Cluster HPC
# Vérifie tous les fichiers essentiels et prépare ce qui manque
# Usage: sudo ./verifier-et-preparer.sh
# ============================================================================

set -uo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}VÉRIFICATION ET PRÉPARATION CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Compteurs
TOTAL=0
OK=0
MANQUANT=0
A_CREER=0

# Fonction de vérification
check_file() {
    local file=$1
    local description=$2
    local create_if_missing=${3:-false}
    
    ((TOTAL++))
    if [ -f "$file" ]; then
        echo -e "${GREEN}  ✅ $description${NC}"
        ((OK++))
        return 0
    else
        echo -e "${RED}  ❌ $description (MANQUANT: $file)${NC}"
        ((MANQUANT++))
        if [ "$create_if_missing" = "true" ]; then
            ((A_CREER++))
        fi
        return 1
    fi
}

# Fonction de création de répertoire
create_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${YELLOW}  📁 Répertoire créé: $dir${NC}"
    fi
}

echo -e "${CYAN}[1/8] Vérification des fichiers Docker essentiels...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_file "docker/docker-compose-opensource.yml" "Docker Compose Open-Source"
check_file "docker/frontal/Dockerfile" "Dockerfile frontal"
check_file "docker/client/Dockerfile" "Dockerfile client"
check_file "docker/scripts/entrypoint-frontal.sh" "Script entrypoint frontal"
check_file "docker/scripts/entrypoint-slave.sh" "Script entrypoint slave"
check_file "docker/scripts/entrypoint-client.sh" "Script entrypoint client"
check_file "docker/frontal/systemd/node-exporter.service" "Service systemd node-exporter frontal"
check_file "docker/frontal/systemd/telegraf.service" "Service systemd telegraf frontal"
check_file "docker/client/systemd/node-exporter.service" "Service systemd node-exporter client"
check_file "docker/client/systemd/telegraf.service" "Service systemd telegraf client"

echo ""
echo -e "${CYAN}[2/8] Vérification des fichiers de configuration...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_file "configs/prometheus/prometheus.yml" "Configuration Prometheus"
check_file "configs/prometheus/alerts.yml" "Règles d'alerte Prometheus"
check_file "configs/grafana/provisioning/datasources/prometheus.yml" "Datasource Grafana Prometheus"
check_file "configs/grafana/provisioning/dashboards/default.yml" "Configuration dashboards Grafana"
check_file "configs/telegraf/telegraf-frontal.conf" "Configuration Telegraf frontal"
check_file "configs/telegraf/telegraf-slave.conf" "Configuration Telegraf slave"
check_file "configs/loki/loki-config.yml" "Configuration Loki"
check_file "configs/promtail/config.yml" "Configuration Promtail"
check_file "configs/slurm/slurm.conf" "Configuration Slurm"
check_file "configs/slurm/cgroup.conf" "Configuration cgroup Slurm"
check_file "configs/jupyterhub/jupyterhub_config.py" "Configuration JupyterHub"

echo ""
echo -e "${CYAN}[3/8] Vérification des scripts principaux...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_file "cluster-start.sh" "Script de démarrage cluster"
check_file "cluster-stop.sh" "Script d'arrêt cluster"
check_file "install-all.sh" "Script d'installation complète"
check_file "scripts/INSTALL.sh" "Script d'installation base"
check_file "scripts/install-ldap-kerberos.sh" "Script installation LDAP+Kerberos"
check_file "scripts/install-freeipa.sh" "Script installation FreeIPA"

echo ""
echo -e "${CYAN}[4/8] Vérification des répertoires essentiels...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

REQUIRED_DIRS=(
    "docker/scripts"
    "docker/frontal/systemd"
    "docker/client/systemd"
    "configs/prometheus"
    "configs/grafana/provisioning/datasources"
    "configs/grafana/provisioning/dashboards"
    "configs/telegraf"
    "configs/loki"
    "configs/promtail"
    "configs/slurm"
    "configs/jupyterhub"
    "scripts"
    "docs"
    "grafana-dashboards"
    "examples/jobs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}  ✅ Répertoire: $dir${NC}"
    else
        echo -e "${YELLOW}  📁 Création: $dir${NC}"
        create_dir "$dir"
    fi
done

echo ""
echo -e "${CYAN}[5/8] Vérification des permissions des scripts...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SCRIPTS_TO_CHECK=(
    "cluster-start.sh"
    "cluster-stop.sh"
    "install-all.sh"
    "scripts/INSTALL.sh"
    "scripts/install-ldap-kerberos.sh"
    "scripts/install-freeipa.sh"
    "docker/scripts/entrypoint-frontal.sh"
    "docker/scripts/entrypoint-slave.sh"
    "docker/scripts/entrypoint-client.sh"
)

for script in "${SCRIPTS_TO_CHECK[@]}"; do
    if [ -f "$script" ]; then
        if [ ! -x "$script" ]; then
            chmod +x "$script"
            echo -e "${YELLOW}  🔧 Permissions ajoutées: $script${NC}"
        else
            echo -e "${GREEN}  ✅ Permissions OK: $script${NC}"
        fi
    fi
done

echo ""
echo -e "${CYAN}[6/8] Vérification des fichiers de documentation essentiels...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_file "README.md" "README principal"
check_file "GUIDE_DEMARRAGE_RAPIDE.md" "Guide démarrage rapide"
check_file "PROJET_STRUCTURE.md" "Structure du projet"

echo ""
echo -e "${CYAN}[7/8] Vérification des prérequis système...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}  ✅ Docker: $(docker --version)${NC}"
else
    echo -e "${RED}  ❌ Docker non installé${NC}"
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}  ✅ Docker Compose: $(docker-compose --version)${NC}"
elif docker compose version &> /dev/null; then
    echo -e "${GREEN}  ✅ Docker Compose: $(docker compose version)${NC}"
else
    echo -e "${RED}  ❌ Docker Compose non installé${NC}"
fi

# Espace disque
AVAILABLE_SPACE=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | sed 's/G//' || echo "N/A")
if [ "$AVAILABLE_SPACE" != "N/A" ] && [ "${AVAILABLE_SPACE:-0}" -lt 10 ] 2>/dev/null; then
    echo -e "${YELLOW}  ⚠️  Espace disque: ${AVAILABLE_SPACE}GB (10GB recommandé)${NC}"
else
    echo -e "${GREEN}  ✅ Espace disque: ${AVAILABLE_SPACE}GB${NC}"
fi

echo ""
echo -e "${CYAN}[8/8] Vérification des fichiers optionnels mais recommandés...${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_file ".gitignore" ".gitignore"
check_file "docker/Makefile" "Makefile Docker"
check_file "DEMO.md" "Guide démo"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ DE LA VÉRIFICATION${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ Fichiers présents: $OK/$TOTAL${NC}"
echo -e "${RED}  ❌ Fichiers manquants: $MANQUANT/$TOTAL${NC}"
if [ $A_CREER -gt 0 ]; then
    echo -e "${YELLOW}  📝 Fichiers à créer: $A_CREER${NC}"
fi
echo ""

if [ $MANQUANT -eq 0 ]; then
    echo -e "${GREEN}🎉 TOUS LES FICHIERS ESSENTIELS SONT PRÉSENTS !${NC}"
    echo ""
    echo -e "${CYAN}Prochaines étapes:${NC}"
    echo -e "  1. sudo ./install-all.sh  (installation complète)"
    echo -e "  2. sudo ./cluster-start.sh  (démarrage rapide)"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️  CERTAINS FICHIERS SONT MANQUANTS${NC}"
    echo -e "${YELLOW}Consultez la liste ci-dessus pour les détails.${NC}"
    echo ""
    exit 1
fi
