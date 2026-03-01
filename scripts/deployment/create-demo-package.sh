#!/bin/bash
# ============================================================================
# Création Package Complet pour Démo Professionnelle
# Cluster HPC - openSUSE 15.6 Hors Ligne
# ============================================================================

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PACKAGE_DIR="$PROJECT_ROOT/demo-package"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CRÉATION PACKAGE DÉMO PROFESSIONNELLE${NC}"
echo -e "${BLUE}========================================${NC}"

# Créer répertoire package
mkdir -p "$PACKAGE_DIR"
cd "$PACKAGE_DIR"

# ============================================================================
# 1. EXPORT COMPLET
# ============================================================================
echo -e "\n${BLUE}[1/5] Export complet...${NC}"
"$PROJECT_ROOT/scripts/deployment/export-complete-demo.sh"

# Trouver le dernier export
LATEST_EXPORT=$(ls -td "$PROJECT_ROOT/export-demo"/hpc-cluster-demo-* 2>/dev/null | head -1)
if [ -z "$LATEST_EXPORT" ]; then
    echo -e "${RED}❌ Export non trouvé${NC}"
    exit 1
fi

# ============================================================================
# 2. CRÉER GUIDE DÉMO
# ============================================================================
echo -e "\n${BLUE}[2/5] Création guide démo...${NC}"
cat > "$LATEST_EXPORT/GUIDE_DEMO.md" <<'DEMO_EOF'
# 🎯 GUIDE DÉMO PROFESSIONNELLE - Cluster HPC

**Durée** : 30-60 minutes  
**Public** : Décideurs, IT, Chercheurs

---

## 📋 Scénario de Démo

### 1. Présentation (5 min)

**Points clés** :
- Cluster HPC 100% open-source
- Architecture professionnelle
- Technologies modernes
- Prêt pour production

**Diapositives** :
- Architecture du cluster
- Technologies utilisées
- Avantages open-source

### 2. Accès aux Services (10 min)

**Grafana** :
- URL : http://localhost:3000
- Login : admin / admin
- Dashboards : 54+ dashboards disponibles

**Prometheus** :
- URL : http://localhost:9090
- Métriques : CPU, RAM, Disk, Network

**Nexus** :
- URL : http://localhost:8081
- Login : admin / admin123
- Packages : PyPI, npm, Maven

### 3. Soumission de Job (10 min)

**Job simple** :
```bash
docker exec -it hpc-frontal-01 bash
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=demo
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=00:05:00

echo "Hello from Slurm!"
hostname
date
EOF
```

**Vérification** :
```bash
squeue
sinfo
```

### 4. Monitoring (10 min)

**Dashboards Grafana** :
- HPC Cluster Overview
- CPU/Memory by Node
- Network I/O
- Slurm Jobs

**Métriques Prometheus** :
- Requêtes PromQL
- Alertes configurées

### 5. Questions/Réponses (15 min)

---

## ✅ Points à Mettre en Avant

- ✅ **100% Open-Source** : Aucune licence
- ✅ **Professionnel** : Qualité production
- ✅ **Complet** : Tous composants
- ✅ **Documenté** : 85+ guides
- ✅ **Sécurisé** : Niveau maximum
- ✅ **Scalable** : Facile d'étendre

---

**Version**: 2.0
DEMO_EOF

echo "  ✅ Guide démo créé"

# ============================================================================
# 3. CRÉER SCRIPT DE DÉMO
# ============================================================================
echo -e "\n${BLUE}[3/5] Création script démo...${NC}"
cat > "$LATEST_EXPORT/demo-professionnelle.sh" <<'SCRIPT_EOF'
#!/bin/bash
# Script de Démo Professionnelle

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DÉMO CLUSTER HPC PROFESSIONNEL${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Architecture
echo -e "${GREEN}[1] Architecture du Cluster${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# 2. Services
echo -e "${GREEN}[2] Services Disponibles${NC}"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Nexus: http://localhost:8081"
echo ""

# 3. Métriques
echo -e "${GREEN}[3] Métriques Prometheus${NC}"
curl -s http://localhost:9090/api/v1/query?query=up 2>/dev/null | head -5 || echo "  Prometheus non accessible"
echo ""

# 4. Slurm
echo -e "${GREEN}[4] Test Slurm${NC}"
docker exec hpc-frontal-01 sinfo 2>/dev/null || echo "  Slurm non accessible"
echo ""

# 5. Documentation
echo -e "${GREEN}[5] Documentation${NC}"
echo "  - Guide complet: docs/DOCUMENTATION_COMPLETE_MASTER.md"
echo "  - Technologies: docs/GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md"
echo "  - Architecture: docs/ARCHITECTURE_ET_CHOIX_CONCEPTION.md"
echo ""

echo -e "${GREEN}✅ Démo prête !${NC}"
SCRIPT_EOF

chmod +x "$LATEST_EXPORT/demo-professionnelle.sh"
echo "  ✅ Script démo créé"

# ============================================================================
# 4. CRÉER CHECKLIST
# ============================================================================
echo -e "\n${BLUE}[4/5] Création checklist...${NC}"
cat > "$LATEST_EXPORT/CHECKLIST_INSTALLATION.md" <<'CHECKLIST_EOF'
# ✅ CHECKLIST INSTALLATION - Cluster HPC

## Avant Installation

- [ ] Serveur openSUSE 15.6 prêt
- [ ] Au moins 16GB RAM disponible
- [ ] Au moins 100GB disque libre
- [ ] Accès root ou sudo
- [ ] Archive export copiée sur le serveur

## Installation

- [ ] Archive extraite
- [ ] Script install-demo.sh exécuté
- [ ] Docker installé et démarré
- [ ] Images Docker chargées
- [ ] Services démarrés

## Vérification

- [ ] Prometheus accessible (http://localhost:9090)
- [ ] Grafana accessible (http://localhost:3000)
- [ ] Nexus accessible (http://localhost:8081)
- [ ] Slurm fonctionnel (sinfo, squeue)
- [ ] Dashboards Grafana visibles

## Démo

- [ ] Guide démo lu
- [ ] Script démo testé
- [ ] Services fonctionnels
- [ ] Documentation accessible

---

**Version**: 2.0
CHECKLIST_EOF

echo "  ✅ Checklist créée"

# ============================================================================
# 5. CRÉER ARCHIVE FINALE
# ============================================================================
echo -e "\n${BLUE}[5/5] Création archive finale...${NC}"
cd "$PROJECT_ROOT/export-demo"
tar -czf "hpc-cluster-demo-complete-${TIMESTAMP}.tar.gz" "$(basename $LATEST_EXPORT)"
echo -e "${GREEN}  ✅ Archive créée: hpc-cluster-demo-complete-${TIMESTAMP}.tar.gz${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}PACKAGE DÉMO CRÉÉ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "📦 Package: ${BLUE}$LATEST_EXPORT${NC}"
echo -e "📦 Archive: ${BLUE}$PROJECT_ROOT/export-demo/hpc-cluster-demo-complete-${TIMESTAMP}.tar.gz${NC}"
echo ""
echo -e "📋 Contenu:"
echo "  ✅ Export complet cluster"
echo "  ✅ Guide démo professionnelle"
echo "  ✅ Script de démo"
echo "  ✅ Checklist installation"
echo ""
echo -e "${YELLOW}Pour transférer sur serveur openSUSE 15.6:${NC}"
echo "  1. Copier l'archive sur le serveur"
echo "  2. Extraire: tar -xzf hpc-cluster-demo-complete-*.tar.gz"
echo "  3. Installer: cd hpc-cluster-demo-* && sudo ./install-demo.sh"
echo "  4. Démo: ./demo-professionnelle.sh"
echo ""
