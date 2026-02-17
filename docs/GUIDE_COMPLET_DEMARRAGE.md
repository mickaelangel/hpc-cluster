# Guide Complet de Démarrage - Cluster HPC
## Pour Débutants : Tout Comprendre du Cluster HPC

**Classification**: Documentation Pédagogique  
**Public**: Débutants / Non-experts HPC  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Qu'est-ce qu'un Cluster HPC ?](#quest-ce-quun-cluster-hpc)
2. [Architecture du Cluster](#architecture-du-cluster)
3. [Composants Principaux](#composants-principaux)
4. [Installation Complète](#installation-complète)
5. [Premiers Pas](#premiers-pas)
6. [Utilisation de Base](#utilisation-de-base)

---

## 🎯 Qu'est-ce qu'un Cluster HPC ?

### Définition Simple

Un **Cluster HPC** (High Performance Computing) est un ensemble d'ordinateurs connectés ensemble qui travaillent comme un seul super-ordinateur pour résoudre des problèmes complexes nécessitant beaucoup de calculs.

### Analogie Simple

Imaginez :
- **Un ordinateur seul** = Un ouvrier qui travaille seul
- **Un Cluster HPC** = Une équipe d'ouvriers qui travaillent ensemble sur un grand projet

### Pourquoi Utiliser un Cluster HPC ?

- ✅ **Calculs complexes** : Simulations, modélisations, analyses de données
- ✅ **Temps de calcul réduit** : Plusieurs ordinateurs = calculs plus rapides
- ✅ **Ressources partagées** : Plusieurs utilisateurs peuvent utiliser le cluster
- ✅ **Économies** : Meilleur rapport qualité/prix qu'un super-ordinateur unique

---

## 🏗️ Architecture du Cluster

### Vue d'Ensemble Simple

```
┌─────────────────────────────────────────┐
│         NŒUDS FRONTAUX (2)              │
│  ┌──────────┐  ┌──────────┐            │
│  │ Frontal-01│  │ Frontal-02│           │
│  │ (Gestion) │  │ (Backup)  │           │
│  └──────────┘  └──────────┘            │
└─────────────────────────────────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
┌───▼───┐ ┌───▼───┐ ┌───▼───┐
│Node-01│ │Node-02│ │Node-06│
│(Calcul)│ │(Calcul)│ │(Calcul)│
└───────┘ └───────┘ └───────┘
```

### Rôles des Nœuds

**Nœuds Frontaux (2)** :
- **Gestion** : Authentification, stockage, monitoring
- **Coordination** : Distribution des travaux

**Nœuds de Calcul (6)** :
- **Calculs** : Exécution des jobs
- **Parallélisation** : Travail en équipe

---

## 🔧 Composants Principaux

### 1. Slurm - Gestionnaire de Jobs

**Qu'est-ce que c'est ?**
- Système qui distribue les travaux aux nœuds
- Comme un chef d'équipe qui assigne les tâches

**Pourquoi ?**
- Évite que les nœuds travaillent sur la même chose
- Partage équitable des ressources
- Gère la file d'attente des travaux

**Comment ça marche ?**
```
Utilisateur soumet un job
    │
    ▼
Slurm vérifie les ressources disponibles
    │
    ▼
Slurm assigne le job à un nœud libre
    │
    ▼
Le nœud exécute le job
```

---

### 2. BeeGFS - Système de Fichiers Partagé

**Qu'est-ce que c'est ?**
- Système de fichiers partagé entre tous les nœuds
- Comme un disque dur partagé accessible par tous

**Pourquoi ?**
- Tous les nœuds voient les mêmes fichiers
- Pas besoin de copier les fichiers sur chaque nœud
- Performance élevée pour HPC

**Comment ça marche ?**
```
Fichier sur BeeGFS
    │
    ├─► Accessible depuis Frontal-01
    ├─► Accessible depuis Node-01
    ├─► Accessible depuis Node-02
    └─► Accessible depuis tous les nœuds
```

---

### 3. LDAP / FreeIPA - Authentification

**Qu'est-ce que c'est ?**
- Système d'authentification centralisé
- Un seul compte pour accéder à tout le cluster

**Pourquoi ?**
- Pas besoin de créer un compte sur chaque nœud
- Gestion centralisée des utilisateurs
- Sécurité renforcée

**Comment ça marche ?**
```
Utilisateur se connecte
    │
    ▼
Vérification dans LDAP/FreeIPA
    │
    ├─► OK → Accès autorisé
    └─► NOK → Accès refusé
```

---

### 4. Prometheus + Grafana - Monitoring

**Qu'est-ce que c'est ?**
- Système de surveillance du cluster
- Tableaux de bord pour voir l'état du cluster

**Pourquoi ?**
- Voir l'utilisation des ressources
- Détecter les problèmes
- Optimiser les performances

**Ce qu'on peut voir :**
- Utilisation CPU par nœud
- Utilisation mémoire
- Jobs en cours
- État des nœuds

---

### 5. Applications Scientifiques

**GROMACS** - Simulation Moléculaire
- Simule le comportement des molécules
- Utilisé en biologie, chimie

**OpenFOAM** - Mécanique des Fluides
- Simule les écoulements de fluides
- Utilisé en aérodynamique, hydrodynamique

**Quantum ESPRESSO** - Calculs Quantiques
- Calculs de structure électronique
- Utilisé en physique, chimie quantique

**ParaView** - Visualisation
- Visualise les résultats de simulations
- Crée des graphiques 3D

---

## 🚀 Installation Complète

### Prérequis

- **Système** : SUSE 15 SP4
- **Docker** : Version 20.10+
- **Docker Compose** : Version 2.0+
- **Espace disque** : 50GB+ minimum
- **RAM** : 16GB+ recommandé

### Installation Étape par Étape

#### 1. Préparation

```bash
# Vérifier Docker
docker --version
docker-compose --version

# Créer répertoire
mkdir -p /opt/hpc-cluster
cd /opt/hpc-cluster
```

#### 2. Copier les Fichiers

```bash
# Copier tout le projet
cp -r /chemin/vers/cluster\ hpc/* .
```

#### 3. Installation Docker Compose

```bash
cd docker
docker-compose build
docker-compose up -d
```

#### 4. Vérification

```bash
# Vérifier les conteneurs
docker-compose ps

# Vérifier les services
docker-compose logs
```

---

## 🎓 Premiers Pas

### 1. Se Connecter au Cluster

```bash
# Se connecter au nœud frontal
ssh user@frontal-01

# Vérifier l'accès
hostname
whoami
```

### 2. Voir l'État du Cluster

```bash
# Voir les nœuds disponibles
sinfo

# Voir les jobs en cours
squeue

# Voir l'utilisation
sinfo -N -l
```

### 3. Soumettre un Premier Job

```bash
# Créer un script simple
cat > mon_premier_job.sh <<EOF
#!/bin/bash
#SBATCH --job-name=test
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1

echo "Bonjour depuis le cluster HPC !"
echo "Je suis sur le nœud: $(hostname)"
date
EOF

# Soumettre le job
sbatch mon_premier_job.sh

# Voir le statut
squeue -u $USER
```

---

## 📖 Utilisation de Base

### Commandes Slurm Essentielles

```bash
# Soumettre un job
sbatch mon_script.sh

# Voir mes jobs
squeue -u $USER

# Annuler un job
scancel JOB_ID

# Voir les détails d'un job
scontrol show job JOB_ID

# Voir l'historique
sacct -u $USER
```

### Gestion des Fichiers

```bash
# Voir l'espace disponible
df -h /mnt/beegfs

# Voir mon quota
beegfs-ctl --getquota --uid $USER

# Copier des fichiers
cp fichier_local /mnt/beegfs/home/$USER/
```

---

## 🔍 Ressources

### Documentation Complète

- `docs/GUIDE_UTILISATEUR.md` - Guide utilisateur détaillé
- `docs/TECHNOLOGIES_CLUSTER.md` - Technologies expliquées
- `docs/GUIDE_LANCEMENT_JOBS.md` - Comment lancer des jobs

### Support

- Documentation officielle de chaque outil
- Forums communautaires
- Logs du cluster : `/var/log/`

---

## ✅ Checklist de Démarrage

- [ ] Docker installé et fonctionnel
- [ ] Docker Compose installé
- [ ] Projet copié sur le serveur
- [ ] Conteneurs démarrés
- [ ] Accès SSH au cluster
- [ ] Premier job soumis avec succès
- [ ] Monitoring accessible (Grafana)

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
