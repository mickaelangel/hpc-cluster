# 📚 DOCUMENTATION COMPLÈTE MASTER - Cluster HPC
## Guide Exhaustif : Technologies, Logiciels, Architecture et Choix de Conception

**Classification**: Documentation Technique Complète  
**Public**: Tous Niveaux (Débutants à Experts)  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Introduction et Vue d'Ensemble](#1-introduction-et-vue-densemble)
2. [Architecture Complète du Cluster](#2-architecture-complète-du-cluster)
3. [Technologies de Base - Explications Détaillées](#3-technologies-de-base)
4. [Logiciels et Applications - Guide Complet](#4-logiciels-et-applications)
5. [Choix de Conception et Justifications](#5-choix-de-conception)
6. [Structure du Projet - Organisation](#6-structure-du-projet)
7. [Comment Tout Fonctionne Ensemble](#7-fonctionnement-global)
8. [Guide d'Utilisation de Chaque Logiciel](#8-guide-utilisation-logiciels)
9. [Maintenance et Opérations](#9-maintenance)
10. [Monitoring et Dashboards](#10-monitoring)

---

## 1. Introduction et Vue d'Ensemble

### 1.1 Qu'est-ce qu'un Cluster HPC ?

Un **Cluster HPC (High-Performance Computing)** est un ensemble de serveurs interconnectés qui travaillent ensemble pour résoudre des problèmes de calcul complexes nécessitant une grande puissance de traitement.

**Caractéristiques** :
- **Parallélisme** : Calculs distribués sur plusieurs nœuds
- **Haute Performance** : Optimisé pour calculs intensifs
- **Scalabilité** : Peut s'étendre à des milliers de nœuds
- **Fiabilité** : Redondance et haute disponibilité

### 1.2 Objectif de ce Projet

**Mission** : Créer un cluster HPC complet, **100% open-source**, portable via Docker, prêt pour déploiement sur **openSUSE 15.6**, avec toutes les fonctionnalités nécessaires pour un environnement de production.

**Contraintes** :
- ✅ **100% Open-Source** : Aucune licence commerciale
- ✅ **Portable** : Docker, fonctionne partout
- ✅ **Production-Ready** : Sécurité, monitoring, maintenance
- ✅ **Complet** : Tous les composants nécessaires

---

## 2. Architecture Complète du Cluster

### 2.1 Architecture Générale

```
┌─────────────────────────────────────────────────────────────────┐
│                    COUCHE MANAGEMENT                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  LDAP    │  │ Kerberos │  │Prometheus│  │  Grafana │         │
│  │ (389DS)  │  │   KDC    │  │          │  │          │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Slurm  │  │  BeeGFS  │  │  Nexus   │  │  X2Go    │         │
│  │  CTLD   │  │   MGMtd  │  │ (PyPI)   │  │ (Remote) │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  Compute-01  │  │  Compute-02  │  │  Compute-06  │
│  (SlurmD)    │  │  (SlurmD)    │  │  (SlurmD)    │
│  + BeeGFS    │  │  + BeeGFS    │  │  + BeeGFS    │
│  + Spack     │  │  + Spack     │  │  + Spack     │
│  + Apps      │  │  + Apps      │  │  + Apps      │
└──────────────┘  └──────────────┘  └──────────────┘
```

### 2.2 Composants Principaux

#### Nœuds Frontaux (2)
- **frontal-01** : Services principaux (LDAP, Kerberos, SlurmCTLD, BeeGFS MGMtd)
- **frontal-02** : Services secondaires (réplication, haute disponibilité)

#### Nœuds de Calcul (6)
- **compute-01 à compute-06** : Exécution des jobs HPC

#### Réseaux (4)
- **Management (172.20.0.0/24)** : SSH, LDAP, Kerberos, Slurm
- **Cluster (10.0.0.0/24)** : Communication MPI
- **Storage (10.10.10.0/24)** : BeeGFS, stockage haute performance
- **Monitoring (192.168.200.0/24)** : Prometheus, Grafana

---

## 3. Technologies de Base - Explications Détaillées

### 3.1 Docker et Docker Compose

#### Qu'est-ce que c'est ?

**Docker** est une plateforme de conteneurisation qui permet d'empaqueter une application et ses dépendances dans un conteneur isolé.

**Docker Compose** est un outil pour définir et orchestrer plusieurs conteneurs Docker.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Portabilité** : Fonctionne identiquement sur n'importe quel système
- ✅ **Isolation** : Chaque service dans son conteneur
- ✅ **Reproductibilité** : Même environnement partout
- ✅ **Facilité** : Un seul fichier `docker-compose.yml` pour tout
- ✅ **Air-gapped** : Peut fonctionner sans Internet (images exportées)

**Alternatives considérées** :
- ❌ **VMware/KVM** : Trop lourd, nécessite hyperviseur
- ❌ **LXC** : Moins standardisé, moins d'outils
- ❌ **Installation native** : Difficile à reproduire, dépendances complexes

**Pourquoi Docker a été choisi** :
- Standard de l'industrie
- Large écosystème
- Facile à apprendre
- Compatible openSUSE 15.6

#### Comment ça fonctionne ?

```
Docker Engine
    │
    ├─► Conteneur frontal-01
    │   ├─► openSUSE Leap 15.6
    │   ├─► SlurmCTLD
    │   ├─► LDAP
    │   └─► Services système
    │
    ├─► Conteneur compute-01
    │   ├─► openSUSE Leap 15.6
    │   ├─► SlurmD
    │   ├─► BeeGFS Client
    │   └─► Applications HPC
    │
    └─► Conteneur Prometheus
        ├─► Image Prometheus
        └─► Configuration
```

**Fichiers** :
- `docker/frontal/Dockerfile` : Image pour nœuds frontaux
- `docker/client/Dockerfile` : Image pour nœuds de calcul
- `docker/docker-compose-opensource.yml` : Orchestration complète

**Utilisation** :
```bash
# Build
cd docker/
docker-compose -f docker-compose-opensource.yml build

# Démarrage
docker-compose -f docker-compose-opensource.yml up -d

# Arrêt
docker-compose -f docker-compose-opensource.yml down
```

---

### 3.2 Slurm (Workload Manager)

#### Qu'est-ce que c'est ?

**Slurm** (Simple Linux Utility for Resource Management) est un gestionnaire de jobs et de ressources pour clusters HPC.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard HPC** : Utilisé par 60%+ des clusters mondiaux
- ✅ **Gestion ressources** : CPU, mémoire, GPU, partitions
- ✅ **File d'attente intelligente** : Priorité, backfill, preemption
- ✅ **Multi-utilisateurs** : Partage équitable des ressources
- ✅ **Open-source** : Gratuit, communauté active

**Alternatives considérées** :
- ❌ **PBS/Torque** : Moins moderne, moins de fonctionnalités
- ❌ **LSF** : Commercial, licence coûteuse
- ❌ **SGE** : Moins maintenu, communauté réduite

**Pourquoi Slurm a été choisi** :
- Standard de facto pour HPC
- Très bien documenté
- Performant et fiable
- Supporte toutes les fonctionnalités nécessaires

#### Comment ça fonctionne ?

```
Utilisateur soumet un job
    │
    ├─► sbatch job.sh
    │
    ▼
SlurmCTLD (Controller)
    │
    ├─► Vérifie ressources disponibles
    ├─► Place dans file d'attente
    ├─► Calcule priorité
    └─► Lance sur nœuds disponibles
        │
        ▼
    SlurmD (Daemon sur chaque nœud)
        │
        ├─► Alloue ressources (CPU, RAM)
        ├─► Lance le job
        └─► Collecte métriques
```

**Composants** :
- **SlurmCTLD** : Contrôleur (frontal-01)
- **SlurmDBD** : Base de données des jobs
- **SlurmD** : Daemon sur chaque nœud de calcul

**Fichiers de configuration** :
- `configs/slurm/slurm.conf` : Configuration principale
- `configs/slurm/cgroup.conf` : Gestion des ressources (cgroups)

**Utilisation** :
```bash
# Soumettre un job
sbatch job.sh

# Voir les jobs
squeue

# Voir les nœuds
sinfo

# Annuler un job
scancel JOBID
```

---

### 3.3 BeeGFS (Système de Fichiers Parallèle)

#### Qu'est-ce que c'est ?

**BeeGFS** (formerly FhGFS) est un système de fichiers parallèle open-source optimisé pour HPC.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Performance** : Très rapide pour HPC (I/O parallèle)
- ✅ **Scalabilité** : Supporte des milliers de nœuds
- ✅ **Open-source** : Gratuit, pas de licence
- ✅ **Facilité** : Plus simple que Lustre
- ✅ **Flexibilité** : Peut démarrer petit et grandir

**Alternatives considérées** :
- ❌ **GPFS (IBM Spectrum Scale)** : Commercial, licence coûteuse
- ❌ **Lustre** : Plus complexe, nécessite plus de ressources
- ❌ **GlusterFS** : Moins performant pour HPC
- ❌ **NFS** : Trop lent pour HPC

**Pourquoi BeeGFS a été choisi** :
- Meilleur compromis performance/facilité
- Open-source pur
- Bien documenté
- Communauté active

#### Comment ça fonctionne ?

```
Application (sur compute-01)
    │
    ├─► Écriture fichier
    │
    ▼
BeeGFS Client
    │
    ├─► Contacte MGMtd (métadonnées)
    │   └─► Obtient localisation
    │
    ├─► Écrit directement sur Storage Targets
    │   ├─► Target 1 (frontal-01)
    │   ├─► Target 2 (frontal-02)
    │   └─► Stripe parallèle
    │
    └─► Performance élevée (I/O parallèle)
```

**Composants** :
- **MGMtd** : Gestionnaire de métadonnées (frontal-01)
- **Storage Targets** : Stockage des données (frontal-01, frontal-02)
- **Client** : Sur chaque nœud (compute-01 à compute-06)

**Installation** :
```bash
./scripts/storage/install-beegfs.sh
```

**Utilisation** :
```bash
# Monter BeeGFS
mount -t beegfs /mnt/beegfs

# Vérifier
df -h /mnt/beegfs
```

---

### 3.4 LDAP (389 Directory Server)

#### Qu'est-ce que c'est ?

**LDAP** (Lightweight Directory Access Protocol) est un protocole d'accès à un annuaire distribué. **389 Directory Server** est l'implémentation open-source.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Authentification centralisée** : Un seul point d'authentification
- ✅ **Gestion utilisateurs** : Création/modification centralisée
- ✅ **Standards** : Protocole standardisé (RFC 4510)
- ✅ **Intégration** : Compatible avec tout (SSH, Slurm, etc.)

**Alternatives considérées** :
- ❌ **Fichiers locaux (/etc/passwd)** : Non scalable, pas centralisé
- ❌ **Active Directory** : Commercial, Windows-centric
- ❌ **FreeIPA** : Plus complexe, peut être overkill

**Pourquoi LDAP a été choisi** :
- Standard de l'industrie
- Simple et efficace
- Compatible avec tout
- Open-source

#### Comment ça fonctionne ?

```
Client (SSH, Slurm, etc.)
    │
    │ Requête LDAP (port 389)
    │ "Vérifier utilisateur jdoe / password"
    ▼
389 Directory Server
    │
    │ Recherche dans base LDAP
    │ dc=cluster,dc=local
    │   └─► ou=users
    │       └─► uid=jdoe
    │
    ├─► Vérifie password (hash)
    │
    └─► Retourne : OK / NOK
```

**Structure LDAP** :
```
dc=cluster,dc=local
├── ou=users
│   ├── uid=jdoe,ou=users,dc=cluster,dc=local
│   │   ├── cn: John Doe
│   │   ├── userPassword: {SSHA}...
│   │   ├── uidNumber: 1001
│   │   └── homeDirectory: /home/jdoe
│   └── ...
├── ou=groups
│   ├── cn=hpc-users,ou=groups,dc=cluster,dc=local
│   └── cn=admins,ou=groups,dc=cluster,dc=local
└── ou=computers
    └── cn=node-01,ou=computers,dc=cluster,dc=local
```

**Installation** :
```bash
./scripts/install-ldap-kerberos.sh
```

**Utilisation** :
```bash
# Créer un utilisateur
ldapadd -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
uid: jdoe
cn: John Doe
userPassword: {SSHA}encrypted
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
EOF

# Rechercher
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"
```

---

### 3.5 Kerberos

#### Qu'est-ce que c'est ?

**Kerberos** est un protocole d'authentification réseau sécurisé basé sur des tickets cryptographiques.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Sécurité** : Pas de mots de passe en clair sur le réseau
- ✅ **SSO** : Authentification unique (Single Sign-On)
- ✅ **Standards** : Protocole standardisé (RFC 4120)
- ✅ **Intégration** : Compatible avec LDAP, SSH, NFS

**Alternatives considérées** :
- ❌ **Mots de passe en clair** : Non sécurisé
- ❌ **Certificats uniquement** : Plus complexe à gérer
- ❌ **OAuth/SAML** : Overkill pour HPC

**Pourquoi Kerberos a été choisi** :
- Standard pour environnements enterprise
- Sécurisé par défaut
- SSO intégré
- Compatible avec tout

#### Comment ça fonctionne ?

```
1. Client demande un ticket
   Client ──► KDC (Key Distribution Center)
              Port 88
   
2. KDC vérifie l'identité (via LDAP)
   KDC ──► LDAP (vérification)
   
3. KDC émet un TGT (Ticket Granting Ticket)
   KDC ──► Client (TGT chiffré)
   
4. Client utilise le TGT pour obtenir un service ticket
   Client ──► KDC (avec TGT)
   KDC ──► Client (Service Ticket)
   
5. Client présente le service ticket au service
   Client ──► SSH/NFS/etc. (avec Service Ticket)
   Service ──► OK (authentifié)
```

**Composants** :
- **KDC** : Key Distribution Center (frontal-01)
- **Realm** : Domaine Kerberos (CLUSTER.LOCAL)
- **Principal** : Identité (jdoe@CLUSTER.LOCAL)
- **Ticket** : Token d'authentification temporaire (24h par défaut)

**Installation** :
```bash
./scripts/install-ldap-kerberos.sh
```

**Utilisation** :
```bash
# Obtenir un ticket
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe

# Vérifier
klist

# SSH sans mot de passe (si ticket valide)
ssh jdoe@node-01
```

---

### 3.6 Prometheus (Monitoring)

#### Qu'est-ce que c'est ?

**Prometheus** est un système de monitoring et d'alerting open-source.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Pull-based** : Collecte active des métriques
- ✅ **Time-series** : Base de données optimisée pour séries temporelles
- ✅ **PromQL** : Langage de requête puissant
- ✅ **Alerting** : Système d'alertes intégré
- ✅ **Open-source** : Gratuit, communauté énorme

**Alternatives considérées** :
- ❌ **Nagios** : Plus ancien, moins moderne
- ❌ **Zabbix** : Plus complexe, interface moins intuitive
- ❌ **Datadog/New Relic** : Commercial, coûteux

**Pourquoi Prometheus a été choisi** :
- Standard de facto pour monitoring moderne
- Très performant
- Excellent pour métriques time-series
- Écosystème énorme (exporters)

#### Comment ça fonctionne ?

```
Prometheus Server
    │
    ├─► Scrape (toutes les 15s)
    │   ├─► Node Exporter (port 9100)
    │   │   └─► Métriques système (CPU, RAM, Disk)
    │   │
    │   ├─► Telegraf (port 9273)
    │   │   └─► Métriques applicatives
    │   │
    │   └─► Slurm Exporter
    │       └─► Métriques Slurm (jobs, partitions)
    │
    ├─► Stockage (TSDB)
    │   └─► Rétention 30 jours
    │
    └─► Alerting
        └─► Règles d'alerte (CPU > 80%, etc.)
```

**Configuration** :
- `configs/prometheus/prometheus.yml` : Configuration scraping
- `configs/prometheus/alerts.yml` : Règles d'alertes

**Utilisation** :
```bash
# Accès web
http://localhost:9090

# Requête PromQL
up{job="frontal-01-node"}
node_cpu_seconds_total{mode="idle"}
```

---

### 3.7 Grafana (Visualisation)

#### Qu'est-ce que c'est ?

**Grafana** est une plateforme de visualisation et d'analyse de métriques.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Dashboards** : Visualisation graphique des métriques
- ✅ **Multi-sources** : Prometheus, InfluxDB, etc.
- ✅ **Alerting** : Alertes visuelles
- ✅ **Templates** : Dashboards pré-configurés
- ✅ **Open-source** : Gratuit

**Alternatives considérées** :
- ❌ **Kibana** : Principalement pour logs (ELK)
- ❌ **Custom HTML** : Trop de travail
- ❌ **Tableaux de bord propriétaires** : Coûteux

**Pourquoi Grafana a été choisi** :
- Standard pour visualisation métriques
- Interface intuitive
- Large communauté de dashboards
- Intégration native avec Prometheus

#### Comment ça fonctionne ?

```
Grafana Server
    │
    ├─► Datasource : Prometheus
    │   └─► http://172.20.0.10:9090
    │
    ├─► Dashboards
    │   ├─► HPC Cluster Overview
    │   ├─► CPU/Memory by Node
    │   ├─► Network I/O
    │   ├─► Slurm Jobs
    │   └─► 50+ autres dashboards
    │
    └─► Alerting
        └─► Notifications (email, webhook)
```

**Dashboards** :
- `grafana-dashboards/` : 54+ dashboards JSON
- Auto-provisioning via `configs/grafana/provisioning/`

**Utilisation** :
```bash
# Accès web
http://localhost:3000
# Login: admin / admin

# Dashboards disponibles
# - HPC Cluster Overview
# - CPU/Memory by Node
# - Network I/O
# - Slurm Jobs
# - Et 50+ autres...
```

---

### 3.8 Telegraf (Collecte de Métriques)

#### Qu'est-ce que c'est ?

**Telegraf** est un agent de collecte de métriques écrit en Go.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Léger** : Faible consommation ressources
- ✅ **Plugins** : 200+ plugins disponibles
- ✅ **Flexible** : Inputs et outputs multiples
- ✅ **Prometheus** : Exporte en format Prometheus

**Alternatives considérées** :
- ❌ **Collectd** : Moins moderne, moins de plugins
- ❌ **StatsD** : Uniquement UDP, moins flexible
- ❌ **Custom scripts** : Trop de maintenance

**Pourquoi Telegraf a été choisi** :
- Standard moderne
- Très performant
- Large écosystème de plugins
- Export Prometheus natif

#### Comment ça fonctionne ?

```
Telegraf Agent (sur chaque nœud)
    │
    ├─► Inputs (collecte)
    │   ├─► CPU
    │   ├─► Memory
    │   ├─► Disk
    │   ├─► Network
    │   └─► Processes
    │
    ├─► Processors (optionnel)
    │   └─► Tags, transformations
    │
    └─► Outputs (exposition)
        └─► Prometheus Client (port 9273)
            └─► Scrapé par Prometheus
```

**Configuration** :
- `configs/telegraf/telegraf-frontal.conf` : Pour nœuds frontaux
- `configs/telegraf/telegraf-slave.conf` : Pour nœuds de calcul

**Utilisation** :
```bash
# Vérifier métriques
curl http://172.20.0.101:9273/metrics

# Logs
journalctl -u telegraf -f
```

---

## 4. Logiciels et Applications - Guide Complet

### 4.1 Applications Scientifiques

#### GROMACS

**Qu'est-ce que c'est ?**
- Simulation moléculaire
- Dynamique moléculaire
- Utilisé pour protéines, membranes, etc.

**Pourquoi l'utiliser ?**
- ✅ Standard pour simulation moléculaire
- ✅ Très performant (optimisé MPI)
- ✅ Open-source
- ✅ Large communauté

**Installation** :
```bash
./scripts/applications/install-gromacs.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=gromacs
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16

gmx mdrun -s topol.tpr -v
```

---

#### OpenFOAM

**Qu'est-ce que c'est ?**
- CFD (Computational Fluid Dynamics)
- Simulation de fluides
- Utilisé pour aérodynamique, etc.

**Pourquoi l'utiliser ?**
- ✅ Standard pour CFD
- ✅ Open-source
- ✅ Très performant
- ✅ Large communauté

**Installation** :
```bash
./scripts/applications/install-openfoam.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=openfoam
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8

mpirun -np 32 simpleFoam -parallel
```

---

#### Quantum ESPRESSO

**Qu'est-ce que c'est ?**
- Calculs quantiques (DFT)
- Électronique de structure
- Utilisé pour matériaux, etc.

**Pourquoi l'utiliser ?**
- ✅ Standard pour calculs quantiques
- ✅ Open-source
- ✅ Très performant
- ✅ Large communauté

**Installation** :
```bash
./scripts/applications/install-quantum-espresso.sh
```

**Utilisation** :
```bash
# Job Slurm
#!/bin/bash
#SBATCH --job-name=qe
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16

mpirun -np 32 pw.x < input.in > output.out
```

---

#### ParaView

**Qu'est-ce que c'est ?**
- Visualisation scientifique
- Visualisation de données HPC
- Utilisé pour visualiser résultats

**Pourquoi l'utiliser ?**
- ✅ Standard pour visualisation HPC
- ✅ Open-source
- ✅ Très performant (parallèle)
- ✅ Large communauté

**Installation** :
```bash
./scripts/applications/install-paraview.sh
```

**Utilisation** :
```bash
# Via X2Go (remote graphics)
paraview

# Ou batch
pvpython script.py
```

---

### 4.2 Bases de Données

#### PostgreSQL

**Qu'est-ce que c'est ?**
- Base de données relationnelle
- ACID compliant
- Utilisé pour SlurmDBD, applications

**Pourquoi l'utiliser ?**
- ✅ Standard SQL
- ✅ Très performant
- ✅ Open-source
- ✅ Extensible

**Installation** :
```bash
./scripts/database/install-postgresql.sh
```

**Utilisation** :
```bash
# Connexion
psql -U slurm -d slurm_acct_db

# Requêtes
SELECT * FROM job_table;
```

---

#### MongoDB

**Qu'est-ce que c'est ?**
- Base de données NoSQL
- Document-oriented
- Utilisé pour données non-structurées

**Pourquoi l'utiliser ?**
- ✅ Flexible (schéma dynamique)
- ✅ Scalable
- ✅ Open-source
- ✅ Performant

**Installation** :
```bash
./scripts/database/install-mongodb.sh
```

**Utilisation** :
```bash
# Connexion
mongo

# Requêtes
db.collection.find()
```

---

#### InfluxDB

**Qu'est-ce que c'est ?**
- Base de données time-series
- Optimisée pour métriques
- Utilisé pour monitoring

**Pourquoi l'utiliser ?**
- ✅ Optimisé time-series
- ✅ Très performant
- ✅ Open-source
- ✅ Compatible Telegraf

**Installation** :
```bash
./scripts/database/install-influxdb.sh
```

**Utilisation** :
```bash
# Accès web
http://localhost:8086

# Requêtes InfluxQL
SELECT * FROM cpu WHERE time > now() - 1h
```

---

### 4.3 Messaging et Streaming

#### RabbitMQ

**Qu'est-ce que c'est ?**
- Message broker
- AMQP protocol
- Utilisé pour communication asynchrone

**Pourquoi l'utiliser ?**
- ✅ Standard AMQP
- ✅ Très performant
- ✅ Open-source
- ✅ Haute disponibilité

**Installation** :
```bash
./scripts/messaging/install-rabbitmq-complete.sh
```

**Utilisation** :
```bash
# Accès web
http://localhost:15672
# Login: guest / guest

# Publier message
rabbitmqadmin publish exchange=amq.default routing_key=test payload="Hello"
```

---

#### Kafka

**Qu'est-ce que c'est ?**
- Streaming platform
- Event streaming
- Utilisé pour Big Data

**Pourquoi l'utiliser ?**
- ✅ Très performant (millions messages/s)
- ✅ Scalable
- ✅ Open-source
- ✅ Standard Big Data

**Installation** :
```bash
./scripts/streaming/install-kafka-complete.sh
```

**Utilisation** :
```bash
# Créer topic
kafka-topics.sh --create --topic test --bootstrap-server localhost:9092

# Publier
kafka-console-producer.sh --topic test --bootstrap-server localhost:9092

# Consommer
kafka-console-consumer.sh --topic test --bootstrap-server localhost:9092
```

---

### 4.4 Big Data et Machine Learning

#### Apache Spark

**Qu'est-ce que c'est ?**
- Processing distribué
- Big Data analytics
- Utilisé pour traitement de données massives

**Pourquoi l'utiliser ?**
- ✅ Très performant (in-memory)
- ✅ Scalable
- ✅ Open-source
- ✅ Standard Big Data

**Installation** :
```bash
./scripts/bigdata/install-spark.sh
```

**Utilisation** :
```bash
# Spark Shell
spark-shell

# Job Spark
spark-submit --class MyApp --master yarn myapp.jar
```

---

#### TensorFlow

**Qu'est-ce que c'est ?**
- Framework deep learning
- Machine learning
- Utilisé pour IA

**Pourquoi l'utiliser ?**
- ✅ Standard deep learning
- ✅ Très performant (GPU)
- ✅ Open-source
- ✅ Large communauté

**Installation** :
```bash
./scripts/ml/install-tensorflow.sh
```

**Utilisation** :
```python
import tensorflow as tf

# Modèle
model = tf.keras.Sequential([...])
model.fit(x_train, y_train)
```

---

#### PyTorch

**Qu'est-ce que c'est ?**
- Framework deep learning
- Alternative à TensorFlow
- Utilisé pour recherche IA

**Pourquoi l'utiliser ?**
- ✅ Plus flexible que TensorFlow
- ✅ Très performant (GPU)
- ✅ Open-source
- ✅ Popular en recherche

**Installation** :
```bash
./scripts/ml/install-pytorch.sh
```

**Utilisation** :
```python
import torch

# Modèle
model = torch.nn.Sequential(...)
loss = criterion(output, target)
```

---

## 5. Choix de Conception et Justifications

### 5.1 Pourquoi Docker au lieu de VMs ?

**Docker** :
- ✅ Plus léger (partage kernel)
- ✅ Démarrage plus rapide
- ✅ Moins de ressources
- ✅ Plus portable

**VMs** :
- ❌ Plus lourd (OS complet)
- ❌ Démarrage lent
- ❌ Plus de ressources
- ❌ Moins portable

**Décision** : Docker pour portabilité et légèreté.

---

### 5.2 Pourquoi BeeGFS au lieu de GPFS ?

**BeeGFS** :
- ✅ Open-source (gratuit)
- ✅ Plus simple à configurer
- ✅ Performance excellente
- ✅ Communauté active

**GPFS** :
- ❌ Commercial (licence coûteuse)
- ❌ Plus complexe
- ❌ Nécessite support IBM

**Décision** : BeeGFS pour open-source et simplicité.

---

### 5.3 Pourquoi Slurm au lieu de PBS/Torque ?

**Slurm** :
- ✅ Standard moderne HPC
- ✅ Plus de fonctionnalités
- ✅ Meilleure performance
- ✅ Communauté très active

**PBS/Torque** :
- ❌ Plus ancien
- ❌ Moins de fonctionnalités
- ❌ Communauté réduite

**Décision** : Slurm pour standard moderne.

---

### 5.4 Pourquoi Prometheus au lieu de Nagios ?

**Prometheus** :
- ✅ Pull-based (plus efficace)
- ✅ Time-series optimisé
- ✅ PromQL puissant
- ✅ Standard moderne

**Nagios** :
- ❌ Push-based (moins efficace)
- ❌ Plus ancien
- ❌ Interface moins moderne

**Décision** : Prometheus pour monitoring moderne.

---

### 5.5 Pourquoi LDAP + Kerberos au lieu de FreeIPA ?

**LDAP + Kerberos** :
- ✅ Plus simple
- ✅ Plus de contrôle
- ✅ Composants séparés (flexibilité)
- ✅ Moins de dépendances

**FreeIPA** :
- ❌ Plus complexe
- ❌ Tout-en-un (moins flexible)
- ❌ Plus de dépendances

**Décision** : LDAP + Kerberos pour simplicité et contrôle.

---

## 6. Structure du Projet - Organisation

### 6.1 Organisation des Dossiers

```
cluster hpc/
├── docker/                    # Configuration Docker
│   ├── docker-compose-opensource.yml
│   ├── frontal/Dockerfile
│   ├── client/Dockerfile
│   ├── scripts/               # Entrypoints
│   └── packages/              # RPMs (GPFS, Telegraf)
│
├── configs/                   # Configurations
│   ├── prometheus/
│   ├── grafana/
│   ├── telegraf/
│   ├── slurm/
│   ├── loki/
│   └── jupyterhub/
│
├── scripts/                   # Scripts d'installation
│   ├── applications/         # Applications scientifiques
│   ├── storage/              # Stockage (BeeGFS, Lustre)
│   ├── security/             # Sécurité
│   ├── monitoring/           # Monitoring
│   ├── database/             # Bases de données
│   ├── messaging/            # Messaging
│   ├── bigdata/             # Big Data
│   └── ...
│
├── docs/                     # Documentation (85+ guides)
│   ├── GUIDE_*.md
│   └── ...
│
├── grafana-dashboards/       # Dashboards Grafana (54+)
│   └── *.json
│
└── examples/                 # Exemples
    ├── jobs/                 # Exemples jobs Slurm
    └── jupyter/              # Notebooks Jupyter
```

### 6.2 Pourquoi cette Structure ?

**Séparation des préoccupations** :
- `docker/` : Tout ce qui concerne Docker
- `configs/` : Toutes les configurations
- `scripts/` : Tous les scripts (organisés par catégorie)
- `docs/` : Toute la documentation

**Avantages** :
- ✅ Facile à naviguer
- ✅ Logique et intuitive
- ✅ Facile à maintenir
- ✅ Facile à étendre

---

## 7. Comment Tout Fonctionne Ensemble

### 7.1 Flux d'Authentification

```
1. Utilisateur se connecte
   ssh jdoe@frontal-01
   
2. SSH contacte LDAP
   SSH ──► LDAP (vérification identité)
   
3. LDAP vérifie et retourne OK
   LDAP ──► SSH (OK)
   
4. SSH demande ticket Kerberos
   SSH ──► Kerberos KDC (obtention ticket)
   
5. Kerberos émet ticket
   Kerberos ──► SSH (ticket)
   
6. Utilisateur authentifié
   SSH ──► Session ouverte
```

### 7.2 Flux de Soumission de Job

```
1. Utilisateur soumet un job
   sbatch job.sh
   
2. SlurmCTLD reçoit la requête
   sbatch ──► SlurmCTLD
   
3. SlurmCTLD vérifie ressources
   SlurmCTLD ──► Vérifie CPU, RAM disponibles
   
4. SlurmCTLD place dans file d'attente
   SlurmCTLD ──► File d'attente
   
5. Quand ressources disponibles, lance le job
   SlurmCTLD ──► SlurmD (compute-01)
   
6. SlurmD exécute le job
   SlurmD ──► Exécution job.sh
   
7. Job accède à BeeGFS
   Job ──► BeeGFS Client ──► BeeGFS MGMtd
   
8. Métriques collectées
   Telegraf ──► Prometheus ──► Grafana
```

### 7.3 Flux de Monitoring

```
1. Telegraf collecte métriques (toutes les 15s)
   Telegraf ──► CPU, RAM, Disk, Network
   
2. Telegraf expose métriques
   Telegraf ──► Port 9273 (format Prometheus)
   
3. Prometheus scrape (toutes les 15s)
   Prometheus ──► http://172.20.0.101:9273/metrics
   
4. Prometheus stocke dans TSDB
   Prometheus ──► TSDB (rétention 30 jours)
   
5. Grafana interroge Prometheus
   Grafana ──► Prometheus (requête PromQL)
   
6. Grafana affiche dans dashboard
   Grafana ──► Dashboard (visualisation)
   
7. Alertes si seuils dépassés
   Prometheus ──► Alertmanager ──► Notification
```

---

## 8. Guide d'Utilisation de Chaque Logiciel

### 8.1 Slurm - Guide Complet

Voir : `docs/GUIDE_LANCEMENT_JOBS.md`

### 8.2 Applications Scientifiques

Voir : `docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md`

### 8.3 Monitoring

Voir : `docs/GUIDE_MONITORING_COMPLET.md`

### 8.4 Sécurité

Voir : `docs/GUIDE_SECURITE_AVANCEE.md`

---

## 9. Maintenance et Opérations

### 9.1 Maintenance Quotidienne

Voir : `docs/GUIDE_MAINTENANCE_COMPLETE.md`

### 9.2 Troubleshooting

Voir : `docs/GUIDE_TROUBLESHOOTING.md`

### 9.3 Mise à Jour

Voir : `docs/GUIDE_MISE_A_JOUR_REPARATION.md`

---

## 10. Monitoring et Dashboards

### 10.1 Dashboards Disponibles

**54+ dashboards Grafana** disponibles dans `grafana-dashboards/` :

- HPC Cluster Overview
- CPU/Memory by Node
- Network I/O
- Slurm Jobs
- Slurm Partitions
- Applications (Redis, RabbitMQ, Kafka, etc.)
- Sécurité (Firewall, IDS, Compliance)
- Et 40+ autres...

### 10.2 Ajout d'Agents de Monitoring

**Sur un nouveau nœud** :

1. Installer Telegraf :
```bash
./scripts/monitoring/install-telegraf.sh
```

2. Configurer Telegraf :
```bash
cp configs/telegraf/telegraf-slave.conf /etc/telegraf/telegraf.conf
```

3. Ajouter à Prometheus :
```yaml
# configs/prometheus/prometheus.yml
- job_name: 'new-node-telegraf'
  static_configs:
    - targets: ['172.20.0.XXX:9273']
```

4. Redémarrer Prometheus :
```bash
docker-compose -f docker/docker-compose-opensource.yml restart prometheus
```

### 10.3 Monitoring Hardware

**Node Exporter** (déjà installé) collecte :
- CPU (utilisation, température)
- Mémoire (RAM, swap)
- Disque (I/O, espace)
- Réseau (trafic, erreurs)
- Système (load, uptime)

**Accès** : `http://172.20.0.101:9100/metrics`

### 10.4 Monitoring Réseau

**Telegraf** collecte :
- Trafic réseau (bytes in/out)
- Paquets (in/out, erreurs)
- Connexions (TCP, UDP)

**Dashboard** : "Network I/O" dans Grafana

---

## 📚 Ressources et Documentation Complémentaire

### Documentation par Catégorie

- **Technologies** : `docs/TECHNOLOGIES_CLUSTER.md`
- **Applications** : `docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md`
- **Architecture** : `docs/ARCHITECTURE.md`
- **Monitoring** : `docs/GUIDE_MONITORING_COMPLET.md`
- **Sécurité** : `docs/GUIDE_SECURITE_AVANCEE.md`
- **Maintenance** : `docs/GUIDE_MAINTENANCE_COMPLETE.md`

### Index Complet

Voir : `DOCUMENTATION_COMPLETE_INDEX_300_ETAPES.md`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
