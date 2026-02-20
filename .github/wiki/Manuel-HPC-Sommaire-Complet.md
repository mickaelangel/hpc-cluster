# 📚 Manuel d'architecture et d'ingénierie HPC : de la théorie à la production

**Sommaire général de l'ouvrage**

> **Estimation globale** : ~620 à 720 pages (9 volumes, hors Dictionnaire encyclopédique et Glossaire).  
> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système et recherche.

---

## 🏗️ Découpage en volumes et plan détaillé

---

### VOLUME 1 : Fondations, architecture de base et provisioning DevOps  
**~60 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 1** | Introduction au HPC moderne et co-design | Définitions, typologies CPU / GPU / I-O heavy, les 3 architectures types. |
| **Ch. 2** | Bases matérielles et topologies | Serveurs, nœuds de calcul vs login vs management, BMC / IPMI / Redfish. |
| **Ch. 3** | Provisioning bare-metal | Cycle de vie d'un nœud, PXE, DHCP, TFTP, solutions type Warewulf / xCAT / MAAS. |
| **Ch. 4** | Configuration Management & GitOps | Ansible en environnement HPC, gestion d'état, infrastructure as code. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 1](Manuel-Architecture-HPC-Volume1)

---

### VOLUME 2 : Réseaux datacenter, interconnexions et sécurité  
**~70 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 5** | Réseaux de management et de stockage | Ethernet, MLAG, Spine-Leaf, Jumbo Frames. |
| **Ch. 6** | Interconnexions à faible latence | InfiniBand, RoCE v2, topologies Fat-Tree / Dragonfly, subnet manager. |
| **Ch. 7** | Fondations de sécurité HPC | IAM, LDAP / FreeIPA, bastion, durcissement OS, segmentation réseau, gestion des secrets. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 2](Manuel-Architecture-HPC-Volume2)

---

### VOLUME 3 : Stockage parallèle et gestion des données (Deep Dive Lustre)  
**~90 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 8** | Architecture du stockage HPC | Concepts POSIX parallèles, hiérarchisation, scratch vs project vs archive. |
| **Ch. 9** | Lustre — Les entrailles (Internals) | MGS, MDT, OST, LNet, DNE, HSM. |
| **Ch. 10** | Déploiement, tuning et opérations Lustre | Configuration optimale, gestion des stripes, quotas, failover / HA, recovery. |
| **Ch. 11** | Panorama des alternatives | BeeGFS, GPFS / Spectrum Scale, CephFS, S3 en HPC. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 3](Manuel-Architecture-HPC-Volume3)

---

### VOLUME 4 : Ordonnancement, gestion des ressources et Slurm  
**~90 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 12** | Théorie de l'ordonnancement HPC | Fairshare, backfill, preemption, throughput vs latency. |
| **Ch. 13** | Slurm — Architecture et déploiement | slurmctld, slurmd, slurmdbd, haute disponibilité. |
| **Ch. 14** | Configuration avancée de Slurm | Partitions, QOS, cgroups, GRES pour GPU, topology-aware placement, job arrays. |
| **Ch. 15** | Exploitation et troubleshooting Slurm | Accounting, upgrades, résolution d'incidents courants. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 4](Manuel-Architecture-HPC-Volume4) — **Référence** : [Guide SLURM Complet](Guide-SLURM-Complet)

---

### VOLUME 5 : Environnements utilisateurs, MPI et accélération GPU  
**~80 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 16** | Toolchains et modules | Spack, EasyBuild, Lmod, conteneurs Apptainer / Singularity. |
| **Ch. 17** | Parallélisme et MPI (Deep Dive) | Sémantique, collectives, rank mapping, RDMA, OpenMPI / MPICH, UCX. |
| **Ch. 18** | Accélération GPU et IA | CUDA / ROCm, architecture multi-GPU, NCCL, GPUDirect, binding CPU / GPU. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 5](Manuel-Architecture-HPC-Volume5)

---

### VOLUME 6 : Ingénierie des performances et benchmarking  
**~70 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 19** | Architecture mémoire et optimisation | NUMA, affinité, hugepages, caches. |
| **Ch. 20** | Méthodologie de profiling | Instrumentation, goulots d'étranglement, perf, NSight, Score-P / TAU. |
| **Ch. 21** | Benchmarking en production | HPL, HPCG, IOR, mdtest, OSU micro-benchmarks — méthodologie et interprétation critique. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 6](Manuel-Architecture-HPC-Volume6)

---

### VOLUME 7 : Observabilité, MCO et incidentologie  
**~70 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 22** | Stack d'observabilité HPC | Prometheus, Grafana, exporters Slurm / Lustre, centralisation des logs. |
| **Ch. 23** | Capacity planning et SLA | Suivi des métriques clés, prévision de charge, refacturation / showback. |
| **Ch. 24** | Runbooks, on-call et post-mortems | Gestion de crise, RCA, procédures opérationnelles standard (SOP). |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 7](Manuel-Architecture-HPC-Volume7) — **Référence** : [Monitoring](Monitoring)

---

### VOLUME 8 : Le fil rouge « De zéro à la prod » et tendances  
**~50 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 25** | Projet complet guidé | Reprise des jalons : design → install → intégration → tests → mise en prod. |
| **Ch. 26** | Hybridation cloud et avenir du HPC | Cloud bursting, convergence IA / HPC, défis exascale. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 8](Manuel-Architecture-HPC-Volume8)

---

### VOLUME 9 : Data Science & Machine Learning sur cluster HPC  
**~70 pages**

| Chapitre | Titre | Contenu principal |
|----------|--------|-------------------|
| **Ch. 27** | Workloads Data/ML — data locality, I/O et formats | Formats (Parquet, Zarr, HDF5, WebDataset), sharding, cache NVMe, checkpoints. |
| **Ch. 28** | Entraînement distribué sur Slurm (DDP, NCCL) | PyTorch DDP multi-nœuds, template sbatch, debug NCCL, scaling study. |
| **Ch. 29** | Orchestration à l'échelle | Job arrays, Submitit, Optuna, Ray/Dask/Spark sur Slurm, anti-patterns. |
| **Ch. 30** | Reproductibilité, MLOps on-prem, perf-to-solution | Env + données + code, tracking (MLflow), profiling, métriques métier. |

➡️ **Cours détaillé** : [Manuel Architecture HPC — Volume 9](Manuel-Architecture-HPC-Volume9)

---

## 🧪 Liste des labs (travaux pratiques)

| Lab | Volume | Sujet |
|-----|--------|--------|
| **Lab 1** | Vol. 1 | Provisioning d'un mini-cluster virtuel (1 master, 2 computes) via Ansible et Warewulf. |
| **Lab 2** | Vol. 2 | Configuration d'un annuaire FreeIPA et intégration des nœuds de calcul (SSSD, sudoers). |
| **Lab 3** | Vol. 3 | Déploiement d'un mini-Lustre (1 MGS/MDT, 2 OST) sur LNet TCP, montage client et tests de striping. |
| **Lab 4** | Vol. 4 | Installation de Slurm + SlurmDBD, hiérarchie de comptes (Fairshare) et tests de backfill. |
| **Lab 5** | Vol. 4 | Configuration des cgroups v2 et GRES virtuels pour l'isolation des jobs. |
| **Lab 6** | Vol. 5 | Compilation MPI avec Spack, module Lmod, exécution d'un job MPI multi-nœuds. |
| **Lab 7** | Vol. 5 | Build d'un conteneur Apptainer pour une charge ML (PyTorch) et lancement via Slurm. |
| **Lab 8** | Vol. 6 | Exécution et interprétation de la suite OSU Micro-Benchmarks pour valider la topologie MPI. |
| **Lab 9** | Vol. 6 | Benchmarking I/O avec IOR sur le point de montage Lustre (tuning taille de transfert). |
| **Lab 10** | Vol. 7 | Déploiement de l'exportateur Prometheus pour Slurm et dashboard Grafana de base. |
| **Lab 11** | Vol. 8 | Étude de cas « Architecture & Design » (exercice sur table : budget, WRF, 200 kW). |
| **Lab 12** | Vol. 9 | PyTorch DDP multi-nœuds via Slurm + Apptainer, debugging NCCL, scaling. |
| **Lab 13** | Vol. 9 | Recherche d'hyperparamètres (Submitit + Optuna), agrégation de résultats. |

---

## 🕵️ Liste des études de cas (cas d'usage / incidents)

### Cas d'usage

| Réf. | Sujet |
|------|--------|
| **Cas A** | Dimensionnement d'un cluster « Data-Intensive » pour la génomique (beaucoup de petits fichiers, I/O aléatoires). |
| **Cas B** | Architecture réseau « Spine-Leaf non bloquante » pour un cluster d'entraînement IA (GPU-heavy, trafic Est-Ouest massif). |

### Incidents (analyse et résolution)

| Réf. | Sujet |
|------|--------|
| **Incident 1** | *Le syndrome du MDS surchargé* — Lustre s'effondre sous une tempête de métadonnées causée par un job utilisateur mal codé. |
| **Incident 2** | *Le job fantôme* — Un nœud Slurm en état drain perpétuel à cause d'un processus zombie échappant aux cgroups. |
| **Incident 3** | *La congestion réseau silencieuse* — Baisse de 40 % des performances MPI (mauvais routage InfiniBand / manque de topology awareness). |

---

## 📎 Liste des annexes

| Annexe | Contenu |
|--------|--------|
| **Annexe A** | Cheatsheet Slurm (commandes admin et user). |
| **Annexe B** | Cheatsheet Lustre (commandes `lfs`, gestion des OST, `lctl`). |
| **Annexe C** | Cheatsheet d'analyse de performance Linux (`perf`, `numactl`, `htop`, `iostat`). |
| **Annexe D** | Templates de production (SOP de mise à jour de cluster, modèle RCA / Post-mortem). |
| **Annexe E** | Index thématique et glossaire des acronymes (de l'A/B testing au ZFS). |

➡️ **Annexes SRE & Cheatsheets (A–D)** : [Annexes SRE & Cheatsheets HPC](hpc_annexes) — Slurm, Lustre, perf/numactl, Post-Mortem Blameless.  
➡️ **Glossaire wiki** : [Glossaire et Acronymes](Glossaire-et-Acronymes)  
➡️ **Commandes** : [Commandes Utiles](Commandes-Utiles)

---

## 📖 Liens vers les pages du wiki

| Ressource | Lien |
|-----------|------|
| **Volume 1 détaillé** | [Manuel Architecture HPC — Volume 1](Manuel-Architecture-HPC-Volume1) |
| **Volume 2 détaillé** | [Manuel Architecture HPC — Volume 2](Manuel-Architecture-HPC-Volume2) |
| **Volume 3 détaillé** | [Manuel Architecture HPC — Volume 3](Manuel-Architecture-HPC-Volume3) |
| **Volume 4 détaillé** | [Manuel Architecture HPC — Volume 4](Manuel-Architecture-HPC-Volume4) |
| **Volume 5 détaillé** | [Manuel Architecture HPC — Volume 5](Manuel-Architecture-HPC-Volume5) |
| **Volume 6 détaillé** | [Manuel Architecture HPC — Volume 6](Manuel-Architecture-HPC-Volume6) |
| **Volume 7 détaillé** | [Manuel Architecture HPC — Volume 7](Manuel-Architecture-HPC-Volume7) |
| **Volume 8 détaillé** | [Manuel Architecture HPC — Volume 8](Manuel-Architecture-HPC-Volume8) |
| **Volume 9 détaillé** | [Manuel Architecture HPC — Volume 9](Manuel-Architecture-HPC-Volume9) (Data Science & ML) |
| **Cours HPC complet** | [Cours HPC Complet](Cours-HPC-Complet) |
| **Dictionnaire encyclopédique** | [Dictionnaire encyclopédique HPC](Dictionnaire-Encyclopedique-HPC) |
| **Annexes SRE & Cheatsheets** | [Annexes HPC (A–D)](hpc_annexes) |
| **Guide Slurm** | [Guide SLURM Complet](Guide-SLURM-Complet) |
| **Monitoring** | [Monitoring](Monitoring) |
| **Glossaire & acronymes** | [Glossaire et Acronymes](Glossaire-et-Acronymes) |
| **Accueil wiki** | [Home](Home) |

---

**Manuel d'architecture et d'ingénierie HPC : de la théorie à la production**  
**Dernière mise à jour** : 2024
