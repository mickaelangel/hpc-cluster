#!/bin/bash
# Script de build et export des images Docker pour déploiement offline
# Usage: ./scripts/build-and-export.sh [export-dir]
# Génère des archives tar.gz de toutes les images nécessaires

set -e

EXPORT_DIR="${1:-./hpc-export}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPORT_PATH="${EXPORT_DIR}/${TIMESTAMP}"

echo "=========================================="
echo "HPC Monitoring - Build & Export Script"
echo "=========================================="
echo ""

# Création du répertoire d'export
mkdir -p "${EXPORT_PATH}/images"
mkdir -p "${EXPORT_PATH}/configs"
mkdir -p "${EXPORT_PATH}/scripts"

echo "[1/5] Build des images Docker personnalisées..."
docker-compose build

echo ""
echo "[2/5] Pull des images publiques (Prometheus, Grafana)..."
docker pull prom/prometheus:v2.48.0
docker pull grafana/grafana:10.2.0

echo ""
echo "[3/5] Export des images Docker..."

# Images personnalisées
echo "  - Export hpc-frontal-01..."
docker save hpc-docker_frontal-01:latest | gzip > "${EXPORT_PATH}/images/hpc-frontal-01-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-frontal-02..."
docker save hpc-docker_frontal-02:latest | gzip > "${EXPORT_PATH}/images/hpc-frontal-02-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-01..."
docker save hpc-docker_slave-01:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-01-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-02..."
docker save hpc-docker_slave-02:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-02-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-03..."
docker save hpc-docker_slave-03:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-03-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-04..."
docker save hpc-docker_slave-04:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-04-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-05..."
docker save hpc-docker_slave-05:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-05-${TIMESTAMP}.tar.gz"

echo "  - Export hpc-slave-06..."
docker save hpc-docker_slave-06:latest | gzip > "${EXPORT_PATH}/images/hpc-slave-06-${TIMESTAMP}.tar.gz"

# Images publiques
echo "  - Export prometheus..."
docker save prom/prometheus:v2.48.0 | gzip > "${EXPORT_PATH}/images/prometheus-v2.48.0.tar.gz"

echo "  - Export grafana..."
docker save grafana/grafana:10.2.0 | gzip > "${EXPORT_PATH}/images/grafana-v10.2.0.tar.gz"

echo ""
echo "[4/5] Copie des fichiers de configuration..."
# Copier depuis la racine du projet
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

cp -r configs "${EXPORT_PATH}/" 2>/dev/null || true
cp -r grafana-dashboards "${EXPORT_PATH}/" 2>/dev/null || true
cp docker/docker-compose-opensource.yml "${EXPORT_PATH}/docker-compose.yml" 2>/dev/null || cp docker/docker-compose.yml "${EXPORT_PATH}/docker-compose.yml" 2>/dev/null || true
cp docker/frontal/Dockerfile "${EXPORT_PATH}/Dockerfile.frontal" 2>/dev/null || true
cp docker/client/Dockerfile "${EXPORT_PATH}/Dockerfile.slave" 2>/dev/null || true
cp -r docker/scripts "${EXPORT_PATH}/scripts" 2>/dev/null || true
cp docker/Makefile "${EXPORT_PATH}/Makefile" 2>/dev/null || true
cp README.md "${EXPORT_PATH}/" 2>/dev/null || true

echo ""
echo "[5/5] Création du script d'import..."
cat > "${EXPORT_PATH}/import-images.sh" << 'IMPORT_EOF'
#!/bin/bash
# Script d'import des images Docker depuis les archives tar.gz
# Usage: ./import-images.sh

set -e

echo "=========================================="
echo "HPC Monitoring - Import Images Script"
echo "=========================================="
echo ""

IMAGES_DIR="./images"

if [ ! -d "$IMAGES_DIR" ]; then
    echo "ERREUR: Répertoire $IMAGES_DIR non trouvé"
    exit 1
fi

echo "Import des images Docker..."
for img in "$IMAGES_DIR"/*.tar.gz; do
    if [ -f "$img" ]; then
        echo "  - Import $(basename $img)..."
        gunzip -c "$img" | docker load
    fi
done

echo ""
echo "✓ Toutes les images ont été importées avec succès"
echo ""
echo "Prochaines étapes:"
echo "  1. Vérifiez les images: docker images"
echo "  2. Lancez l'infrastructure: docker-compose up -d"
IMPORT_EOF

chmod +x "${EXPORT_PATH}/import-images.sh"

echo ""
echo "=========================================="
echo "✓ Export terminé avec succès!"
echo "=========================================="
echo ""
echo "Répertoire d'export: ${EXPORT_PATH}"
echo ""
echo "Contenu:"
echo "  - images/          : Archives tar.gz des images Docker"
echo "  - configs/         : Configurations Prometheus, Grafana, Telegraf"
echo "  - grafana-dashboards/ : Dashboards JSON"
echo "  - scripts/         : Scripts d'entrypoint et utilitaires"
echo "  - docker-compose.yml : Fichier d'orchestration"
echo "  - Dockerfile.*      : Dockerfiles pour rebuild si nécessaire"
echo "  - import-images.sh : Script d'import sur serveur cible"
echo ""
echo "Pour transférer sur clé USB:"
echo "  tar -czf hpc-monitoring-${TIMESTAMP}.tar.gz -C ${EXPORT_DIR} ${TIMESTAMP}"
echo ""
echo "Sur le serveur cible (offline):"
echo "  1. Extraire: tar -xzf hpc-monitoring-${TIMESTAMP}.tar.gz"
echo "  2. Importer: cd ${TIMESTAMP} && ./import-images.sh"
echo "  3. Démarrer: docker-compose up -d"
echo ""
