# 🚀 DÉPLOIEMENT DÉMO COMPLET - Cluster HPC Professionnel
## Package Complet pour Installation Hors Ligne sur SUSE 15 SP4

**Version**: 2.0  
**Date**: 2024  
**Statut**: ✅ **PRÊT POUR PRODUCTION**

---

## 🎯 Vue d'Ensemble

Ce document explique comment créer un package complet pour déployer un cluster HPC professionnel sur un serveur SUSE 15 SP4 **hors ligne** (air-gapped) pour une démo fonctionnelle.

---

## 📦 Ce que Contient le Package

### Images Docker (20+)
- openSUSE Leap 15.4 (base)
- Prometheus, Grafana (monitoring)
- InfluxDB, Telegraf (métriques)
- PostgreSQL, MongoDB, Redis (bases de données)
- Nginx, Nexus (web, packages)
- ELK Stack (logging)
- JupyterHub (notebooks)
- Et 10+ autres...

### Configurations (11+ fichiers)
- `configs/prometheus/prometheus.yml` - Configuration Prometheus
- `configs/prometheus/alerts.yml` - Règles d'alertes
- `configs/grafana/provisioning/` - Provisioning Grafana
- `configs/telegraf/` - Configurations Telegraf
- `configs/slurm/` - Configuration Slurm
- `configs/loki/` - Configuration Loki
- Et autres...

### Scripts (100+)
- Installation applications scientifiques
- Configuration monitoring
- Installation sécurité
- Configuration stockage
- Scripts maintenance
- Et tous les autres...

### Documentation (85+ guides)
- Guide master complet
- Toutes technologies expliquées
- Architecture et choix
- Guides utilisateur, admin, développeur
- Troubleshooting
- Et 70+ autres guides...

### Dashboards Grafana (54+)
- HPC Cluster Overview
- CPU/Memory by Node
- Network I/O
- Slurm Jobs
- Applications
- Sécurité
- Et 40+ autres...

---

## 🚀 Processus Complet

### Étape 1 : Créer le Package (Machine avec Internet)

```bash
# Aller dans le projet
cd "cluster hpc"

# Créer le package complet
chmod +x scripts/deployment/create-demo-package.sh
./scripts/deployment/create-demo-package.sh
```

**Durée** : 15-30 minutes (selon nombre d'images Docker)

**Résultat** :
- Dossier : `export-demo/hpc-cluster-demo-YYYYMMDD-HHMMSS/`
- Archive : `export-demo/hpc-cluster-demo-complete-YYYYMMDD-HHMMSS.tar.gz`
- Taille : ~5-10GB (selon images)

### Étape 2 : Vérifier l'Export

```bash
# Vérifier l'export
chmod +x scripts/deployment/verify-export.sh
./scripts/deployment/verify-export.sh
```

### Étape 3 : Transférer sur Serveur SUSE 15 SP4

**Méthodes** :
- USB / Disque externe
- Réseau local (scp, rsync)
- Partage NFS/SMB
- Autre méthode de transfert

```bash
# Exemple : USB
cp export-demo/hpc-cluster-demo-complete-*.tar.gz /media/usb/

# Exemple : Réseau local
scp export-demo/hpc-cluster-demo-complete-*.tar.gz user@server-suse:/opt/
```

### Étape 4 : Préparer le Serveur (Optionnel mais Recommandé)

```bash
# Sur le serveur SUSE 15 SP4
# Copier le script de préparation
scp scripts/deployment/prepare-suse15sp4.sh user@server:/tmp/

# Exécuter
ssh user@server
sudo /tmp/prepare-suse15sp4.sh
```

**Ce script va** :
- Vérifier les ressources système
- Installer Docker
- Installer les dépendances
- Configurer le système
- Créer les répertoires

### Étape 5 : Installation sur Serveur

```bash
# Sur le serveur SUSE 15 SP4
cd /opt
tar -xzf hpc-cluster-demo-complete-*.tar.gz
cd hpc-cluster-demo-*

# Installation automatique
sudo ./install-demo.sh
```

**Durée** : 20-40 minutes

**Le script va** :
1. Vérifier SUSE 15 SP4
2. Installer Docker (si nécessaire)
3. Charger les images Docker
4. Installer les dépendances système
5. Configurer les réseaux Docker
6. Build les images Docker
7. Démarrer le cluster

### Étape 6 : Vérification

```bash
# Vérifier les conteneurs
docker ps

# Vérifier les services
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3000/api/health  # Grafana

# Vérifier Slurm
docker exec hpc-frontal-01 sinfo
```

### Étape 7 : Démo

```bash
# Lancer le script de démo
./demo-professionnelle.sh

# Accéder aux services
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
# Nexus: http://localhost:8081 (admin/admin123)
```

---

## 📊 Structure du Package

```
hpc-cluster-demo-YYYYMMDD-HHMMSS/
├── docker-images/              # Images Docker (tar.gz)
│   ├── opensuse_leap_15.4.tar.gz
│   ├── prom_prometheus_v2.48.0.tar.gz
│   ├── grafana_grafana_10.2.0.tar.gz
│   └── ... (20+ images)
│
├── configs/                    # Configurations
│   ├── prometheus/
│   ├── grafana/
│   ├── telegraf/
│   ├── slurm/
│   └── ...
│
├── scripts/                    # Scripts (100+)
│   ├── applications/
│   ├── monitoring/
│   ├── security/
│   ├── storage/
│   └── ...
│
├── docker/                     # Docker Compose
│   ├── docker-compose-opensource.yml
│   ├── frontal/Dockerfile
│   └── client/Dockerfile
│
├── docs/                       # Documentation (85+ guides)
│   ├── DOCUMENTATION_COMPLETE_MASTER.md
│   ├── GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md
│   └── ... (80+ autres guides)
│
├── grafana-dashboards/         # Dashboards Grafana (54+)
│   ├── hpc-cluster-overview.json
│   ├── cpu-memory-by-node.json
│   └── ... (50+ autres)
│
├── install-demo.sh             # Script installation
├── demo-professionnelle.sh     # Script démo
├── GUIDE_DEMO.md               # Guide démo
├── CHECKLIST_INSTALLATION.md   # Checklist
└── README-EXPORT.md            # Instructions
```

---

## ✅ Prérequis Serveur SUSE 15 SP4

### Minimum
- **OS** : SUSE 15 SP4 ou openSUSE Leap 15.4
- **RAM** : 16GB
- **Disque** : 100GB libre
- **CPU** : 4 cœurs

### Recommandé
- **RAM** : 32GB+
- **Disque** : 200GB+ libre
- **CPU** : 8+ cœurs
- **Réseau** : Non requis (hors ligne)

---

## 🎯 Scénario de Démo

### Durée : 30-60 minutes

1. **Présentation** (5 min)
   - Architecture
   - Technologies
   - Avantages open-source

2. **Accès Services** (10 min)
   - Grafana (dashboards)
   - Prometheus (métriques)
   - Nexus (packages)

3. **Soumission Job** (10 min)
   - Job Slurm simple
   - Job MPI
   - Visualisation

4. **Monitoring** (10 min)
   - Dashboards Grafana
   - Métriques temps réel
   - Alertes

5. **Questions/Réponses** (15 min)

Voir `GUIDE_DEMO.md` pour le scénario détaillé.

---

## 🆘 Troubleshooting

### Problèmes Courants

#### Docker ne démarre pas
```bash
systemctl status docker
systemctl start docker
systemctl enable docker
```

#### Images Docker manquantes
```bash
# Build depuis Dockerfile
cd docker
docker-compose -f docker-compose-opensource.yml build
```

#### Ports déjà utilisés
```bash
# Vérifier ports
netstat -tulpn | grep -E "9090|3000|8081"

# Modifier ports dans docker-compose-opensource.yml si nécessaire
```

Voir `docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md` section Troubleshooting pour plus de détails.

---

## 📚 Documentation

### Guides Principaux
- `GUIDE_RAPIDE_DEMO.md` - Guide rapide
- `docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md` - Guide complet
- `README_DEPLOIEMENT_DEMO.md` - Instructions

### Documentation Complète
- `docs/DOCUMENTATION_COMPLETE_MASTER.md` - Guide master
- `docs/GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md` - Technologies
- `docs/ARCHITECTURE_ET_CHOIX_CONCEPTION.md` - Architecture

---

## ✅ Garanties

- ✅ **100% Open-Source** : Aucune licence commerciale
- ✅ **Fonctionnel** : Tous services opérationnels
- ✅ **Professionnel** : Qualité production
- ✅ **Complet** : Tous composants nécessaires
- ✅ **Documenté** : Documentation exhaustive
- ✅ **Testé** : Vérifié et validé

---

## 🎯 Résultat Final

Après installation, vous aurez :

- ✅ **Cluster HPC fonctionnel** : 2 frontaux + 6 compute
- ✅ **Monitoring complet** : Prometheus + Grafana (54+ dashboards)
- ✅ **Applications scientifiques** : GROMACS, OpenFOAM, Quantum ESPRESSO, etc.
- ✅ **Stockage parallèle** : BeeGFS configuré
- ✅ **Scheduler** : Slurm opérationnel
- ✅ **Authentification** : LDAP + Kerberos
- ✅ **Documentation** : 85+ guides complets

**Prêt pour une démo professionnelle !**

---

**Version**: 2.0  
**Date**: 2024  
**Statut**: ✅ **PRÊT POUR DÉMO PROFESSIONNELLE**
