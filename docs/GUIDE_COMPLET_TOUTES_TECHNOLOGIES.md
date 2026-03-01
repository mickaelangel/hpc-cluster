# 📚 GUIDE COMPLET - TOUTES LES TECHNOLOGIES
## Explication Détaillée de Chaque Technologie, Pourquoi et Comment

**Classification**: Documentation Technique Exhaustive  
**Public**: Tous Niveaux  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Technologies de Base](#1-technologies-de-base)
2. [Authentification et Sécurité](#2-authentification-et-sécurité)
3. [Scheduler et Gestion des Jobs](#3-scheduler-et-gestion-des-jobs)
4. [Stockage](#4-stockage)
5. [Monitoring et Observabilité](#5-monitoring-et-observabilité)
6. [Applications Scientifiques](#6-applications-scientifiques)
7. [Bases de Données](#7-bases-de-données)
8. [Messaging et Streaming](#8-messaging-et-streaming)
9. [Big Data et Machine Learning](#9-big-data-et-machine-learning)
10. [CI/CD et Automatisation](#10-cicd-et-automatisation)
11. [Orchestration et Conteneurs](#11-orchestration-et-conteneurs)
12. [Sécurité Avancée](#12-sécurité-avancée)
13. [Remote Graphics](#13-remote-graphics)
14. [Gestion de Packages](#14-gestion-de-packages)

---

## 1. Technologies de Base

### 1.1 Docker

#### Qu'est-ce que c'est ?

**Docker** est une plateforme de conteneurisation qui permet d'empaqueter une application et ses dépendances dans un conteneur isolé, léger et portable.

**Concepts clés** :
- **Image** : Template d'un conteneur (ex: `openSUSE Leap 15.6`)
- **Conteneur** : Instance d'une image en cours d'exécution
- **Dockerfile** : Instructions pour construire une image
- **Docker Compose** : Orchestration de plusieurs conteneurs

#### Pourquoi l'utiliser dans ce projet ?

**Avantages** :
- ✅ **Portabilité** : Fonctionne identiquement sur n'importe quel système
- ✅ **Isolation** : Chaque service dans son conteneur (pas de conflits)
- ✅ **Reproductibilité** : Même environnement partout (dev, test, prod)
- ✅ **Facilité** : Un seul fichier `docker-compose.yml` pour tout
- ✅ **Air-gapped** : Peut fonctionner sans Internet (images exportées)
- ✅ **Léger** : Partage le kernel (vs VMs qui ont leur propre OS)

**Alternatives considérées et pourquoi rejetées** :
- ❌ **VMware/KVM** : Trop lourd, nécessite hyperviseur, démarrage lent
- ❌ **LXC** : Moins standardisé, moins d'outils, communauté plus petite
- ❌ **Installation native** : Difficile à reproduire, dépendances complexes, pas portable

**Pourquoi Docker a été choisi** :
- Standard de l'industrie (utilisé partout)
- Large écosystème (millions d'images disponibles)
- Facile à apprendre et utiliser
- Compatible openSUSE 15.6
- Parfait pour simulation/démo de cluster

#### Comment ça fonctionne ?

```
┌─────────────────────────────────────┐
│         Docker Engine               │
│  (sur le système hôte)              │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Conteneur frontal-01         │  │
│  │  ├─► openSUSE Leap 15.6       │  │
│  │  ├─► SlurmCTLD                │  │
│  │  ├─► LDAP (389DS)             │  │
│  │  ├─► Kerberos KDC             │  │
│  │  └─► Services système          │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Conteneur compute-01          │  │
│  │  ├─► openSUSE Leap 15.6       │  │
│  │  ├─► SlurmD                   │  │
│  │  ├─► BeeGFS Client            │  │
│  │  └─► Applications HPC         │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Conteneur Prometheus          │  │
│  │  ├─► Image Prometheus          │  │
│  │  └─► Configuration            │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Fichiers** :
- `docker/frontal/Dockerfile` : Image pour nœuds frontaux
- `docker/client/Dockerfile` : Image pour nœuds de calcul
- `docker/docker-compose-opensource.yml` : Orchestration complète

**Utilisation** :
```bash
# Build des images
cd docker/
docker-compose -f docker-compose-opensource.yml build

# Démarrage
docker-compose -f docker-compose-opensource.yml up -d

# Arrêt
docker-compose -f docker-compose-opensource.yml down

# Logs
docker-compose -f docker-compose-opensource.yml logs -f

# Statut
docker-compose -f docker-compose-opensource.yml ps
```

**Maintenance** :
```bash
# Mise à jour images
docker-compose -f docker-compose-opensource.yml pull
docker-compose -f docker-compose-opensource.yml up -d

# Nettoyage
docker system prune -a
```

---

### 1.2 openSUSE Leap 15.6

#### Qu'est-ce que c'est ?

**openSUSE Leap** est une distribution Linux communautaire.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **openSUSE Leap 15.6** : Base unique du projet
- ✅ **Stable** : Version LTS (Long Term Support)
- ✅ **Zypper** : Gestionnaire de packages performant
- ✅ **Enterprise-ready** : Utilisé en production
- ✅ **Open-source** : Gratuit

**Alternatives considérées** :
- ❌ **CentOS/RHEL** : Autre écosystème (yum/dnf)
- ❌ **Ubuntu** : Différent (apt vs zypper)
- ❌ **Debian** : Moins enterprise-oriented

**Pourquoi openSUSE Leap a été choisi** :
- Compatibilité maximale avec openSUSE 15.6
- Stable et fiable
- Zypper excellent gestionnaire de packages
- Parfait pour environnement enterprise

---

## 2. Authentification et Sécurité

### 2.1 LDAP (389 Directory Server)

#### Qu'est-ce que c'est ?

**LDAP** (Lightweight Directory Access Protocol) est un protocole d'accès à un annuaire distribué. **389 Directory Server** est l'implémentation open-source d'IBM (anciennement Red Hat Directory Server).

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Authentification centralisée** : Un seul point d'authentification pour tous les nœuds
- ✅ **Gestion utilisateurs** : Création/modification/suppression centralisée
- ✅ **Intégration** : Compatible avec Kerberos, SSH, Slurm, NFS, etc.
- ✅ **Standards** : Protocole standardisé (RFC 4510)
- ✅ **Scalable** : Supporte des milliers d'utilisateurs
- ✅ **Open-source** : Gratuit

**Alternatives considérées** :
- ❌ **Fichiers locaux (/etc/passwd)** : Non scalable, pas centralisé, difficile à maintenir
- ❌ **Active Directory** : Commercial, Windows-centric, licence coûteuse
- ❌ **FreeIPA** : Plus complexe, peut être overkill pour certains cas

**Pourquoi LDAP a été choisi** :
- Standard de l'industrie pour annuaires
- Simple et efficace
- Compatible avec tout (SSH, Slurm, NFS, etc.)
- Open-source pur
- Bien documenté

#### Comment ça fonctionne ?

```
Client (SSH, Slurm, etc.)
    │
    │ Requête LDAP (port 389)
    │ "Vérifier utilisateur jdoe / password"
    ▼
389 Directory Server
    │
    │ Recherche dans base LDAP (Berkeley DB)
    │ dc=cluster,dc=local
    │   └─► ou=users
    │       └─► uid=jdoe
    │
    ├─► Vérifie password (hash SSHA)
    │
    └─► Retourne : OK / NOK
```

**Structure LDAP** :
```
dc=cluster,dc=local
├── ou=users
│   ├── uid=jdoe,ou=users,dc=cluster,dc=local
│   │   ├── cn: John Doe
│   │   ├── sn: Doe
│   │   ├── userPassword: {SSHA}encrypted_password
│   │   ├── uidNumber: 1001
│   │   ├── gidNumber: 1001
│   │   ├── homeDirectory: /home/jdoe
│   │   └── loginShell: /bin/bash
│   └── ...
├── ou=groups
│   ├── cn=hpc-users,ou=groups,dc=cluster,dc=local
│   │   ├── memberUid: jdoe
│   │   └── gidNumber: 1001
│   └── cn=admins,ou=groups,dc=cluster,dc=local
└── ou=computers
    ├── cn=node-01,ou=computers,dc=cluster,dc=local
    └── ...
```

**Installation** :
```bash
./scripts/install-ldap-kerberos.sh
```

**Configuration** :
```bash
# Créer un utilisateur
ldapadd -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: jdoe
cn: John Doe
sn: Doe
userPassword: {SSHA}encrypted_password
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
loginShell: /bin/bash
EOF

# Rechercher
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Modifier
ldapmodify -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
changetype: modify
replace: userPassword
userPassword: {SSHA}new_encrypted_password
EOF
```

**Maintenance** :
```bash
# Vérification
systemctl status dirsrv@cluster
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Sauvegarde
ldapsearch -x -b "dc=cluster,dc=local" > backup.ldif

# Restauration
ldapadd -x -D "cn=Directory Manager" -w "password" -f backup.ldif

# Logs
tail -f /var/log/dirsrv/slapd-cluster/access
tail -f /var/log/dirsrv/slapd-cluster/errors
```

---

### 2.2 Kerberos

#### Qu'est-ce que c'est ?

**Kerberos** est un protocole d'authentification réseau sécurisé basé sur des tickets cryptographiques. Il permet l'authentification unique (SSO) sans transmettre de mots de passe en clair sur le réseau.

**Concepts clés** :
- **KDC** (Key Distribution Center) : Serveur d'authentification
- **Realm** : Domaine Kerberos (ex: CLUSTER.LOCAL)
- **Principal** : Identité (ex: jdoe@CLUSTER.LOCAL)
- **TGT** (Ticket Granting Ticket) : Ticket pour obtenir d'autres tickets
- **Service Ticket** : Ticket pour accéder à un service spécifique

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Sécurité** : Pas de mots de passe en clair sur le réseau
- ✅ **SSO** : Authentification unique (Single Sign-On)
- ✅ **Intégration** : Compatible avec LDAP, SSH, NFS, etc.
- ✅ **Standards** : Protocole standardisé (RFC 4120)
- ✅ **Enterprise** : Utilisé par toutes les grandes entreprises

**Alternatives considérées** :
- ❌ **Mots de passe en clair** : Non sécurisé, vulnérable aux attaques
- ❌ **Certificats uniquement** : Plus complexe à gérer, pas de SSO
- ❌ **OAuth/SAML** : Overkill pour HPC, plus pour web apps

**Pourquoi Kerberos a été choisi** :
- Standard pour environnements enterprise
- Sécurisé par défaut (chiffrement)
- SSO intégré (une authentification pour tout)
- Compatible avec tout (SSH, NFS, Slurm, etc.)
- Bien documenté

#### Comment ça fonctionne ?

```
1. Client demande un TGT
   Client ──► KDC (Key Distribution Center)
              Port 88
              "Je suis jdoe, voici mon password (chiffré)"
   
2. KDC vérifie l'identité (via LDAP)
   KDC ──► LDAP (vérification jdoe / password)
   LDAP ──► KDC (OK / NOK)
   
3. Si OK, KDC émet un TGT (chiffré avec password client)
   KDC ──► Client (TGT chiffré)
   
4. Client utilise le TGT pour obtenir un service ticket
   Client ──► KDC (avec TGT)
              "Je veux accéder à SSH sur node-01"
   KDC ──► Client (Service Ticket pour SSH/node-01)
   
5. Client présente le service ticket au service
   Client ──► SSH/node-01 (avec Service Ticket)
   SSH ──► KDC (vérification ticket)
   KDC ──► SSH (ticket valide)
   SSH ──► Client (OK, authentifié, session ouverte)
```

**Durée de vie des tickets** :
- **TGT** : 24 heures (par défaut)
- **Service Ticket** : 10 heures (par défaut)
- **Renouvellement** : Possible jusqu'à 7 jours

**Installation** :
```bash
./scripts/install-ldap-kerberos.sh
```

**Configuration** :
```bash
# /etc/krb5.conf
[libdefaults]
    default_realm = CLUSTER.LOCAL
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    CLUSTER.LOCAL = {
        kdc = frontal-01.cluster.local:88
        admin_server = frontal-01.cluster.local:749
    }

[domain_realm]
    .cluster.local = CLUSTER.LOCAL
    cluster.local = CLUSTER.LOCAL
```

**Utilisation** :
```bash
# Obtenir un ticket
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe

# Vérifier le ticket
klist

# Renouveler le ticket
kinit -R

# Détruire le ticket
kdestroy

# SSH sans mot de passe (si ticket valide)
ssh jdoe@node-01
# (pas besoin de mot de passe si ticket Kerberos valide)
```

**Maintenance** :
```bash
# Vérification
systemctl status krb5kdc
kadmin.local -q "listprincs"

# Créer un principal
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"

# Changer mot de passe
kadmin.local -q "change_password jdoe@CLUSTER.LOCAL"

# Logs
tail -f /var/log/krb5kdc.log
tail -f /var/log/kadmin.log
```

---

### 2.3 FreeIPA (Alternative)

#### Qu'est-ce que c'est ?

**FreeIPA** (Identity, Policy, and Audit) est une solution intégrée qui combine :
- LDAP (389 Directory Server)
- Kerberos
- DNS
- PKI (Certificats)
- Gestion des politiques

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Solution unifiée** : Tout-en-un au lieu de configurer LDAP + Kerberos séparément
- ✅ **Interface web** : Administration via interface graphique
- ✅ **Enterprise-ready** : Solution robuste pour production
- ✅ **Gestion des politiques** : Contrôle d'accès centralisé
- ✅ **DNS intégré** : Gestion DNS automatique

**Inconvénients** :
- ❌ **Plus complexe** : Plus de composants, plus de dépendances
- ❌ **Moins flexible** : Tout-en-un, moins de contrôle granulaire

**Quand utiliser FreeIPA vs LDAP+Kerberos** :
- **FreeIPA** : Si vous voulez une solution complète avec interface web
- **LDAP+Kerberos** : Si vous voulez plus de contrôle et simplicité

**Installation** :
```bash
./scripts/install-freeipa.sh
```

**Utilisation** :
```bash
# Interface web
https://frontal-01.cluster.local

# Commandes
ipa user-add jdoe
ipa user-mod jdoe --password
ipa group-add hpc-users
ipa group-add-member hpc-users --users=jdoe
```

---

## 3. Scheduler et Gestion des Jobs

### 3.1 Slurm (Workload Manager)

#### Qu'est-ce que c'est ?

**Slurm** (Simple Linux Utility for Resource Management) est un gestionnaire de jobs et de ressources pour clusters HPC.

**Composants** :
- **SlurmCTLD** : Contrôleur (sur frontal-01)
- **SlurmDBD** : Base de données des jobs (optionnel)
- **SlurmD** : Daemon sur chaque nœud de calcul
- **squeue** : Affiche la file d'attente
- **sinfo** : Affiche les nœuds
- **sbatch** : Soumet un job
- **srun** : Lance un job interactif
- **scancel** : Annule un job

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard HPC** : Utilisé par 60%+ des clusters mondiaux (Top500)
- ✅ **Gestion ressources** : CPU, mémoire, GPU, partitions, QOS
- ✅ **File d'attente intelligente** : Priorité, backfill, preemption
- ✅ **Multi-utilisateurs** : Partage équitable des ressources
- ✅ **Open-source** : Gratuit, communauté très active
- ✅ **Performant** : Gère des milliers de nœuds, millions de jobs
- ✅ **Fonctionnalités avancées** : Checkpointing, job arrays, dependencies

**Alternatives considérées** :
- ❌ **PBS/Torque** : Moins moderne, moins de fonctionnalités, communauté réduite
- ❌ **LSF (IBM)** : Commercial, licence coûteuse, moins flexible
- ❌ **SGE (Sun Grid Engine)** : Moins maintenu, communauté réduite
- ❌ **Kubernetes** : Pas optimisé pour HPC, plus pour microservices

**Pourquoi Slurm a été choisi** :
- Standard de facto pour HPC moderne
- Très bien documenté
- Performant et fiable
- Supporte toutes les fonctionnalités nécessaires (GPU, MPI, etc.)
- Communauté énorme et active
- Utilisé par les plus grands clusters mondiaux

#### Comment ça fonctionne ?

```
Utilisateur soumet un job
    │
    ├─► sbatch job.sh
    │
    ▼
SlurmCTLD (Controller sur frontal-01)
    │
    ├─► Parse le script (directives #SBATCH)
    │   ├─► --nodes=2
    │   ├─► --ntasks-per-node=16
    │   ├─► --time=01:00:00
    │   └─► --partition=normal
    │
    ├─► Vérifie ressources disponibles
    │   ├─► CPU disponible ?
    │   ├─► RAM disponible ?
    │   ├─► Partition disponible ?
    │   └─► QOS disponible ?
    │
    ├─► Calcule priorité
    │   ├─► Fair-share (utilisation historique)
    │   ├─► Age (temps d'attente)
    │   └─► Partition priority
    │
    ├─► Place dans file d'attente
    │   └─► Ordre par priorité
    │
    ├─► Quand ressources disponibles :
    │   ├─► Sélectionne nœuds (best-fit)
    │   ├─► Alloue ressources (cgroups)
    │   └─► Lance le job
    │       │
    │       ▼
    │   SlurmD (Daemon sur compute-01, compute-02, etc.)
    │       │
    │       ├─► Crée environnement
    │       ├─► Alloue CPU, RAM (cgroups)
    │       ├─► Lance le job
    │       ├─► Collecte métriques
    │       └─► Notifie SlurmCTLD (fin, erreur)
    │
    └─► SlurmCTLD met à jour état
        └─► SlurmDBD (enregistre dans base de données)
```

**Fichiers de configuration** :
- `configs/slurm/slurm.conf` : Configuration principale
- `configs/slurm/cgroup.conf` : Gestion des ressources (cgroups)

**Exemple de job** :
```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=16
#SBATCH --time=01:00:00
#SBATCH --partition=normal
#SBATCH --output=myjob.%j.out
#SBATCH --error=myjob.%j.err

# Charger modules
module load openmpi/4.1.5
module load gromacs/2023.2

# Lancer le job
mpirun -np 32 gmx mdrun -s topol.tpr -v
```

**Utilisation** :
```bash
# Soumettre un job
sbatch job.sh

# Voir les jobs
squeue
squeue -u $USER
squeue -j JOBID

# Voir les nœuds
sinfo
sinfo -N -l

# Voir les partitions
sinfo -p normal

# Job interactif
srun --pty bash

# Annuler un job
scancel JOBID
scancel -u $USER

# Voir historique
sacct
sacct -j JOBID
```

**Maintenance** :
```bash
# Vérification
systemctl status slurmctld
systemctl status slurmd

# Contrôle
scontrol show nodes
scontrol show partition normal
scontrol show job JOBID

# Recharger configuration
scontrol reconfigure

# Logs
tail -f /var/log/slurmctld.log
tail -f /var/log/slurmd.log
```

---

## 4. Stockage

### 4.1 BeeGFS

#### Qu'est-ce que c'est ?

**BeeGFS** (formerly FhGFS) est un système de fichiers parallèle open-source optimisé pour HPC et calcul haute performance.

**Composants** :
- **MGMtd** : Gestionnaire de métadonnées (Management)
- **Metadata Servers** : Serveurs de métadonnées (optionnel, pour scalabilité)
- **Storage Targets** : Serveurs de stockage (données)
- **Client** : Sur chaque nœud (compute-01 à compute-06)

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Performance** : Très rapide pour HPC (I/O parallèle)
- ✅ **Scalabilité** : Supporte des milliers de nœuds, pétaoctets
- ✅ **Open-source** : Gratuit, pas de licence
- ✅ **Facilité** : Plus simple que Lustre
- ✅ **Flexibilité** : Peut démarrer petit et grandir
- ✅ **Haute disponibilité** : Redondance possible

**Alternatives considérées** :
- ❌ **GPFS (IBM Spectrum Scale)** : Commercial, licence coûteuse (plusieurs dizaines de milliers d'euros)
- ❌ **Lustre** : Plus complexe, nécessite plus de ressources, plus difficile à maintenir
- ❌ **GlusterFS** : Moins performant pour HPC, plus pour stockage distribué général
- ❌ **NFS** : Trop lent pour HPC, pas parallèle
- ❌ **CephFS** : Plus pour cloud, moins optimisé HPC

**Pourquoi BeeGFS a été choisi** :
- Meilleur compromis performance/facilité
- Open-source pur (pas de licence)
- Bien documenté
- Communauté active
- Performances excellentes pour HPC
- Plus simple que Lustre

#### Comment ça fonctionne ?

```
Application (sur compute-01)
    │
    ├─► Écriture fichier /mnt/beegfs/data.txt
    │
    ▼
BeeGFS Client
    │
    ├─► Contacte MGMtd (métadonnées)
    │   └─► "Où stocker data.txt ?"
    │
    ├─► MGMtd retourne localisation
    │   └─► "Storage Target 1 (frontal-01), Target 2 (frontal-02)"
    │
    ├─► Client écrit directement sur Storage Targets
    │   ├─► Target 1 (frontal-01) : Stripe 1
    │   ├─► Target 2 (frontal-02) : Stripe 2
    │   └─► I/O parallèle (performance élevée)
    │
    └─► Performance élevée (bande passante agrégée)
```

**Architecture** :
```
┌─────────────┐
│   MGMtd     │  ← Management (métadonnées)
│ (frontal-01)│
└──────┬──────┘
       │
┌──────▼──────┐
│  Storage    │  ← Storage Targets (données)
│  Targets    │
│ (frontal-01)│
│ (frontal-02)│
└──────┬──────┘
       │
┌──────▼──────┐
│   Clients   │  ← Tous les nœuds
│ (compute-01)│
│ (compute-02)│
│     ...     │
└─────────────┘
```

**Installation** :
```bash
./scripts/storage/install-beegfs.sh
```

**Configuration** :
```bash
# Configuration MGMtd (frontal-01)
/opt/beegfs/sbin/beegfs-setup-mgmtd -p /mnt/beegfs-mgmtd

# Configuration Storage Target (frontal-01, frontal-02)
/opt/beegfs/sbin/beegfs-setup-storage -p /mnt/beegfs-storage -s 1

# Configuration Client (compute-01 à compute-06)
/opt/beegfs/sbin/beegfs-setup-client -m frontal-01

# Démarrer
systemctl start beegfs-mgmtd
systemctl start beegfs-storage
systemctl start beegfs-client

# Monter
mount -t beegfs beegfs /mnt/beegfs
```

**Utilisation** :
```bash
# Vérifier
df -h /mnt/beegfs
beegfs-ctl --listnodes --nodetype=storage
beegfs-ctl --listnodes --nodetype=client

# Performance test
dd if=/dev/zero of=/mnt/beegfs/test bs=1M count=1000
```

**Maintenance** :
```bash
# Statut
systemctl status beegfs-mgmtd
systemctl status beegfs-storage
systemctl status beegfs-client

# Logs
tail -f /var/log/beegfs-mgmtd.log
tail -f /var/log/beegfs-storage.log
```

---

### 4.2 Lustre (Alternative)

#### Qu'est-ce que c'est ?

**Lustre** est un système de fichiers parallèle open-source, très performant mais plus complexe que BeeGFS.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Très performant** : Utilisé par les plus grands clusters (Top500)
- ✅ **Scalable** : Supporte exaoctets
- ✅ **Open-source** : Gratuit

**Inconvénients** :
- ❌ **Plus complexe** : Configuration plus difficile
- ❌ **Plus de ressources** : Nécessite plus de serveurs

**Quand utiliser Lustre vs BeeGFS** :
- **Lustre** : Si vous avez besoin de performances maximales et beaucoup de ressources
- **BeeGFS** : Si vous voulez simplicité et bonnes performances

**Installation** :
```bash
./scripts/storage/install-lustre.sh
```

---

## 5. Monitoring et Observabilité

### 5.1 Prometheus

#### Qu'est-ce que c'est ?

**Prometheus** est un système de monitoring et d'alerting open-source, spécialisé dans les métriques time-series.

**Concepts clés** :
- **Pull-based** : Prometheus "scrape" (tire) les métriques
- **Time-series** : Base de données optimisée pour séries temporelles
- **PromQL** : Langage de requête puissant
- **Alerting** : Système d'alertes intégré
- **Exporters** : Agents qui exposent des métriques

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Pull-based** : Plus efficace que push (pas de perte si exporter down)
- ✅ **Time-series** : Base de données optimisée pour métriques
- ✅ **PromQL** : Langage de requête très puissant
- ✅ **Alerting** : Système d'alertes intégré
- ✅ **Open-source** : Gratuit, communauté énorme
- ✅ **Standard** : De facto pour monitoring moderne
- ✅ **Écosystème** : Des centaines d'exporters disponibles

**Alternatives considérées** :
- ❌ **Nagios** : Plus ancien, push-based, moins moderne
- ❌ **Zabbix** : Plus complexe, interface moins intuitive
- ❌ **Datadog/New Relic** : Commercial, coûteux (plusieurs centaines d'euros/mois)
- ❌ **InfluxDB seul** : Pas de système d'alertes intégré

**Pourquoi Prometheus a été choisi** :
- Standard de facto pour monitoring moderne
- Très performant (millions de métriques)
- Excellent pour métriques time-series
- Écosystème énorme (exporters pour tout)
- PromQL très puissant
- Alerting intégré

#### Comment ça fonctionne ?

```
Prometheus Server
    │
    ├─► Scrape (toutes les 15s)
    │   ├─► Node Exporter (port 9100)
    │   │   └─► Métriques système
    │   │       ├─► CPU (node_cpu_seconds_total)
    │   │       ├─► RAM (node_memory_MemTotal_bytes)
    │   │       ├─► Disk (node_filesystem_size_bytes)
    │   │       └─► Network (node_network_receive_bytes_total)
    │   │
    │   ├─► Telegraf (port 9273)
    │   │   └─► Métriques applicatives
    │   │
    │   └─► Slurm Exporter
    │       └─► Métriques Slurm
    │           ├─► Jobs (slurm_jobs_total)
    │           └─► Partitions (slurm_partition_nodes)
    │
    ├─► Stockage (TSDB)
    │   └─► Rétention 30 jours
    │
    ├─► Évaluation règles (toutes les 15s)
    │   └─► Alertes si seuils dépassés
    │
    └─► API HTTP (port 9090)
        └─► Requêtes PromQL
```

**Configuration** :
- `configs/prometheus/prometheus.yml` : Configuration scraping
- `configs/prometheus/alerts.yml` : Règles d'alertes

**Exemple de configuration** :
```yaml
# configs/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'frontal-01-node'
    static_configs:
      - targets: ['172.20.0.101:9100']
        labels:
          role: 'frontal'
          node: 'frontal-01'
```

**Utilisation** :
```bash
# Accès web
http://localhost:9090

# Requête PromQL
up{job="frontal-01-node"}
node_cpu_seconds_total{mode="idle"}
rate(node_network_receive_bytes_total[5m])
```

**Maintenance** :
```bash
# Vérification
curl http://localhost:9090/-/healthy

# Reload configuration
curl -X POST http://localhost:9090/-/reload

# Logs
docker logs hpc-prometheus
```

---

### 5.2 Grafana

#### Qu'est-ce que c'est ?

**Grafana** est une plateforme de visualisation et d'analyse de métriques.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Dashboards** : Visualisation graphique des métriques
- ✅ **Multi-sources** : Prometheus, InfluxDB, Elasticsearch, etc.
- ✅ **Alerting** : Alertes visuelles
- ✅ **Templates** : Dashboards pré-configurés (54+ dans ce projet)
- ✅ **Open-source** : Gratuit
- ✅ **Standard** : De facto pour visualisation métriques

**Alternatives considérées** :
- ❌ **Kibana** : Principalement pour logs (ELK), moins pour métriques
- ❌ **Custom HTML** : Trop de travail, maintenance difficile
- ❌ **Tableaux de bord propriétaires** : Coûteux, moins flexible

**Pourquoi Grafana a été choisi** :
- Standard pour visualisation métriques
- Interface intuitive et moderne
- Large communauté de dashboards
- Intégration native avec Prometheus
- Open-source

#### Comment ça fonctionne ?

```
Grafana Server
    │
    ├─► Datasource : Prometheus
    │   └─► http://172.20.0.10:9090
    │
    ├─► Dashboards (54+)
    │   ├─► HPC Cluster Overview
    │   ├─► CPU/Memory by Node
    │   ├─► Network I/O
    │   ├─► Slurm Jobs
    │   ├─► Slurm Partitions
    │   ├─► Applications (Redis, RabbitMQ, etc.)
    │   ├─► Sécurité (Firewall, IDS, Compliance)
    │   └─► 40+ autres...
    │
    └─► Alerting
        └─► Notifications (email, webhook, Slack)
```

**Dashboards** :
- `grafana-dashboards/` : 54+ dashboards JSON
- Auto-provisioning via `configs/grafana/provisioning/dashboards/default.yml`

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
# - Slurm Partitions
# - Applications (Redis, RabbitMQ, Kafka, etc.)
# - Sécurité (Firewall, IDS, Compliance)
# - Et 40+ autres...
```

**Création de dashboard** :
1. Aller dans Grafana : http://localhost:3000
2. Créer → Dashboard
3. Ajouter panel
4. Requête PromQL : `node_cpu_seconds_total{mode="idle"}`
5. Sauvegarder

**Maintenance** :
```bash
# Vérification
curl http://localhost:3000/api/health

# Backup dashboards
cp -r grafana-dashboards/ backup/

# Logs
docker logs hpc-grafana
```

---

### 5.3 Telegraf

#### Qu'est-ce que c'est ?

**Telegraf** est un agent de collecte de métriques écrit en Go, très léger et performant.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Léger** : Faible consommation ressources (< 50MB RAM)
- ✅ **Plugins** : 200+ plugins disponibles
- ✅ **Flexible** : Inputs et outputs multiples
- ✅ **Prometheus** : Exporte en format Prometheus
- ✅ **Performant** : Collecte très rapide

**Alternatives considérées** :
- ❌ **Collectd** : Moins moderne, moins de plugins
- ❌ **StatsD** : Uniquement UDP, moins flexible
- ❌ **Custom scripts** : Trop de maintenance

**Pourquoi Telegraf a été choisi** :
- Standard moderne
- Très performant
- Large écosystème de plugins
- Export Prometheus natif
- Léger

#### Comment ça fonctionne ?

```
Telegraf Agent (sur chaque nœud)
    │
    ├─► Inputs (collecte toutes les 15s)
    │   ├─► CPU
    │   │   └─► cpu_usage_idle, cpu_usage_user, etc.
    │   ├─► Memory
    │   │   └─► mem_total, mem_available, etc.
    │   ├─► Disk
    │   │   └─► disk_used, disk_free, etc.
    │   ├─► Network
    │   │   └─► bytes_recv, bytes_sent, etc.
    │   └─► Processes
    │       └─► processes_total, etc.
    │
    ├─► Processors (optionnel)
    │   └─► Tags, transformations
    │
    └─► Outputs (exposition)
        └─► Prometheus Client (port 9273)
            └─► Format Prometheus
            └─► Scrapé par Prometheus
```

**Configuration** :
- `configs/telegraf/telegraf-frontal.conf` : Pour nœuds frontaux
- `configs/telegraf/telegraf-slave.conf` : Pour nœuds de calcul

**Exemple de configuration** :
```toml
# configs/telegraf/telegraf-frontal.conf
[global_tags]
  cluster = "hpc-demo"
  role = "frontal"

[agent]
  interval = "15s"

[[inputs.cpu]]
  percpu = true
  totalcpu = true

[[inputs.mem]]

[[inputs.disk]]

[[outputs.prometheus_client]]
  listen = ":9273"
```

**Utilisation** :
```bash
# Vérifier métriques
curl http://172.20.0.101:9273/metrics

# Logs
journalctl -u telegraf -f

# Test configuration
telegraf --test --config /etc/telegraf/telegraf.conf
```

**Maintenance** :
```bash
# Vérification
systemctl status telegraf

# Reload configuration
systemctl reload telegraf

# Logs
tail -f /var/log/telegraf/telegraf.log
```

---

### 5.4 Node Exporter

#### Qu'est-ce que c'est ?

**Node Exporter** est un exporter Prometheus pour métriques système (CPU, RAM, Disk, Network).

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : Exporter officiel Prometheus
- ✅ **Complet** : Toutes les métriques système
- ✅ **Léger** : Faible consommation
- ✅ **Performant** : Collecte très rapide

#### Comment ça fonctionne ?

```
Node Exporter (port 9100)
    │
    ├─► Collecte métriques système
    │   ├─► CPU (node_cpu_seconds_total)
    │   ├─► Memory (node_memory_MemTotal_bytes)
    │   ├─► Disk (node_filesystem_size_bytes)
    │   ├─► Network (node_network_receive_bytes_total)
    │   └─► System (node_load1, node_uptime_seconds)
    │
    └─► Expose sur /metrics (format Prometheus)
        └─► Scrapé par Prometheus
```

**Utilisation** :
```bash
# Vérifier métriques
curl http://172.20.0.101:9100/metrics

# Accès web
http://172.20.0.101:9100
```

---

## 6. Applications Scientifiques

### 6.1 GROMACS

#### Qu'est-ce que c'est ?

**GROMACS** (GROningen MAchine for Chemical Simulations) est un logiciel de simulation moléculaire.

**Utilisations** :
- Dynamique moléculaire
- Simulation de protéines
- Simulation de membranes
- Études de médicaments

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : Utilisé par la majorité des chercheurs
- ✅ **Performant** : Très optimisé (MPI, GPU)
- ✅ **Open-source** : Gratuit
- ✅ **Documentation** : Très bien documenté

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
#SBATCH --time=01:00:00

module load gromacs/2023.2

gmx mdrun -s topol.tpr -v
```

---

### 6.2 OpenFOAM

#### Qu'est-ce que c'est ?

**OpenFOAM** (Open Field Operation and Manipulation) est un logiciel CFD (Computational Fluid Dynamics).

**Utilisations** :
- Simulation de fluides
- Aérodynamique
- Combustion
- Turbulence

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard CFD** : Utilisé partout
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Très optimisé (MPI)
- ✅ **Flexible** : Personnalisable

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

module load openfoam/2312

mpirun -np 32 simpleFoam -parallel
```

---

### 6.3 Quantum ESPRESSO

#### Qu'est-ce que c'est ?

**Quantum ESPRESSO** est un logiciel de calculs quantiques (DFT - Density Functional Theory).

**Utilisations** :
- Électronique de structure
- Propriétés de matériaux
- Catalyse
- Physique du solide

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : Utilisé par la majorité des chercheurs
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Très optimisé (MPI)
- ✅ **Complet** : Tous les outils nécessaires

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

module load quantum-espresso/7.2

mpirun -np 32 pw.x < input.in > output.out
```

---

### 6.4 ParaView

#### Qu'est-ce que c'est ?

**ParaView** est un logiciel de visualisation scientifique.

**Utilisations** :
- Visualisation de données HPC
- Visualisation de résultats de simulation
- Analyse de données volumétriques

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : Utilisé partout
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Parallèle (MPI)
- ✅ **Puissant** : Beaucoup de fonctionnalités

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

## 7. Bases de Données

### 7.1 PostgreSQL

#### Qu'est-ce que c'est ?

**PostgreSQL** est une base de données relationnelle open-source, ACID compliant.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard SQL** : Compatible avec tout
- ✅ **Performant** : Très rapide
- ✅ **Open-source** : Gratuit
- ✅ **Extensible** : Beaucoup d'extensions

**Utilisation dans le cluster** :
- SlurmDBD (base de données des jobs Slurm)
- Applications nécessitant une base SQL

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
SELECT * FROM job_table WHERE user_name = 'jdoe';
```

---

### 7.2 MongoDB

#### Qu'est-ce que c'est ?

**MongoDB** est une base de données NoSQL document-oriented.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Flexible** : Schéma dynamique
- ✅ **Scalable** : Horizontal scaling
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Très rapide

**Utilisation dans le cluster** :
- Données non-structurées
- Logs structurés
- Métadonnées applications

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
db.collection.insert({name: "test"})
```

---

### 7.3 InfluxDB

#### Qu'est-ce que c'est ?

**InfluxDB** est une base de données time-series optimisée pour métriques.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Optimisé time-series** : Très performant pour métriques
- ✅ **Open-source** : Gratuit
- ✅ **Compatible Telegraf** : Intégration native
- ✅ **Retention policies** : Gestion automatique

**Utilisation dans le cluster** :
- Stockage métriques (alternative à Prometheus TSDB)
- Longue rétention

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

## 8. Messaging et Streaming

### 8.1 RabbitMQ

#### Qu'est-ce que c'est ?

**RabbitMQ** est un message broker open-source, implémentation AMQP.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard AMQP** : Protocole standardisé
- ✅ **Performant** : Très rapide
- ✅ **Open-source** : Gratuit
- ✅ **Haute disponibilité** : Clustering

**Utilisation dans le cluster** :
- Communication asynchrone entre services
- File d'attente de messages
- Découplage de services

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

# Consommer
rabbitmqadmin get queue=test
```

---

### 8.2 Kafka

#### Qu'est-ce que c'est ?

**Kafka** est une plateforme de streaming d'événements.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Très performant** : Millions de messages/seconde
- ✅ **Scalable** : Horizontal scaling
- ✅ **Open-source** : Gratuit
- ✅ **Standard Big Data** : Utilisé partout

**Utilisation dans le cluster** :
- Streaming de données
- Event sourcing
- Big Data pipelines

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

## 9. Big Data et Machine Learning

### 9.1 Apache Spark

#### Qu'est-ce que c'est ?

**Apache Spark** est un framework de processing distribué pour Big Data.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Très performant** : In-memory processing
- ✅ **Scalable** : Horizontal scaling
- ✅ **Open-source** : Gratuit
- ✅ **Standard Big Data** : Utilisé partout

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

### 9.2 TensorFlow

#### Qu'est-ce que c'est ?

**TensorFlow** est un framework deep learning développé par Google.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : Utilisé partout
- ✅ **Performant** : GPU support
- ✅ **Open-source** : Gratuit
- ✅ **Large communauté** : Beaucoup de ressources

**Installation** :
```bash
./scripts/ml/install-tensorflow.sh
```

**Utilisation** :
```python
import tensorflow as tf

model = tf.keras.Sequential([...])
model.fit(x_train, y_train)
```

---

### 9.3 PyTorch

#### Qu'est-ce que c'est ?

**PyTorch** est un framework deep learning développé par Facebook.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Flexible** : Plus flexible que TensorFlow
- ✅ **Performant** : GPU support
- ✅ **Open-source** : Gratuit
- ✅ **Popular en recherche** : Utilisé par beaucoup de chercheurs

**Installation** :
```bash
./scripts/ml/install-pytorch.sh
```

**Utilisation** :
```python
import torch

model = torch.nn.Sequential(...)
loss = criterion(output, target)
```

---

## 10. CI/CD et Automatisation

### 10.1 GitLab CI

#### Qu'est-ce que c'est ?

**GitLab CI** est un système d'intégration continue intégré à GitLab.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Intégré** : Dans GitLab
- ✅ **Flexible** : Pipelines configurables
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Runners distribués

**Installation** :
```bash
./scripts/ci-cd/install-gitlab-ci.sh
```

---

### 10.2 Terraform

#### Qu'est-ce que c'est ?

**Terraform** est un outil Infrastructure as Code (IaC).

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **IaC** : Infrastructure versionnée
- ✅ **Multi-cloud** : Fonctionne partout
- ✅ **Open-source** : Gratuit
- ✅ **Standard** : Utilisé partout

**Installation** :
```bash
./scripts/iac/install-terraform.sh
```

---

## 11. Orchestration et Conteneurs

### 11.1 Kubernetes

#### Qu'est-ce que c'est ?

**Kubernetes** est un orchestrateur de conteneurs.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Standard** : De facto pour orchestration
- ✅ **Scalable** : Auto-scaling
- ✅ **Open-source** : Gratuit
- ✅ **Écosystème** : Très large

**Installation** :
```bash
./scripts/orchestration/install-kubernetes-complete.sh
```

---

## 12. Sécurité Avancée

### 12.1 Vault

#### Qu'est-ce que c'est ?

**Vault** (HashiCorp) est un gestionnaire de secrets.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Gestion secrets** : Centralisée
- ✅ **Rotation** : Automatique
- ✅ **Audit** : Traçabilité
- ✅ **Open-source** : Gratuit

**Installation** :
```bash
./scripts/security/install-vault.sh
```

---

### 12.2 Falco

#### Qu'est-ce que c'est ?

**Falco** est un runtime security monitoring pour conteneurs.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Runtime security** : Détection d'anomalies
- ✅ **Conteneurs** : Spécialisé conteneurs
- ✅ **Open-source** : Gratuit
- ✅ **Performant** : Faible overhead

**Installation** :
```bash
./scripts/security/install-falco.sh
```

---

## 13. Remote Graphics

### 13.1 X2Go

#### Qu'est-ce que c'est ?

**X2Go** est une solution de remote graphics open-source.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **100% Gratuit** : Open-source
- ✅ **Performance** : Optimisé via SSH
- ✅ **Sécurité** : Chiffrement SSH
- ✅ **Multi-utilisateurs** : Plusieurs sessions

**Installation** :
```bash
./scripts/remote-graphics/install-x2go.sh
```

**Utilisation** :
```bash
# Client (Windows/Linux)
# Télécharger X2Go Client
# Connexion : frontal-01, utilisateur, mot de passe
# Session : XFCE ou autre
```

---

### 13.2 NoMachine

#### Qu'est-ce que c'est ?

**NoMachine** est une alternative gratuite pour remote desktop.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Gratuit** : Version gratuite disponible
- ✅ **Performant** : Très rapide
- ✅ **Facile** : Interface simple

**Installation** :
```bash
./scripts/remote-graphics/install-nomachine.sh
```

**Utilisation** :
```bash
# Client
# Connexion : frontal-01:4000
```

---

## 14. Gestion de Packages

### 14.1 Spack

#### Qu'est-ce que c'est ?

**Spack** est un gestionnaire de packages scientifique pour HPC.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Packages scientifiques** : OpenMPI, HDF5, NetCDF, etc.
- ✅ **Optimisation** : Compilation optimisée
- ✅ **Versions multiples** : Plusieurs versions simultanées
- ✅ **Environnements** : Isolation

**Installation** :
```bash
./scripts/spack/configure-spack.sh
```

**Utilisation** :
```bash
# Installer package
spack install openmpi@4.1.5

# Charger
spack load openmpi

# Environnement
spack env create myenv
spack env activate myenv
```

---

### 14.2 Nexus Repository

#### Qu'est-ce que c'est ?

**Nexus Repository** est un gestionnaire de dépôts d'artefacts.

#### Pourquoi l'utiliser ?

**Avantages** :
- ✅ **Air-gapped** : Fonctionne sans Internet
- ✅ **Performance** : Cache local
- ✅ **Sécurité** : Contrôle des packages
- ✅ **Audit** : Traçabilité

**Installation** :
```bash
./scripts/artifacts/install-nexus.sh
```

**Utilisation** :
```bash
# Accès web
http://localhost:8081

# Configuration pip
# ~/.pip/pip.conf
[global]
index-url = http://frontal-01:8081/repository/pypi-group/simple
```

---

## 📚 Documentation Complémentaire

Pour plus de détails sur chaque technologie, voir :
- `docs/TECHNOLOGIES_CLUSTER.md` - Technologies détaillées
- `docs/GUIDE_APPLICATIONS_SCIENTIFIQUES_COMPLET.md` - Applications scientifiques
- `docs/GUIDE_MONITORING_COMPLET.md` - Monitoring complet
- `docs/GUIDE_SECURITE_AVANCEE.md` - Sécurité avancée

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
