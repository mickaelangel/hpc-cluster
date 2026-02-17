# Architecture du Cluster HPC
## Documentation Technique Complète

**Classification**: Documentation Technique  
**Public**: Architectes / Ingénieurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture Générale](#architecture-générale)
3. [Composants](#composants)
4. [Flux de Données](#flux-de-données)
5. [Réseau](#réseau)
6. [Sécurité](#sécurité)

---

## 🎯 Vue d'ensemble

Le cluster HPC est une infrastructure de calcul haute performance avec :
- **2 nœuds frontaux** : Services de management et stockage
- **6 nœuds de calcul** : Exécution des jobs
- **Stockage partagé** : BeeGFS / Lustre (50 TB)
- **Authentification centralisée** : LDAP + Kerberos ou FreeIPA
- **Scheduler** : Slurm
- **Monitoring** : Prometheus, Grafana, InfluxDB, Telegraf

---

## 🏗️ Architecture Générale

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
│  + GPFS      │  │  + GPFS      │  │  + GPFS      │
│  + Spack     │  │  + Spack     │  │  + Spack     │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🔧 Composants

### Nœuds Frontaux

**frontal-01** (Primary) :
- LDAP (389 Directory Server)
- Kerberos KDC
- Slurm Controller (SlurmCTLD)
- Slurm Database (SlurmDBD)
- BeeGFS MGMtd (Management)
- BeeGFS Storage Target
- Prometheus
- Grafana
- Nexus Repository
- X2Go Server

**frontal-02** (Secondary) :
- LDAP Replica (optionnel)
- Slurm Controller Standby
- BeeGFS Storage Target
- Monitoring (Telegraf)

### Nœuds de Calcul

**compute-01 à compute-06** :
- Slurm Worker (Slurmd)
- BeeGFS Client
- Spack
- Applications HPC

---

## 📊 Flux de Données

### Authentification

```
Utilisateur
    │
    ├─► LDAP (vérification identité)
    │
    ├─► Kerberos (obtention ticket)
    │
    └─► Accès autorisé
```

### Soumission de Job

```
Utilisateur
    │
    ├─► sbatch/srun
    │
    ├─► SlurmCTLD (frontal-01)
    │
    ├─► SlurmDBD (enregistrement)
    │
    ├─► Slurmd (compute-XX)
    │
    └─► Exécution job
```

### Stockage

```
Application
    │
    ├─► BeeGFS Client
    │
    ├─► BeeGFS MGMtd (métadonnées)
    │
    ├─► BeeGFS Storage Targets (frontal-01/02)
    │
    └─► Données stockées (I/O parallèle)
```

---

## 🌐 Réseau

### Réseaux Configurés

1. **Management (172.20.0.0/24)** :
   - SSH, LDAP, Kerberos, Slurm
   - Communication inter-nœuds

2. **Cluster (10.0.0.0/24)** :
   - Communication MPI
   - Jobs parallèles

3. **Storage (10.10.10.0/24)** :
   - BeeGFS (simulation IPoIB)
   - Haute performance I/O

4. **Monitoring (192.168.200.0/24)** :
   - Prometheus, Grafana
   - Collecte métriques

---

## 🔒 Sécurité

### Couches de Sécurité

1. **Authentification** :
   - LDAP (identité)
   - Kerberos (tickets)

2. **Autorisation** :
   - PAM
   - SSSD

3. **Protection** :
   - Fail2ban (SSH, Slurm)
   - Auditd (audit système)
   - AIDE (intégrité fichiers)

4. **Chiffrement** :
   - SSH (GSSAPI)
   - LDAPS (port 636)

---

## 📈 Dimensionnement

### Ressources Recommandées

**Frontaux** :
- CPU : 4+ cœurs
- RAM : 16GB+
- Disque : 100GB+ (système) + stockage GPFS

**Compute** :
- CPU : 2+ cœurs
- RAM : 8GB+
- Disque : 50GB+ (système)

**Stockage BeeGFS** :
- Capacité : 50 TB
- Performance : Haute (SSD recommandé)
- Alternative : Lustre disponible

---

## 🔄 Haute Disponibilité

### Composants Redondants

- **LDAP** : Réplication
- **Slurm** : Controller standby
- **BeeGFS** : Storage Targets multiples
- **Monitoring** : Redondance optionnelle

---

## 📚 Ressources

- **Slurm Architecture** : https://slurm.schedmd.com/overview.html
- **BeeGFS Architecture** : https://www.beegfs.io/docs/
- **LDAP Architecture** : https://directory.fedoraproject.org/docs/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
