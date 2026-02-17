# 🏗️ ARCHITECTURE ET CHOIX DE CONCEPTION
## Pourquoi Cette Architecture ? Pourquoi Ces Technologies ?

**Classification**: Documentation Architecture  
**Public**: Architectes / Ingénieurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Architecture Globale](#1-architecture-globale)
2. [Choix d'Architecture](#2-choix-darchitecture)
3. [Choix Technologiques Détaillés](#3-choix-technologiques-détaillés)
4. [Structure du Projet](#4-structure-du-projet)
5. [Justifications des Décisions](#5-justifications-des-décisions)
6. [Alternatives Considérées](#6-alternatives-considérées)
7. [Évolutivité et Scalabilité](#7-évolutivité-et-scalabilité)

---

## 1. Architecture Globale

### 1.1 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COUCHE MANAGEMENT                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  LDAP    │  │ Kerberos │  │Prometheus│  │  Grafana │           │
│  │ (389DS)  │  │   KDC    │  │          │  │          │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Slurm  │  │  BeeGFS  │  │  Nexus   │  │  X2Go    │           │
│  │  CTLD   │  │   MGMtd  │  │ (PyPI)   │  │ (Remote) │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│                    (frontal-01, frontal-02)                        │
└─────────────────────────────────────────────────────────────────────┘
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

### 1.2 Composants par Couche

#### Couche Management (Frontaux)
- **Authentification** : LDAP, Kerberos
- **Scheduler** : SlurmCTLD
- **Stockage** : BeeGFS MGMtd
- **Monitoring** : Prometheus, Grafana
- **Packages** : Nexus
- **Remote Graphics** : X2Go

#### Couche Calcul (Compute)
- **Scheduler** : SlurmD
- **Stockage** : BeeGFS Client
- **Packages** : Spack
- **Applications** : GROMACS, OpenFOAM, etc.

#### Couche Réseau
- **Management** : 172.20.0.0/24 (SSH, LDAP, Slurm)
- **Cluster** : 10.0.0.0/24 (MPI)
- **Storage** : 10.10.10.0/24 (BeeGFS)
- **Monitoring** : 192.168.200.0/24 (Prometheus, Grafana)

---

## 2. Choix d'Architecture

### 2.1 Pourquoi Docker ?

**Décision** : Utiliser Docker pour conteneurisation

**Justification** :
1. **Portabilité** : Fonctionne identiquement partout
2. **Reproductibilité** : Même environnement dev/test/prod
3. **Isolation** : Chaque service isolé
4. **Facilité** : Un seul fichier docker-compose.yml
5. **Air-gapped** : Peut fonctionner sans Internet

**Alternatives rejetées** :
- ❌ **VMs** : Trop lourd, démarrage lent, plus de ressources
- ❌ **Installation native** : Difficile à reproduire, dépendances complexes

**Résultat** : Architecture portable et reproductible

---

### 2.2 Pourquoi 2 Frontaux + 6 Compute ?

**Décision** : Architecture 2 frontaux + 6 compute

**Justification** :
1. **Haute disponibilité** : Redondance des frontaux
2. **Scalabilité** : Facile d'ajouter des compute
3. **Équilibrage** : Charge répartie
4. **Réaliste** : Représente un vrai cluster

**Alternatives considérées** :
- ❌ **1 frontal** : Pas de redondance
- ❌ **3+ frontaux** : Overkill pour démo
- ❌ **Moins de compute** : Pas assez réaliste

**Résultat** : Architecture équilibrée et réaliste

---

### 2.3 Pourquoi 4 Réseaux Séparés ?

**Décision** : 4 réseaux Docker séparés

**Justification** :
1. **Sécurité** : Isolation des réseaux
2. **Performance** : Pas de congestion
3. **Clarté** : Séparation logique
4. **Réalisme** : Représente un vrai cluster

**Réseaux** :
- **Management** : Services de gestion
- **Cluster** : Communication MPI
- **Storage** : Stockage haute performance
- **Monitoring** : Monitoring isolé

**Résultat** : Architecture sécurisée et performante

---

## 3. Choix Technologiques Détaillés

### 3.1 Scheduler : Slurm vs PBS/Torque

**Décision** : Slurm

**Justification** :
- ✅ Standard moderne (60%+ des clusters)
- ✅ Plus de fonctionnalités
- ✅ Meilleure performance
- ✅ Communauté très active
- ✅ Open-source

**Alternatives rejetées** :
- ❌ **PBS/Torque** : Moins moderne, moins de fonctionnalités
- ❌ **LSF** : Commercial, licence coûteuse
- ❌ **Kubernetes** : Pas optimisé pour HPC

**Résultat** : Scheduler moderne et performant

---

### 3.2 Stockage : BeeGFS vs GPFS vs Lustre

**Décision** : BeeGFS

**Justification** :
- ✅ Open-source (gratuit)
- ✅ Plus simple que Lustre
- ✅ Performance excellente
- ✅ Communauté active

**Alternatives rejetées** :
- ❌ **GPFS** : Commercial, licence coûteuse
- ❌ **Lustre** : Plus complexe, plus de ressources
- ❌ **GlusterFS** : Moins performant pour HPC

**Résultat** : Stockage open-source performant

---

### 3.3 Authentification : LDAP+Kerberos vs FreeIPA

**Décision** : LDAP + Kerberos (séparés)

**Justification** :
- ✅ Plus simple
- ✅ Plus de contrôle
- ✅ Composants séparés (flexibilité)
- ✅ Moins de dépendances

**Alternatives considérées** :
- **FreeIPA** : Plus complexe, tout-en-un (moins flexible)

**Résultat** : Authentification simple et flexible

---

### 3.4 Monitoring : Prometheus vs Nagios vs Zabbix

**Décision** : Prometheus + Grafana

**Justification** :
- ✅ Standard moderne
- ✅ Pull-based (plus efficace)
- ✅ Time-series optimisé
- ✅ PromQL puissant
- ✅ Écosystème énorme

**Alternatives rejetées** :
- ❌ **Nagios** : Plus ancien, push-based
- ❌ **Zabbix** : Plus complexe
- ❌ **Datadog** : Commercial, coûteux

**Résultat** : Monitoring moderne et performant

---

## 4. Structure du Projet

### 4.1 Organisation des Dossiers

**Décision** : Structure modulaire par fonction

```
cluster hpc/
├── docker/              # Tout Docker
├── configs/             # Toutes configurations
├── scripts/             # Tous scripts (par catégorie)
├── docs/                # Toute documentation
├── grafana-dashboards/  # Tous dashboards
└── examples/            # Tous exemples
```

**Justification** :
- ✅ **Séparation des préoccupations** : Chaque dossier a un rôle
- ✅ **Facilité de navigation** : Logique et intuitive
- ✅ **Facilité de maintenance** : Facile à trouver les fichiers
- ✅ **Facilité d'extension** : Facile d'ajouter de nouveaux composants

**Alternatives considérées** :
- ❌ **Tout à la racine** : Trop de fichiers, confusion
- ❌ **Par technologie** : Duplication, moins logique

**Résultat** : Structure claire et maintenable

---

### 4.2 Pourquoi `configs/` à la Racine ?

**Décision** : `configs/` à la racine (pas dans `docker/`)

**Justification** :
- ✅ **Partagé** : Utilisé par Docker ET installation native
- ✅ **Centralisé** : Toutes les configs au même endroit
- ✅ **Clarté** : Facile à trouver

**Alternatives considérées** :
- **`docker/configs/`** : Mais alors duplication si installation native

**Résultat** : Configs centralisées et partagées

---

## 5. Justifications des Décisions

### 5.1 Pourquoi 100% Open-Source ?

**Décision** : Tous les composants open-source

**Justification** :
1. **Coût** : Aucune licence à payer
2. **Liberté** : Pas de dépendance à un fournisseur
3. **Communauté** : Support communautaire
4. **Transparence** : Code source disponible
5. **Évolutivité** : Peut être modifié si nécessaire

**Composants commerciaux remplacés** :
- ❌ **MATLAB** → ✅ GROMACS, OpenFOAM, Quantum ESPRESSO
- ❌ **GPFS** → ✅ BeeGFS, Lustre
- ❌ **Exceed TurboX** → ✅ X2Go, NoMachine
- ❌ **FlexLM** → ✅ Supprimé (plus nécessaire)

**Résultat** : Cluster 100% open-source et gratuit

---

### 5.2 Pourquoi SUSE 15 SP4 ?

**Décision** : openSUSE Leap 15.4 (compatible SUSE 15 SP4)

**Justification** :
1. **Compatible SLES** : Même base que SUSE Enterprise
2. **Stable** : Version LTS
3. **Enterprise** : Utilisé en production
4. **Zypper** : Excellent gestionnaire de packages

**Alternatives considérées** :
- ❌ **CentOS/RHEL** : Moins compatible avec SUSE
- ❌ **Ubuntu** : Différent (apt vs zypper)

**Résultat** : Compatibilité maximale avec SUSE Enterprise

---

### 5.3 Pourquoi Docker Compose ?

**Décision** : Docker Compose pour orchestration

**Justification** :
1. **Simplicité** : Un seul fichier YAML
2. **Standard** : Utilisé partout
3. **Facilité** : Pas besoin de Kubernetes pour ce cas
4. **Suffisant** : Parfait pour cluster de taille moyenne

**Alternatives considérées** :
- ❌ **Kubernetes** : Overkill pour 8 nœuds, plus complexe
- ❌ **Ansible** : Pas pour orchestration conteneurs

**Résultat** : Orchestration simple et efficace

---

## 6. Alternatives Considérées

### 6.1 Tableau Comparatif

| Composant | Choix Final | Alternatives Rejetées | Raison |
|-----------|-------------|----------------------|--------|
| Conteneurisation | Docker | VMs, LXC | Portabilité, légèreté |
| Scheduler | Slurm | PBS, LSF, Kubernetes | Standard HPC, open-source |
| Stockage | BeeGFS | GPFS, Lustre, GlusterFS | Open-source, simplicité |
| Authentification | LDAP+Kerberos | FreeIPA, AD | Simplicité, contrôle |
| Monitoring | Prometheus | Nagios, Zabbix, Datadog | Standard moderne, open-source |
| OS | openSUSE 15.4 | CentOS, Ubuntu | Compatibilité SUSE |
| Orchestration | Docker Compose | Kubernetes | Simplicité, suffisant |

---

## 7. Évolutivité et Scalabilité

### 7.1 Comment Ajouter des Nœuds ?

**Ajouter un compute** :
1. Ajouter dans `docker-compose-opensource.yml`
2. Ajouter dans `configs/slurm/slurm.conf`
3. Ajouter dans `configs/prometheus/prometheus.yml`
4. Redémarrer

**Ajouter un frontal** :
1. Ajouter dans `docker-compose-opensource.yml`
2. Configurer réplication (LDAP, Slurm)
3. Ajouter dans monitoring

---

### 7.2 Comment Scalabiliser ?

**Stockage** :
- Ajouter des Storage Targets BeeGFS
- Scalable jusqu'à pétaoctets

**Calcul** :
- Ajouter des nœuds compute
- Scalable jusqu'à milliers de nœuds

**Monitoring** :
- Prometheus peut scaler (fédération)
- Grafana peut scaler (HA)

---

## 📚 Documentation Complémentaire

- `docs/ARCHITECTURE.md` - Architecture détaillée
- `docs/DOCUMENTATION_COMPLETE_MASTER.md` - Documentation master
- `docs/GUIDE_COMPLET_TOUTES_TECHNOLOGIES.md` - Toutes technologies

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
