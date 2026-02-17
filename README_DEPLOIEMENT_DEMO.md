# 🚀 DÉPLOIEMENT DÉMO - Cluster HPC Professionnel
## Guide Complet pour Installation Hors Ligne sur SUSE 15 SP4

**Version**: 2.0  
**Date**: 2024

---

## 🎯 Objectif

Créer un package complet pour déployer un cluster HPC professionnel sur un serveur SUSE 15 SP4 **hors ligne** (air-gapped) pour une démo fonctionnelle.

---

## 📦 Création du Package

### Sur Machine avec Internet

```bash
cd "cluster hpc"

# Créer le package complet
chmod +x scripts/deployment/create-demo-package.sh
./scripts/deployment/create-demo-package.sh
```

**Résultat** :
- Dossier : `export-demo/hpc-cluster-demo-YYYYMMDD-HHMMSS/`
- Archive : `export-demo/hpc-cluster-demo-complete-YYYYMMDD-HHMMSS.tar.gz`

---

## 📋 Contenu du Package

```
hpc-cluster-demo-YYYYMMDD-HHMMSS/
├── docker-images/              # Images Docker (20+ images)
├── configs/                    # Toutes configurations
├── scripts/                    # Tous scripts (100+)
├── docker/                     # Docker Compose
├── docs/                       # Documentation complète (85+ guides)
├── grafana-dashboards/         # Dashboards Grafana (54+)
├── install-demo.sh             # Script installation
├── demo-professionnelle.sh     # Script démo
├── GUIDE_DEMO.md               # Guide démo
├── CHECKLIST_INSTALLATION.md   # Checklist
└── README-EXPORT.md            # Instructions
```

---

## 🚀 Installation sur SUSE 15 SP4

### 1. Transfert

```bash
# Copier l'archive sur le serveur (USB, réseau local, etc.)
scp hpc-cluster-demo-complete-*.tar.gz user@server-suse:/opt/
```

### 2. Extraction

```bash
# Sur le serveur SUSE 15 SP4
cd /opt
tar -xzf hpc-cluster-demo-complete-*.tar.gz
cd hpc-cluster-demo-*
```

### 3. Installation

```bash
# Installation automatique
sudo ./install-demo.sh
```

**Le script va :**
- ✅ Installer Docker
- ✅ Charger les images Docker
- ✅ Installer les dépendances
- ✅ Configurer le cluster
- ✅ Démarrer les services

### 4. Vérification

```bash
# Vérifier les services
docker ps

# Tester l'accès
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3000/api/health  # Grafana
```

---

## 🎯 Démo Professionnelle

### Lancer la Démo

```bash
./demo-professionnelle.sh
```

### Accès aux Services

- **Grafana** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090
- **Nexus** : http://localhost:8081 (admin/admin123)

### Scénario de Démo

Voir `GUIDE_DEMO.md` pour le scénario complet.

---

## ✅ Checklist

Voir `CHECKLIST_INSTALLATION.md` pour la checklist complète.

---

## 📚 Documentation

Toute la documentation est dans `docs/` :

- `docs/DOCUMENTATION_COMPLETE_MASTER.md` - Guide complet
- `docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md` - Déploiement hors ligne
- `docs/GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md` - Toutes technologies

---

## 🆘 Support

En cas de problème :
- `docs/GUIDE_TROUBLESHOOTING.md`
- `docs/GUIDE_DEBUG_TROUBLESHOOTING.md`

---

**Version**: 2.0  
**Date**: 2024
