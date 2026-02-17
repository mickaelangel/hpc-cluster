#!/bin/bash
# Script d'installation one-click pour infrastructure HPC Monitoring
# Usage: ./INSTALL.sh
# Prérequis: Docker et Docker Compose installés

set -e

echo "=========================================="
echo "HPC Monitoring - Installation Script"
echo "=========================================="
echo ""

# Vérification des prérequis
echo "[1/6] Vérification des prérequis..."

if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installé"
    echo "Installez Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "ERREUR: Docker Compose n'est pas installé"
    echo "Installez Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "  ✓ Docker détecté: $(docker --version)"
if command -v docker-compose &> /dev/null; then
    echo "  ✓ Docker Compose détecté: $(docker-compose --version)"
    COMPOSE_CMD="docker-compose"
else
    echo "  ✓ Docker Compose détecté: $(docker compose version)"
    COMPOSE_CMD="docker compose"
fi
COMPOSE_FILE="docker/docker-compose-opensource.yml"

# Vérification des permissions Docker
if ! docker ps &> /dev/null; then
    echo "ERREUR: Pas de permissions pour accéder à Docker"
    echo "Ajoutez votre utilisateur au groupe docker ou utilisez sudo"
    exit 1
fi

# Vérification de l'espace disque (minimum 10GB recommandé)
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//' || echo 99)
if [ "${AVAILABLE_SPACE:-0}" -lt 10 ] 2>/dev/null; then
    echo "ATTENTION: Espace disque disponible: ${AVAILABLE_SPACE}GB (10GB recommandé)"
    if [ -t 0 ]; then
        read -p "Continuer quand même? (y/N) " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    else
        echo "Mode non-interactif: poursuite."
    fi
fi

echo ""
echo "[2/6] Vérification de la structure des fichiers..."

REQUIRED_FILES=(
    "docker/docker-compose-opensource.yml"
    "docker/frontal/Dockerfile"
    "docker/client/Dockerfile"
    "configs/prometheus/prometheus.yml"
    "configs/prometheus/alerts.yml"
    "configs/telegraf/telegraf-frontal.conf"
    "configs/telegraf/telegraf-slave.conf"
    "docker/scripts/entrypoint-frontal.sh"
    "docker/scripts/entrypoint-slave.sh"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "ERREUR: Fichiers manquants:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

echo "  ✓ Tous les fichiers requis sont présents"

echo ""
echo "[3/6] Vérification des permissions des scripts..."
chmod +x scripts/*.sh 2>/dev/null || true
echo "  ✓ Permissions mises à jour"

echo ""
echo "[4/6] Build des images Docker personnalisées..."
echo "  (Cela peut prendre plusieurs minutes...)"
$COMPOSE_CMD -f "$COMPOSE_FILE" build

echo ""
echo "[5/6] Création des réseaux et conteneurs Docker..."
echo "[6/6] Démarrage de l'infrastructure..."
$COMPOSE_CMD -f "$COMPOSE_FILE" up -d

echo ""
echo "=========================================="
echo "✓ Installation terminée avec succès!"
echo "=========================================="
echo ""
echo "Services démarrés:"
echo "  - Prometheus:  http://localhost:9090"
echo "  - Grafana:     http://localhost:3000"
echo "    Login:       admin / demo-hpc-2024"
echo ""
echo "Nœuds frontaux:"
echo "  - frontal-01: SSH sur port 2222"
echo "  - frontal-02: SSH sur port 2223"
echo ""
echo "Vérification du statut:"
echo "  $COMPOSE_CMD -f $COMPOSE_FILE ps"
echo ""
echo "Logs:"
echo "  $COMPOSE_CMD -f $COMPOSE_FILE logs -f"
echo ""
echo "Arrêt:"
echo "  $COMPOSE_CMD -f $COMPOSE_FILE down"
echo ""

# Attente et vérification de santé
echo "Attente du démarrage des services (30 secondes)..."
sleep 30

echo ""
echo "Vérification de santé des services..."
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "  ✓ Prometheus: UP"
else
    echo "  ✗ Prometheus: DOWN (vérifiez les logs)"
fi

if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "  ✓ Grafana: UP"
else
    echo "  ✗ Grafana: DOWN (vérifiez les logs)"
fi

echo ""
echo "Pour vérifier tous les targets Prometheus:"
echo "  curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'"
echo ""
