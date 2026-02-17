# 🚀 GUIDE DÉPLOIEMENT HORS LIGNE - Cluster HPC
## Installation sur SUSE 15 SP4 en Environnement Air-Gapped

**Classification**: Guide Déploiement  
**Public**: Administrateurs Système  
**Version**: 2.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Préparation de l'Export](#préparation-de-lexport)
3. [Transfert vers le Serveur](#transfert-vers-le-serveur)
4. [Installation sur SUSE 15 SP4](#installation-sur-suse-15-sp4)
5. [Vérification et Tests](#vérification-et-tests)
6. [Démo Professionnelle](#démo-professionnelle)
7. [Troubleshooting](#troubleshooting)

---

## 1. Vue d'Ensemble

Ce guide explique comment exporter le cluster HPC depuis un environnement avec Internet et l'installer sur un serveur SUSE 15 SP4 **hors ligne** (air-gapped).

### Architecture

```
┌─────────────────────────────────┐
│  Environnement avec Internet    │
│  (Machine de développement)     │
│                                 │
│  1. Export Docker images        │
│  2. Export configurations       │
│  3. Export scripts              │
│  4. Création archive             │
└──────────────┬──────────────────┘
               │
               │ Transfert (USB, réseau local, etc.)
               ▼
┌─────────────────────────────────┐
│  Serveur SUSE 15 SP4            │
│  (Hors ligne / Air-gapped)      │
│                                 │
│  1. Import images Docker         │
│  2. Installation dépendances    │
│  3. Configuration cluster        │
│  4. Démarrage services           │
└─────────────────────────────────┘
```

---

## 2. Préparation de l'Export

### 2.1 Prérequis

Sur la machine avec Internet :
- Docker installé et fonctionnel
- Accès au projet cluster HPC
- Au moins 20GB d'espace disque libre
- Accès root ou sudo

### 2.2 Export Complet (avec images Docker, pour serveur 100 % hors ligne)

Sur une machine **avec Internet** et Docker, pour obtenir une archive contenant les images (démo utilisable sans réseau) :

```bash
cd "cluster hpc"
sudo bash scripts/deployment/export-hors-ligne-complet.sh
```

Ce script télécharge les images du stack open-source puis lance l’export. L’archive générée est dans `export-demo/hpc-cluster-demo-YYYYMMDD-HHMMSS.tar.gz` (plus volumineuse, plusieurs Go).

### 2.2b Export sans téléchargement d’images

Si les images sont déjà présentes localement (ou si le serveur cible aura accès Internet pour les télécharger) :

```bash
cd "cluster hpc"
chmod +x scripts/deployment/export-complete-demo.sh
sudo ./scripts/deployment/export-complete-demo.sh
```

**Ce que fait l’export :**
1. ✅ Exporter les images Docker du stack open-source (si présentes)
2. ✅ Copier toutes les configurations
3. ✅ Copier tous les scripts
4. ✅ Copier toute la documentation
5. ✅ Copier les dashboards Grafana
6. ✅ Créer un script d’installation (`install-demo.sh`)
7. ✅ Créer une archive tar.gz

**Résultat** :
- Dossier : `export-demo/hpc-cluster-demo-YYYYMMDD-HHMMSS/`
- Archive : `export-demo/hpc-cluster-demo-YYYYMMDD-HHMMSS.tar.gz`

### 2.3 Contenu de l'Export

```
hpc-cluster-demo-YYYYMMDD-HHMMSS/
├── docker-images/          # Images Docker (tar.gz)
├── configs/                # Toutes les configurations
├── scripts/                 # Tous les scripts
├── docker/                  # Docker Compose
├── docs/                    # Documentation complète
├── grafana-dashboards/      # Dashboards Grafana
├── install-demo.sh          # Script d'installation
└── README-EXPORT.md         # Instructions
```

---

## 3. Transfert vers le Serveur

### 3.1 Méthodes de Transfert

#### Option 1 : USB / Disque Externe
```bash
# Sur machine source
cp export-demo/hpc-cluster-demo-*.tar.gz /media/usb/

# Sur serveur SUSE 15 SP4
cp /media/usb/hpc-cluster-demo-*.tar.gz /opt/
cd /opt
tar -xzf hpc-cluster-demo-*.tar.gz
```

#### Option 2 : Réseau Local (si disponible)
```bash
# Sur machine source
scp export-demo/hpc-cluster-demo-*.tar.gz user@server-suse:/opt/

# Sur serveur SUSE 15 SP4
cd /opt
tar -xzf hpc-cluster-demo-*.tar.gz
```

#### Option 3 : Partage NFS/SMB
```bash
# Monter le partage sur serveur
mount -t nfs server:/export /mnt
cp /mnt/hpc-cluster-demo-*.tar.gz /opt/
```

### 3.2 Vérification

```bash
# Vérifier l'intégrité de l'archive
tar -tzf hpc-cluster-demo-*.tar.gz | head -20

# Vérifier la taille
du -sh hpc-cluster-demo-*
```

---

## 4. Installation sur SUSE 15 SP4

### 4.1 Prérequis Serveur

- **OS** : SUSE 15 SP4 (ou openSUSE Leap 15.4)
- **RAM** : Minimum 16GB (32GB recommandé)
- **Disque** : Minimum 100GB libre
- **CPU** : Minimum 4 cœurs (8+ recommandé)
- **Réseau** : Non requis (hors ligne)

### 4.2 Docker hors ligne (serveur sans Internet)

Si le serveur **n’a pas Docker** et **n’a pas Internet** :

1. **Sur une machine avec Internet** (SUSE 15 SP4 ou openSUSE Leap 15.4), télécharger les RPM Docker :
   ```bash
   cd "cluster hpc"
   sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh
   ```
   Le dossier **`docker-offline-rpms/`** est rempli avec les `.rpm`. Lancer ensuite l’export complet : les RPM seront inclus dans l’archive.

2. **Sur le serveur hors ligne**, après extraction de l’archive :
   ```bash
   cd hpc-cluster-demo-*
   sudo ./install-docker-offline.sh   # installe Docker depuis docker-offline-rpms/
   sudo ./install-demo.sh
   ```
   Ou lancer directement **`sudo ./install-demo.sh`** : il installera Docker depuis **`docker-offline-rpms/`** s’il contient des RPM.

### 4.3 Installation du cluster

```bash
# 1. Extraire l'archive (si pas déjà fait)
cd /opt
tar -xzf hpc-cluster-demo-*.tar.gz
cd hpc-cluster-demo-*

# 2. (Optionnel) Installer Docker hors ligne si besoin
sudo ./install-docker-offline.sh

# 3. Lancer l'installation
chmod +x install-demo.sh
sudo ./install-demo.sh
```

**Le script install-demo.sh :**
1. ✅ Vérifie SUSE 15 SP4
2. ✅ Installe Docker (depuis docker-offline-rpms/ si présent, sinon zypper)
3. ✅ Charge les images Docker
4. ✅ Installe les dépendances système (zypper si réseau)
5. ✅ Build les images Docker (frontaux, compute)
6. ✅ Démarre le cluster

### 4.4 Installation alternative (script détaillé)

Si vous préférez plus de contrôle :

```bash
# Utiliser le script d'import détaillé
cd /opt/hpc-cluster-demo-*
chmod +x scripts/deployment/import-suse15sp4.sh
sudo ./scripts/deployment/import-suse15sp4.sh
```

---

## 5. Vérification et Tests

### 5.1 Vérification Services

```bash
# Vérifier les conteneurs
docker ps

# Vérifier les services spécifiques
docker ps | grep -E "prometheus|grafana|slurm"

# Vérifier les logs
cd docker
docker-compose -f docker-compose-opensource.yml logs
```

### 5.2 Tests d'Accès

```bash
# Prometheus
curl http://localhost:9090/-/healthy

# Grafana
curl http://localhost:3000/api/health

# Nexus
curl http://localhost:8081/service/rest/v1/status
```

### 5.3 Tests Slurm

```bash
# Se connecter au conteneur frontal
docker exec -it hpc-frontal-01 bash

# Vérifier Slurm
sinfo
squeue

# Tester un job simple
srun hostname
```

---

## 6. Démo Professionnelle

### 6.1 Scénario de Démo

**Objectif** : Démontrer un cluster HPC fonctionnel et professionnel

**Durée** : 30-60 minutes

**Étapes** :

1. **Présentation Architecture** (5 min)
   - Architecture du cluster
   - Technologies utilisées
   - Choix open-source

2. **Accès aux Services** (10 min)
   - Grafana : Dashboards monitoring
   - Prometheus : Métriques
   - Nexus : Gestion packages

3. **Soumission de Job** (10 min)
   - Job Slurm simple
   - Job MPI
   - Visualisation résultats

4. **Monitoring** (10 min)
   - Dashboards Grafana
   - Métriques temps réel
   - Alertes

5. **Questions/Réponses** (15 min)

### 6.2 Script de Démo

Créer un script de démo automatique :

```bash
#!/bin/bash
# demo-professionnelle.sh

echo "=== DÉMO CLUSTER HPC ==="

# 1. Afficher architecture
echo "1. Architecture"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Afficher métriques
echo "2. Métriques Prometheus"
curl -s http://localhost:9090/api/v1/query?query=up | jq

# 3. Soumettre job test
echo "3. Job Slurm test"
docker exec hpc-frontal-01 srun hostname

# 4. Afficher dashboards
echo "4. Dashboards disponibles"
echo "  - Grafana: http://localhost:3000"
echo "  - Prometheus: http://localhost:9090"
```

### 6.3 Points à Mettre en Avant

- ✅ **100% Open-Source** : Aucune licence commerciale
- ✅ **Professionnel** : Qualité production
- ✅ **Complet** : Tous les composants nécessaires
- ✅ **Documenté** : Documentation exhaustive
- ✅ **Scalable** : Facile d'ajouter des nœuds
- ✅ **Sécurisé** : Sécurité niveau maximum

---

## 7. Troubleshooting

### 7.1 Problèmes Courants

#### Docker ne démarre pas
```bash
systemctl status docker
systemctl start docker
systemctl enable docker
```

#### Images Docker manquantes
```bash
# Vérifier les images chargées
docker images

# Si images manquantes, build depuis Dockerfile
cd docker
docker-compose -f docker-compose-opensource.yml build
```

#### Ports déjà utilisés
```bash
# Vérifier les ports
netstat -tulpn | grep -E "9090|3000|8081"

# Modifier les ports dans docker-compose-opensource.yml si nécessaire
```

#### Problèmes de permissions
```bash
# Vérifier permissions Docker
usermod -aG docker $USER
newgrp docker
```

### 7.2 Logs et Debug

```bash
# Logs Docker Compose
cd docker
docker-compose -f docker-compose-opensource.yml logs -f

# Logs d'un service spécifique
docker-compose -f docker-compose-opensource.yml logs prometheus

# Logs système
journalctl -u docker -f
```

### 7.3 Réinitialisation

Si besoin de tout réinitialiser :

```bash
cd docker
docker-compose -f docker-compose-opensource.yml down -v
docker system prune -a
# Puis relancer install-demo.sh
```

---

## 📚 Documentation Complémentaire

- `docs/DOCUMENTATION_COMPLETE_MASTER.md` - Guide complet
- `docs/GUIDE_TROUBLESHOOTING.md` - Troubleshooting détaillé
- `docs/GUIDE_DEBUG_TROUBLESHOOTING.md` - Debug avancé

---

**Version**: 2.0  
**Dernière mise à jour**: 2024
