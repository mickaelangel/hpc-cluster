# 📚 Cours HPC Complet — Master Data Science / Doctorat

> **Formation exhaustive Calcul Haute Performance — Niveau DevOps Senior & Recherche**

---

## 🎯 Objectifs pédagogiques

À l'issue de ce cours, vous maîtriserez :

- Les **concepts fondamentaux** du calcul haute performance (HPC)
- L’**architecture** des clusters et supercalculateurs
- Les **technologies** (schedulers, MPI, stockage parallèle, réseau)
- Le **fonctionnement** d’un cluster de bout en bout
- Les **bonnes pratiques** pour jobs, performances et coûts

**Public** : Étudiants Master Data Science, Doctorat, ingénieurs et administrateurs HPC.

---

## 1. Introduction au calcul haute performance (HPC)

### 1.1 Qu’est-ce que le HPC ?

Le **calcul haute performance** (High Performance Computing) regroupe :

- L’utilisation de **plusieurs processeurs** (ou cœurs) pour résoudre un problème plus vite
- L’utilisation de **plusieurs nœuds** (machines) reliés par un réseau rapide
- L’optimisation du **code** et des **données** pour tirer parti du parallélisme

**Domaines typiques** : simulation (climat, physique, chimie), intelligence artificielle / deep learning, génomique, finance, ingénierie (CFD, éléments finis).

### 1.2 Parallélisme : concepts de base

| Type | Description | Exemple |
|------|-------------|--------|
| **Parallélisme de données** | Même code, données différentes (SIMD, data parallelism) | Entraînement ML sur plusieurs GPU |
| **Parallélisme de tâches** | Tâches indépendantes en parallèle | Embarrassingly parallel jobs |
| **Parallélisme à mémoire partagée** | Threads sur un nœud (OpenMP) | Boucles parallèles sur un serveur |
| **Parallélisme à mémoire distribuée** | Processus sur plusieurs nœuds (MPI) | Simulation multi-nœuds |

### 1.3 Métriques clés

- **Speedup** : \( S(n) = T(1) / T(n) \) (temps sur 1 processeur / temps sur n processeurs)
- **Efficacité** : \( E(n) = S(n) / n \)
- **Scalabilité** : comportement de S(n) et E(n) quand n augmente (forte/faible scalabilité)
- **Flops** : opérations en virgule flottante par seconde (FLOPS, GFLOPS, TFLOPS, PFLOPS)

---

## 2. Architecture des clusters HPC

### 2.1 Composants d’un cluster

```
                    ┌─────────────────────────────────────────┐
                    │           RÉSEAU UTILISATEURS           │
                    │              (Internet / LAN)            │
                    └───────────────────┬─────────────────────┘
                                        │
                    ┌───────────────────▼─────────────────────┐
                    │  NŒUDS FRONTAUX (Login / Management)     │
                    │  - Authentification (LDAP, Kerberos)    │
                    │  - Scheduler (Slurm controller)          │
                    │  - NFS / home, soumission de jobs        │
                    └───────────────────┬─────────────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │                               │                               │
        ▼                               ▼                               ▼
┌───────────────┐             ┌───────────────┐             ┌───────────────┐
│ RÉSEAU CALCUL │             │ RÉSEAU STOCKAGE│             │ RÉSEAU MGMT   │
│ (Interconnect) │             │ (Storage)      │             │ (Admin)       │
│ InfiniBand/    │             │ 10G/25G/100G   │             │ 1G/10G        │
│ Ethernet RoCE  │             │                │             │               │
└───────┬───────┘             └───────┬───────┘             └───────┬───────┘
        │                             │                             │
        ▼                             ▼                             ▼
┌───────────────┐             ┌───────────────┐             ┌───────────────┐
│ NŒUDS DE CALCUL│             │ SYSTÈMES       │             │ MONITORING    │
│ (Compute nodes)│             │ FICHIERS       │             │ Prometheus,   │
│ - CPU / GPU    │             │ Lustre, BeeGFS,│             │ Grafana, etc. │
│ - Mémoire      │             │ NFS, Ceph      │             │               │
└───────────────┘             └───────────────┘             └───────────────┘
```

### 2.2 Rôles des nœuds

| Rôle | Rôle | Exemple |
|------|------|--------|
| **Frontal (login)** | Connexion SSH, édition, soumission de jobs, compilation | frontend01, frontend02 |
| **Contrôleur** | Scheduler (Slurm controller), gestion des jobs et nœuds | Souvent sur un frontal |
| **Calcul (compute)** | Exécution des jobs uniquement, pas de login direct | compute01..compute06 |
| **Stockage** | Serveurs de fichiers parallèles (metadata + data) | MDS, OSS (Lustre), etc. |

### 2.3 Réseaux dans un cluster

- **Réseau de management** : administration, monitoring, PXE, NFS racine.
- **Réseau de calcul (interconnect)** : communication MPI, faible latence, haut débit (InfiniBand, Ethernet 10G/25G/100G, RoCE).
- **Réseau de stockage** : trafic vers systèmes de fichiers parallèles (Lustre, BeeGFS, etc.).

---

## 3. Ordonnancement des jobs : rôle du scheduler

### 3.1 Pourquoi un scheduler ?

- **Partage équitable** des ressources entre utilisateurs et projets
- **File d’attente** : les jobs en attente sont ordonnancés selon politiques (priorité, QoS, fair-share)
- **Éviter la surcharge** : pas d’exécution directe sur les nœuds de calcul par les utilisateurs

### 3.2 Schedulers courants

| Scheduler | Usage typique | Points forts |
|-----------|----------------|--------------|
| **Slurm** | Très répandu (académique, labs, cloud HPC) | Open source, riche, communauté active |
| **PBS Pro / OpenPBS** | Enterprise, certains centres nationaux | Politiques avancées, support commercial |
| **SGE / Univa Grid Engine** | Historique, certains clusters | Compatibilité legacy |
| **LSF** | Enterprise (IBM) | Intégration écosystème IBM |

Dans ce projet, le scheduler utilisé est **Slurm**. Voir [Guide-SLURM-Complet](Guide-SLURM-Complet).

### 3.3 Cycle de vie d’un job

1. **Soumission** : `sbatch script.sh` ou `srun` (interactif)
2. **File d’attente** : le job est **PENDING** jusqu’à attribution de ressources
3. **Allocation** : le scheduler alloue nœuds/CPU/GPU/mémoire
4. **Exécution** : le job passe en **RUNNING**
5. **Fin** : **COMPLETED**, **FAILED**, **CANCELLED**, **TIMEOUT**, etc.

---

## 4. Programmation parallèle : MPI et OpenMP

### 4.1 MPI (Message Passing Interface)

- **Modèle** : mémoire distribuée, communication par messages entre processus.
- **Utilisation** : applications qui s’exécutent sur **plusieurs nœuds** (plusieurs processus, souvent 1 par cœur ou par nœud).
- **Implémentations** : OpenMPI, Intel MPI, MPICH, MVAPICH (InfiniBand).

**Concepts** : communicateur, rang, envoi/réception (point-à-point), collectives (broadcast, reduce, scatter, gather), types dérivés.

### 4.2 OpenMP

- **Modèle** : mémoire partagée, parallélisme de boucles et de régions sur **un seul nœud** (multi-threads).
- **Utilisation** : parallélisme à l’intérieur d’un nœud ; souvent combiné avec MPI (MPI entre nœuds, OpenMP dans le nœud = hybride MPI+OpenMP).

### 4.3 Modèle hybride MPI + OpenMP

- **MPI** : un processus par nœud (ou par socket) pour la communication inter-nœuds.
- **OpenMP** : plusieurs threads par processus pour utiliser tous les cœurs du nœud.
- Réduit le volume de messages MPI et peut améliorer les performances sur des nœuds multi-cœurs.

---

## 5. Stockage et systèmes de fichiers

### 5.1 Hiérarchie typique

| Espace | Usage | Caractéristiques |
|--------|--------|-------------------|
| **Home** | Répertoire personnel, petits fichiers, sauvegardes | NFS, quotas, sauvegardes |
| **Scratch / work** | Données temporaires de calcul, gros I/O | Fichier parallèle, haute bande passante, purge |
| **Project / shared** | Données de projet partagées | NFS ou parallèle selon taille |
| **Local** | Disque local nœud (si présent) | Très rapide, non partagé, éphémère |

### 5.2 Systèmes de fichiers parallèles

| Système | Modèle | Points forts |
|---------|--------|--------------|
| **Lustre** | Parallèle, metadata servers + object storage servers | Très gros débits, très répandu en HPC |
| **BeeGFS** | Parallèle, metadata + storage servers | Installation plus simple, bon pour clusters moyens |
| **GlusterFS** | Distribué, pas de metadata central | Scalable, réplication |
| **Ceph** | Objet (object storage) + interfaces bloc/fichier | Unifié bloc/fichier/objet, réplication |
| **NFS** | Centralisé | Simple, pour home et petits partages |

### 5.3 Bonnes pratiques I/O

- Privilégier les **gros transferts séquentiels** plutôt que beaucoup de petits fichiers
- Utiliser **scratch** pour les gros I/O et **ne pas** y garder les seules copies
- Éviter les accès très petits et aléatoires sur un système parallèle partagé
- Utiliser les **API parallèles** (MPI-IO, HDF5 parallèle, NetCDF) quand c’est possible

---

## 6. GPU et accélération

### 6.1 Rôle des GPU en HPC

- **Calcul vectoriel/matrice** : algèbre linéaire, deep learning, simulations ciblées
- **Modèle** : beaucoup de cœurs légers, mémoire dédiée (VRAM), transferts CPU–GPU à minimiser

### 6.2 Environnements courants

- **CUDA** (NVIDIA) : langage et librairies (cuBLAS, cuDNN, etc.)
- **ROCm** (AMD) : équivalent pour GPU AMD
- **oneAPI / SYCL** : approche plus portable (Intel, NVIDIA, AMD)

### 6.3 Intégration avec le scheduler

- Slurm gère les **GPU** comme ressource (Generic Resource, `--gres=gpu:n` ou `--gres=gpu:type:n`).
- Variables d’environnement typiques : `CUDA_VISIBLE_DEVICES`, `GPU_DEVICE_ORDINAL` (selon configuration).

---

## 7. Conteneurs et HPC

### 7.1 Intérêt des conteneurs en HPC

- **Reproductibilité** : même environnement (libs, versions) sur tout le cluster
- **Portabilité** : image unique pour dev, test et production
- **Isolation** : pas de conflit entre versions d’outils ou de librairies

### 7.2 Outils

- **Docker** : build et partage d’images (souvent utilisé en dehors des nœuds de calcul)
- **Singularity / Apptainer** : conçu pour HPC (pas de démon root, support MPI, GPU)
- **Podman** : alternative à Docker, rootless

Sur un cluster Slurm, les jobs GPU ou MPI utilisent en général **Singularity/Apptainer** pour lancer l’image sur les nœuds alloués.

---

## 8. Sécurité et bonnes pratiques

- **Authentification centralisée** : LDAP, Kerberos ou FreeIPA
- **Quotas** : CPU-heures, nombre de jobs, taille stockage
- **Politiques** : limites par partition, par QoS, fair-share
- **Audit** : logs de soumission, d’exécution et d’accès aux données sensibles
- **Mise à jour** : correctifs sécurité sur OS, scheduler et logiciels critiques

---

## 9. Monitoring et observabilité

- **Métriques** : utilisation CPU/RAM/GPU, files d’attente, taux de succès des jobs
- **Outils** : Prometheus (métriques), Grafana (tableaux de bord), éventuellement InfluxDB, Loki pour les logs
- **Alertes** : nœuds down, files d’attente anormalement longues, panne de stockage

Voir [Monitoring](Monitoring) et [Commandes-Utiles](Commandes-Utiles).

---

## 10. Synthèse et suite

Ce cours pose les bases **conceptuelles** et **architecturales** du HPC. Pour aller plus loin dans ce projet :

- **[Guide-SLURM-Complet](Guide-SLURM-Complet)** : utilisation avancée de Slurm (partitions, QoS, script sbatch, bonnes pratiques)
- **[Glossaire-et-Acronymes](Glossaire-et-Acronymes)** : définitions et acronymes (HPC, MPI, Slurm, Lustre, etc.)
- **[Configuration-de-Base](Configuration-de-Base)** : déploiement concret du cluster
- **[Commandes-Utiles](Commandes-Utiles)** : commandes de référence (Slurm, monitoring, dépannage)

---

**Niveau** : Master / Doctorat / DevOps Senior  
**Dernière mise à jour** : 2024
