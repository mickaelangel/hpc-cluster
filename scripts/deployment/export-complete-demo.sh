#!/bin/bash
# ============================================================================
# Export Complet Cluster HPC pour Démo Hors Ligne
# Export Docker + Configurations + Documentation pour openSUSE 15.6
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EXPORT_DIR="$PROJECT_ROOT/export-demo"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPORT_NAME="hpc-cluster-demo-${TIMESTAMP}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}EXPORT COMPLET CLUSTER HPC POUR DÉMO${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Créer répertoire d'export
mkdir -p "$EXPORT_DIR/$EXPORT_NAME"
cd "$EXPORT_DIR/$EXPORT_NAME"

echo -e "${YELLOW}📦 Préparation de l'export...${NC}"

# ============================================================================
# 1. EXPORT IMAGES DOCKER
# ============================================================================
echo -e "\n${BLUE}[1/8] Export des images Docker...${NC}"
mkdir -p docker-images
cat > docker-images/README.txt <<'IMG_EOF'
Images Docker pour installation hors ligne.
Si ce dossier ne contient aucun .tar.gz (ou des archives vides), l'export a été
fait sans que les images soient présentes sur la machine.

Pour obtenir des images complètes :
  Sur une machine AVEC Internet et Docker :
    cd "cluster hpc"
    sudo bash scripts/deployment/export-hors-ligne-complet.sh
  Ce script fait "docker pull" puis relance l'export.
IMG_EOF

# Images du stack open-source (docker-compose-opensource.yml) pour démo hors ligne
IMAGES=(
    "opensuse/leap:15.6"
    "prom/prometheus:v2.48.0"
    "grafana/grafana:10.2.0"
    "influxdb:2.7"
    "grafana/loki:2.9.0"
    "grafana/promtail:2.9.0"
    "jupyterhub/jupyterhub:4.0"
)

echo "Export de ${#IMAGES[@]} images Docker..."
for image in "${IMAGES[@]}"; do
    echo "  - Export: $image"
    IMAGE_FILE=$(echo "$image" | tr '/:' '_' | tr -d '.')
    TMP_SAVE=$(mktemp)
    if docker save "$image" > "$TMP_SAVE" 2>/dev/null; then
        gzip -c "$TMP_SAVE" > "docker-images/${IMAGE_FILE}.tar.gz"
        echo -e "    ${GREEN}✅${NC}"
    else
        echo -e "${YELLOW}    ⚠️  Image non disponible (lancez: docker pull $image)${NC}"
    fi
    rm -f "$TMP_SAVE"
done
# Supprimer les archives vides ou corrompues (fichiers < 10 Ko)
find docker-images -name '*.tar.gz' -size -10k -delete 2>/dev/null || true

# ============================================================================
# 2. EXPORT CONFIGURATIONS
# ============================================================================
echo -e "\n${BLUE}[2/8] Export des configurations...${NC}"
mkdir -p configs
cp -r "$PROJECT_ROOT/configs/"* configs/ 2>/dev/null || true
echo "  ✅ Configurations exportées"

# ============================================================================
# 3. EXPORT SCRIPTS
# ============================================================================
echo -e "\n${BLUE}[3/8] Export des scripts...${NC}"
mkdir -p scripts
cp -r "$PROJECT_ROOT/scripts/"* scripts/ 2>/dev/null || true
# Supprimer les scripts commerciaux s'ils existent encore
rm -f scripts/applications/install-gaussian.sh 2>/dev/null || true
rm -f scripts/applications/install-vasp.sh 2>/dev/null || true
rm -f scripts/applications/install-charmm.sh 2>/dev/null || true
rm -f scripts/monitoring/install-datadog-agent.sh 2>/dev/null || true
rm -f scripts/monitoring/install-newrelic-agent.sh 2>/dev/null || true
rm -f scripts/monitoring/install-splunk.sh 2>/dev/null || true
echo "  ✅ Scripts exportés"

# ============================================================================
# 4. EXPORT DOCKER COMPOSE
# ============================================================================
echo -e "\n${BLUE}[4/8] Export Docker Compose...${NC}"
mkdir -p docker
cp -r "$PROJECT_ROOT/docker/"* docker/ 2>/dev/null || true
echo "  ✅ Docker Compose exporté"

# ============================================================================
# 5. EXPORT DOCUMENTATION
# ============================================================================
echo -e "\n${BLUE}[5/8] Export de la documentation...${NC}"
mkdir -p docs
cp -r "$PROJECT_ROOT/docs/"* docs/ 2>/dev/null || true
# Copier aussi les documents à la racine importants
cp "$PROJECT_ROOT/README.md" . 2>/dev/null || true
cp "$PROJECT_ROOT/install-all.sh" . 2>/dev/null || true
cp "$PROJECT_ROOT/DEMO.md" . 2>/dev/null || true
cp "$PROJECT_ROOT/INSTALLATION_CLE_USB.md" . 2>/dev/null || true
cp "$PROJECT_ROOT/cluster-start.sh" . 2>/dev/null || true
cp "$PROJECT_ROOT/cluster-stop.sh" . 2>/dev/null || true
cp "$PROJECT_ROOT/INSTALL_SERVEUR_SUDE_15.txt" . 2>/dev/null || true
cp "$PROJECT_ROOT/AUDIT_FINAL_100_OPENSOURCE.md" . 2>/dev/null || true
chmod +x cluster-start.sh cluster-stop.sh 2>/dev/null || true
echo "  ✅ Documentation exportée"

# ============================================================================
# 6. EXPORT DASHBOARDS GRAFANA
# ============================================================================
echo -e "\n${BLUE}[6/8] Export dashboards Grafana...${NC}"
mkdir -p grafana-dashboards
cp -r "$PROJECT_ROOT/grafana-dashboards/"* grafana-dashboards/ 2>/dev/null || true
echo "  ✅ Dashboards exportés"

# ============================================================================
# 6b. DOCKER HORS LIGNE (RPM)
# ============================================================================
mkdir -p docker-offline-rpms
cp "$PROJECT_ROOT/scripts/deployment/install-docker-offline.sh" . 2>/dev/null || true
chmod +x install-docker-offline.sh 2>/dev/null || true
cat > docker-offline-rpms/README.txt <<'RPMS_EOF'
RPM Docker pour installation hors ligne (openSUSE 15.6 / openSUSE Leap 15.6)
================================================================================

Sur une machine AVEC INTERNET (openSUSE 15.6 ou openSUSE Leap 15.6) :
  sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh

Cela remplit ce dossier avec les .rpm. Copiez tout l'export (ou au minimum
ce dossier docker-offline-rpms/) sur la clé USB.

Sur le serveur openSUSE 15.6 HORS LIGNE :
  sudo ./install-docker-offline.sh
puis
  sudo ./install-demo.sh
RPMS_EOF
# Copier les RPM déjà téléchargés (si présents dans le projet)
if [ -d "$PROJECT_ROOT/docker-offline-rpms" ]; then
    cp -n "$PROJECT_ROOT/docker-offline-rpms"/*.rpm docker-offline-rpms/ 2>/dev/null || true
fi
echo "  ✅ Dossier docker-offline-rpms/ et install-docker-offline.sh prêts"

# ============================================================================
# 7. CRÉER SCRIPT D'INSTALLATION
# ============================================================================
echo -e "\n${BLUE}[7/8] Création script d'installation...${NC}"
cat > install-demo.sh <<'INSTALL_EOF'
#!/bin/bash
# ============================================================================
# Installation Cluster HPC - Démo Hors Ligne
# openSUSE 15.6
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION CLUSTER HPC - DÉMO${NC}"
echo -e "${BLUE}========================================${NC}"

# Vérifier openSUSE 15.6
if [ ! -f /etc/os-release ]; then
    echo "❌ Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" ]]; then
    echo -e "${YELLOW}⚠️  Ce script est conçu pour openSUSE 15.6${NC}"
    read -p "Continuer quand même ? (y/N): " CONTINUE
    [[ "$CONTINUE" != "y" ]] && exit 1
fi

# Installer Docker si absent (hors ligne : RPM locaux ; en ligne : zypper)
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker non installé. Tentative installation...${NC}"
    if [ -d "docker-offline-rpms" ] && [ -n "$(ls -A docker-offline-rpms/*.rpm 2>/dev/null)" ]; then
        echo -e "${YELLOW}  Installation depuis docker-offline-rpms/ (hors ligne)${NC}"
        bash ./install-docker-offline.sh
    elif command -v zypper &> /dev/null; then
        echo -e "${YELLOW}  Installation via zypper (connexion requise)${NC}"
        zypper install -y docker docker-compose 2>/dev/null || zypper install -y docker docker-compose-plugin
        systemctl enable docker
        systemctl start docker
    else
        echo -e "${RED}  ❌ Installez Docker (RPM dans docker-offline-rpms/ ou zypper) puis relancez install-demo.sh${NC}"
        exit 1
    fi
fi

# Charger les images Docker
echo -e "\n${BLUE}[1/4] Chargement des images Docker...${NC}"
if [ -d "docker-images" ]; then
    for img in docker-images/*.tar.gz; do
        if [ -f "$img" ]; then
            echo "  - Chargement: $(basename $img)"
            gunzip -c "$img" | docker load
        fi
    done
else
    echo -e "${YELLOW}  ⚠️  Dossier docker-images non trouvé${NC}"
fi

# Installation des dépendances système
echo -e "\n${BLUE}[2/4] Installation des dépendances...${NC}"
zypper install -y \
    python3 python3-pip \
    git curl wget \
    gcc gcc-c++ make cmake \
    openmpi4 openmpi4-devel \
    hdf5 hdf5-devel \
    netcdf netcdf-devel \
    || echo -e "${YELLOW}  ⚠️  Certaines dépendances peuvent manquer${NC}"

# Configuration Docker Compose
echo -e "\n${BLUE}[3/4] Configuration Docker Compose...${NC}"
cd docker
if [ -f "docker-compose-opensource.yml" ]; then
    docker-compose -f docker-compose-opensource.yml build
    echo -e "${GREEN}  ✅ Build terminé${NC}"
else
    echo -e "${RED}  ❌ docker-compose-opensource.yml non trouvé${NC}"
    exit 1
fi

# Démarrage
echo -e "\n${BLUE}[4/4] Démarrage du cluster...${NC}"
START="${START_CLUSTER:-Y}"
if [[ "$START" =~ ^[yY] ]] || [[ -z "$START" ]]; then
    docker compose -f docker-compose-opensource.yml up -d 2>/dev/null || docker-compose -f docker-compose-opensource.yml up -d
    echo -e "${GREEN}  ✅ Cluster démarré${NC}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}CLUSTER HPC DÉMARRÉ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Services disponibles:"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Grafana: http://localhost:3000 (admin/admin)"
    echo "  - JupyterHub: http://localhost:8000"
    echo ""
    echo "Démo: voir DEMO.md | Arrêt: ./cluster-stop.sh"
else
    echo "  Démarrer plus tard: cd docker && docker compose -f docker-compose-opensource.yml up -d"
fi

cd ..

echo -e "\n${GREEN}✅ Installation terminée !${NC}"
INSTALL_EOF

chmod +x install-demo.sh
echo "  ✅ Script d'installation créé"

# ============================================================================
# 8. CRÉER README D'EXPORT
# ============================================================================
echo -e "\n${BLUE}[8/8] Création README d'export...${NC}"
cat > README-EXPORT.md <<'README_EOF'
# 📦 Export Cluster HPC - Démo Hors Ligne

**Date d'export**: $(date)  
**Version**: 2.0  
**Destination**: openSUSE 15.6 (Hors Ligne)

---

## 📋 Contenu de l'Export

- ✅ **Images Docker** : Toutes les images nécessaires
- ✅ **Configurations** : Tous les fichiers de configuration
- ✅ **Scripts** : Tous les scripts d'installation
- ✅ **Documentation** : Documentation complète
- ✅ **Dashboards** : Dashboards Grafana
- ✅ **Script d'installation** : `install-demo.sh`

---

## 🚀 Installation sur openSUSE 15.6

### Prérequis

- openSUSE 15.6 installé
- Accès root ou sudo
- Au moins 50GB d'espace disque
- Au moins 16GB de RAM

### Étapes d'Installation

1. **Copier l'export sur le serveur** :
```bash
# Via USB, réseau local, ou autre méthode
scp -r hpc-cluster-demo-* user@server:/opt/
```

2. **Se connecter au serveur** :
```bash
ssh user@server
cd /opt/hpc-cluster-demo-*
```

3. **Lancer l'installation** :
```bash
sudo ./install-demo.sh
```

4. **Vérifier le cluster** :
```bash
cd docker
docker-compose -f docker-compose-opensource.yml ps
```

---

## 📊 Services Disponibles

Après installation :

- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)
- **Nexus** : http://localhost:8081
- **Slurm** : Via SSH sur frontal-01

---

## 📚 Documentation

Toute la documentation est dans le dossier `docs/` :

- `docs/DOCUMENTATION_COMPLETE_MASTER.md` - Guide complet
- `docs/GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md` - Toutes technologies
- `docs/ARCHITECTURE_ET_CHOIX_CONCEPTION.md` - Architecture

---

## ✅ Vérification

```bash
# Vérifier les conteneurs
docker ps

# Vérifier les services
systemctl status docker

# Vérifier les logs
cd docker
docker-compose -f docker-compose-opensource.yml logs
```

---

## 🆘 Support

En cas de problème, consulter :
- `docs/GUIDE_TROUBLESHOOTING.md`
- `docs/GUIDE_DEBUG_TROUBLESHOOTING.md`

---

**Version**: 2.0  
**Date**: $(date)
README_EOF

echo "  ✅ README créé"

# ============================================================================
# CRÉER ARCHIVE
# ============================================================================
echo -e "\n${BLUE}📦 Création de l'archive...${NC}"
cd "$EXPORT_DIR"
tar -czf "${EXPORT_NAME}.tar.gz" "$EXPORT_NAME"
echo -e "${GREEN}  ✅ Archive créée: ${EXPORT_NAME}.tar.gz${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}EXPORT TERMINÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📦 Export créé: ${BLUE}${EXPORT_DIR}/${EXPORT_NAME}${NC}"
echo -e "📦 Archive créée: ${BLUE}${EXPORT_DIR}/${EXPORT_NAME}.tar.gz${NC}"
echo ""
echo -e "📋 Contenu:"
echo "  - Images Docker: $(ls -1 "$EXPORT_NAME/docker-images"/*.tar.gz 2>/dev/null | wc -l) images"
echo "  - Configurations: configs/"
echo "  - Scripts: scripts/"
echo "  - Documentation: docs/"
echo "  - Dashboards: grafana-dashboards/"
echo ""
echo -e "${YELLOW}Pour transférer sur le serveur openSUSE 15.6:${NC}"
echo "  1. Copier ${EXPORT_NAME}.tar.gz sur le serveur"
echo "  2. Extraire: tar -xzf ${EXPORT_NAME}.tar.gz"
echo "  3. Installer: cd ${EXPORT_NAME} && sudo ./install-demo.sh"
echo ""
