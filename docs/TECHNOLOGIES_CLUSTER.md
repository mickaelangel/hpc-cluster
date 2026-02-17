# Technologies et Outils du Cluster HPC
## Documentation Technique Complète

**Classification**: Documentation Technique  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Stack d'Authentification](#stack-dauthentification)
3. [Gestion des Packages](#gestion-des-packages)
4. [Remote Graphics](#remote-graphics)
5. [Scheduler et Jobs](#scheduler-et-jobs)
6. [Stockage](#stockage)
7. [Monitoring](#monitoring)
8. [Provisioning](#provisioning)

---

## 🎯 Vue d'ensemble

Le cluster HPC utilise une stack complète d'outils enterprise pour gérer un environnement de calcul haute performance sécurisé et maintenable.

### Architecture Générale

```
┌─────────────────────────────────────────────────────────────┐
│                    NŒUDS FRONTAUX                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  LDAP    │  │ Kerberos │  │  Nexus   │  │  X2Go    │   │
│  │ (389DS)  │  │   KDC    │  │ (PyPI)   │  │ (Remote) │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Slurm  │  │  BeeGFS  │  │Prometheus│  │  Grafana │   │
│  │  CTLD   │  │   MGMtd  │  │          │  │          │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  Compute-01  │  │  Compute-02  │  │  Compute-06  │
│  (SlurmD)    │  │  (SlurmD)    │  │  (SlurmD)    │
│  + BeeGFS    │  │  + BeeGFS    │  │  + BeeGFS    │
│  + Spack     │  │  + Spack     │  │  + Spack     │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🔐 Stack d'Authentification

### 1. LDAP (389 Directory Server)

#### Qu'est-ce que c'est ?

**LDAP** (Lightweight Directory Access Protocol) est un protocole d'accès à un annuaire distribué. **389 Directory Server** est l'implémentation open-source d'IBM (anciennement Red Hat Directory Server).

#### Pourquoi l'utiliser ?

- **Authentification centralisée** : Un seul point d'authentification pour tous les nœuds
- **Gestion des utilisateurs** : Création/modification/suppression centralisée
- **Intégration** : Compatible avec Kerberos, SSH, Slurm, etc.
- **Standards** : Protocole standardisé (RFC 4510)

#### Comment ça fonctionne ?

```
Client (SSH, Slurm, etc.)
    │
    │ Requête LDAP (port 389)
    ▼
389 Directory Server
    │
    │ Vérification credentials
    ▼
Base de données LDAP (Berkeley DB)
    │
    └─► Retourne : OK / NOK
```

**Structure LDAP** :
```
dc=cluster,dc=local
├── ou=users
│   ├── uid=jdoe,ou=users,dc=cluster,dc=local
│   ├── uid=asmith,ou=users,dc=cluster,dc=local
│   └── ...
├── ou=groups
│   ├── cn=hpc-users,ou=groups,dc=cluster,dc=local
│   └── cn=admins,ou=groups,dc=cluster,dc=local
└── ou=computers
    ├── cn=node-01,ou=computers,dc=cluster,dc=local
    └── ...
```

#### Installation et Configuration

**Installation** :
```bash
zypper install -y 389-ds 389-ds-base
```

**Configuration initiale** :
```bash
setup-ds.pl --silent --file /path/to/inf.conf
```

**Création d'un utilisateur** :
```bash
ldapadd -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
uid: jdoe
cn: John Doe
sn: Doe
userPassword: {SSHA}encrypted_password
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
loginShell: /bin/bash
EOF
```

#### Maintenance

**Vérification du service** :
```bash
systemctl status dirsrv@cluster
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

**Sauvegarde** :
```bash
# Export LDIF
ldapsearch -x -b "dc=cluster,dc=local" > backup.ldif

# Restauration
ldapadd -x -D "cn=Directory Manager" -w "password" -f backup.ldif
```

**Logs** :
```bash
tail -f /var/log/dirsrv/slapd-cluster/access
tail -f /var/log/dirsrv/slapd-cluster/errors
```

---

### 2. Kerberos

#### Qu'est-ce que c'est ?

**Kerberos** est un protocole d'authentification réseau sécurisé basé sur des tickets cryptographiques. Il permet l'authentification unique (SSO) sans transmettre de mots de passe en clair.

#### Pourquoi l'utiliser ?

- **Sécurité** : Pas de mots de passe en clair sur le réseau
- **SSO** : Authentification unique pour tous les services
- **Intégration** : Compatible avec LDAP, SSH, NFS, etc.
- **Standards** : Protocole standardisé (RFC 4120)

#### Comment ça fonctionne ?

```
1. Client demande un ticket
   ┌─────────┐
   │ Client  │ ──► KDC (Key Distribution Center)
   └─────────┘     Port 88
   
2. KDC vérifie l'identité et émet un TGT
   (Ticket Granting Ticket)
   
3. Client utilise le TGT pour obtenir un service ticket
   
4. Client présente le service ticket au service
   (SSH, NFS, etc.)
```

**Composants** :
- **KDC** (Key Distribution Center) : Serveur d'authentification
- **Realm** : Domaine Kerberos (ex: CLUSTER.LOCAL)
- **Principal** : Identité (ex: jdoe@CLUSTER.LOCAL)
- **Ticket** : Token d'authentification temporaire

#### Installation et Configuration

**Installation** :
```bash
zypper install -y krb5 krb5-server krb5-client
```

**Configuration KDC** :
```bash
# /etc/krb5.conf
[libdefaults]
    default_realm = CLUSTER.LOCAL
    ticket_lifetime = 24h
    renew_lifetime = 7d

[realms]
    CLUSTER.LOCAL = {
        kdc = frontal-01.cluster.local:88
        admin_server = frontal-01.cluster.local:749
    }
```

**Initialisation de la base de données** :
```bash
kdb5_util create -s
```

**Création d'un principal** :
```bash
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

#### Utilisation

**Obtenir un ticket** :
```bash
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe
```

**Vérifier le ticket** :
```bash
klist
```

**SSH avec Kerberos** :
```bash
# Configuration SSH
# /etc/ssh/sshd_config
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes

# Connexion (sans mot de passe si ticket valide)
ssh jdoe@node-01
```

#### Maintenance

**Vérification du service** :
```bash
systemctl status krb5kdc
kadmin.local -q "listprincs"
```

**Expiration des tickets** :
```bash
# Vérifier l'expiration
klist -v

# Renouveler
kinit -R
```

**Logs** :
```bash
tail -f /var/log/krb5kdc.log
tail -f /var/log/kadmin.log
```

---

### 3. FreeIPA (Alternative)

#### Qu'est-ce que c'est ?

**FreeIPA** (Identity, Policy, and Audit) est une solution intégrée qui combine :
- LDAP (389 Directory Server)
- Kerberos
- DNS
- PKI (Certificats)
- Gestion des politiques

#### Pourquoi l'utiliser ?

- **Solution unifiée** : Tout-en-un au lieu de configurer LDAP + Kerberos séparément
- **Interface web** : Administration via interface graphique
- **Enterprise-ready** : Solution robuste pour production
- **Gestion des politiques** : Contrôle d'accès centralisé

#### Installation

```bash
# Sur SUSE, utiliser le conteneur FreeIPA
docker run -d --name freeipa \
    -h ipa.cluster.local \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --tmpfs /run --tmpfs /tmp \
    -v /var/lib/ipa-data:/data:Z \
    freeipa/freeipa-server:centos-8-stream \
    ipa-server-install -U -r CLUSTER.LOCAL \
    -n cluster.local -p 'AdminPassword' \
    --admin-password 'AdminPassword'
```

---

## 📦 Gestion des Packages

### 1. Nexus Repository

#### Qu'est-ce que c'est ?

**Nexus Repository** est un gestionnaire de dépôts d'artefacts qui permet de créer un miroir privé pour :
- Packages Python (PyPI)
- Packages R (CRAN)
- Packages npm
- Packages Maven
- Etc.

#### Pourquoi l'utiliser ?

- **Air-gapped** : Fonctionne en environnement isolé
- **Performance** : Cache local = téléchargements plus rapides
- **Sécurité** : Contrôle des packages installés
- **Audit** : Traçabilité des packages utilisés

#### Comment ça fonctionne ?

```
pip install numpy
    │
    │ Requête vers Nexus (port 8081)
    ▼
Nexus Repository
    │
    ├─► Si package en cache : retourne directement
    │
    └─► Si pas en cache : télécharge depuis PyPI
        puis met en cache et retourne
```

#### Installation

**Via Docker** :
```bash
docker run -d --name nexus \
    -p 8081:8081 \
    -v nexus-data:/nexus-data \
    sonatype/nexus3
```

**Configuration pip** :
```bash
# ~/.pip/pip.conf
[global]
index-url = http://frontal-01:8081/repository/pypi-group/simple
trusted-host = frontal-01
```

#### Maintenance

**Vérification** :
```bash
curl http://frontal-01:8081/service/rest/v1/status
```

**Nettoyage du cache** :
```bash
# Via interface web : http://frontal-01:8081
# Administration > Repositories > Cleanup policies
```

---

### 2. Spack

#### Qu'est-ce que c'est ?

**Spack** est un gestionnaire de packages scientifique pour HPC qui permet de :
- Compiler des logiciels scientifiques
- Gérer plusieurs versions
- Gérer les dépendances
- Optimiser pour l'architecture

#### Pourquoi l'utiliser ?

- **Packages scientifiques** : OpenMPI, HDF5, NetCDF, etc.
- **Optimisation** : Compilation optimisée pour l'architecture
- **Versions multiples** : Plusieurs versions installées simultanément
- **Environnements** : Isolation des environnements

#### Installation

```bash
git clone https://github.com/spack/spack.git /opt/spack
. /opt/spack/share/spack/setup-env.sh
spack compiler find
```

#### Utilisation

**Installer un package** :
```bash
spack install openmpi@4.1.5
spack install hdf5@1.14.0
```

**Charger un package** :
```bash
spack load openmpi
mpirun --version
```

**Créer un environnement** :
```bash
spack env create myenv
spack env activate myenv
spack add openmpi hdf5
spack install
```

#### Maintenance

**Mise à jour** :
```bash
cd /opt/spack
git pull
spack reindex
```

**Nettoyage** :
```bash
spack clean -a  # Nettoie tout
spack clean -m  # Nettoie les miroirs
```

---

## 🖥️ Remote Graphics

### X2Go (Open-Source)

#### Qu'est-ce que c'est ?

**X2Go** est une solution de remote graphics open-source qui permet d'exécuter des applications graphiques sur le cluster et d'afficher l'interface sur un client distant via SSH.

#### Pourquoi l'utiliser ?

- **100% Gratuit** : Open-source, aucune licence requise
- **Applications graphiques** : ParaView, GROMACS, OpenFOAM, Quantum ESPRESSO
- **Performance** : Optimisé via SSH
- **Sécurité** : Chiffrement SSH intégré
- **Multi-utilisateurs** : Plusieurs sessions simultanées

#### Comment ça fonctionne ?

```
Client (Windows/Linux)
    │
    │ Connexion SSH avec X11 Forwarding
    ▼
X2Go Server (frontal-01)
    │
    │ Lance l'application graphique
    ▼
Application (ParaView, GROMACS, OpenFOAM, Quantum ESPRESSO)
    │
    │ Stream graphique via X11
    └─► Affiché sur le client
```

#### Installation

**Sur le serveur** :
```bash
cd cluster\ hpc/scripts/remote-graphics
sudo ./install-x2go.sh
```

**Configuration** :
```bash
# X2Go utilise SSH (port 22)
# Configuration automatique via script
```

#### Utilisation

**Lancer une application** :
```bash
# Sur le client (avec X11 Forwarding)
ssh -X user@frontal-01

# Dans la session SSH
paraview
```

#### Alternative : NoMachine

**NoMachine** est une alternative gratuite également disponible :
```bash
cd cluster\ hpc/scripts/remote-graphics
sudo ./install-nomachine.sh
```

**Connexion** : frontal-01:4000

---

## ⚡ Scheduler et Jobs

### Slurm Workload Manager

#### Qu'est-ce que c'est ?

**Slurm** (Simple Linux Utility for Resource Management) est un gestionnaire de jobs et de ressources pour clusters HPC.

#### Pourquoi l'utiliser ?

- **Gestion des ressources** : CPU, mémoire, GPU
- **File d'attente** : Gestion intelligente des jobs
- **Multi-utilisateurs** : Partage équitable des ressources
- **Standards** : Utilisé par la majorité des clusters HPC

#### Comment ça fonctionne ?

```
Utilisateur soumet un job
    │
    ▼
SlurmCTLD (Controller)
    │
    ├─► Vérifie les ressources disponibles
    ├─► Place dans la file d'attente
    └─► Lance sur les nœuds disponibles
        │
        ▼
    SlurmD (Daemon sur chaque nœud)
        │
        └─► Exécute le job
```

#### Soumission de Jobs

**Job simple** :
```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=01:00:00

srun my_program
```

**Soumission** :
```bash
sbatch myjob.sh
```

**Vérification** :
```bash
squeue -u $USER
sinfo
```

#### Maintenance

**Vérification** :
```bash
systemctl status slurmctld
scontrol show nodes
```

**Logs** :
```bash
tail -f /var/log/slurmctld.log
```

---

## 💾 Stockage

### BeeGFS (Système de Fichiers Parallèle Open-Source)

**Qu'est-ce que c'est ?**
- Système de fichiers parallèle open-source
- Optimisé pour HPC et calcul haute performance

**Pourquoi l'utiliser ?**
- ✅ **Performance** : Très rapide pour HPC (I/O parallèle)
- ✅ **Scalabilité** : Supporte des milliers de nœuds
- ✅ **Open-source** : Gratuit, pas de licence
- ✅ **Facilité** : Plus simple que Lustre

**Installation** :
```bash
./scripts/storage/install-beegfs.sh
```

**Alternative** : Lustre également disponible
```bash
./scripts/storage/install-lustre.sh
```

---

## 📊 Monitoring

### Prometheus + Grafana + Telegraf

Voir documentation dédiée dans `monitoring/README.md`

---

## 🔧 Provisioning

### TrinityX + Warewulf

Voir documentation dédiée dans `trinityx/GUIDE_INSTALLATION_TRINITYX.md`

---

## 📚 Ressources

- **LDAP 389DS**: https://directory.fedoraproject.org/
- **Kerberos**: https://web.mit.edu/kerberos/
- **FreeIPA**: https://www.freeipa.org/
- **Nexus**: https://www.sonatype.com/products/nexus-repository
- **Spack**: https://spack.io/
- **X2Go**: https://wiki.x2go.org/
- **NoMachine**: https://www.nomachine.com/
- **Slurm**: https://slurm.schedmd.com/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
