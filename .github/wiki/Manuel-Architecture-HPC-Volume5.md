# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 5 : Toolchains, MPI, GPU et conteneurs**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

Après l'infrastructure matérielle, le stockage et l'ordonnanceur, ce volume couvre la **couche qui interagit directement avec les chercheurs** : environnements logiciels, compilation et exécution massivement parallèle. On y traite les **toolchains** (Lmod, Spack, Apptainer), le **parallélisme MPI** (sémantique, binding NUMA, UCX), puis l'**accélération GPU et IA** (NCCL, GPUDirect RDMA, lancement Slurm). Les [Labs 6 & 7](#-lab-6--7--toolchains-et-déploiement-ia) et l'[examen de fin de volume](#-examen-de-fin-de-volume-5) permettent de valider les acquis.

**Prérequis :**
- Compilation Linux (GCC, Make, CMake), variables d'environnement (PATH, LD_LIBRARY_PATH) — Ch. 16
- Architecture NUMA, C/C++ ou Fortran de base — Ch. 17
- Notions PCIe, accélération matérielle — Ch. 18

---

## Chapitre 16 : Environnements utilisateurs et toolchains (Spack & Lmod)

### Objectifs d'apprentissage

- Déployer et gérer un **arbre de modules** hiérarchique avec **Lmod**
- Automatiser la compilation de stacks complexes avec **Spack**
- Exécuter des charges de travail via **Apptainer** (ex-Singularity) de façon sécurisée

---

### 16.1 Le chaos des dépendances et Lmod

En HPC, un chercheur peut avoir besoin de **GCC 11** pour le code A et de **GCC 13 + OpenMPI 4** pour le code B. Installer tout globalement dans `/usr/bin` est impossible. Les **Modules d'environnement**, et en particulier **Lmod** (TACC, écrit en Lua), permettent de **charger/décharger** dynamiquement les variables d'environnement.

**Exemple de Modulefile Lmod (Lua) pour OpenMPI :**

```lua
help([[
Ce module charge OpenMPI 4.1.5 compilé avec GCC 11.2.
]])
whatis("Version: 4.1.5")
whatis("Compiler: gcc/11.2.0")

-- Empêche le chargement de deux versions d'OpenMPI simultanément
conflict("openmpi")
-- S'assure que le bon compilateur est chargé
prereq("gcc/11.2.0")

local base = "/opt/hpc/software/openmpi/4.1.5-gcc11"
prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib"))
```

---

### 16.2 Spack : le gestionnaire de paquets des supercalculateurs

**Spack** automatise le téléchargement, la **compilation** (depuis les sources) et la **génération des modules Lmod**. Il gère un graphe de dépendances combinatoire (ex. HDF5 avec ou sans MPI, GCC ou Intel).

**Snippet : Installation d'un package via Spack**

```bash
# HDF5 1.14.0, GCC 12.2, support MPI (OpenMPI 4.1.5)
spack install hdf5@1.14.0 %gcc@12.2.0 +mpi ^openmpi@4.1.5
```

---

### 16.3 Conteneurs HPC : Apptainer (ex-Singularity)

Docker nécessite un démon **root** → faille de sécurité en HPC. **Apptainer** résout cela :

| Caractéristique | Bénéfice |
|-----------------|-----------|
| **Rootless** | L'utilisateur a les **mêmes UID/GID** à l'intérieur qu'à l'extérieur. |
| **Intégration** | `/home` et le stockage parallèle (Lustre) sont montés automatiquement. |
| **Format** | Image **SIF** (Singularity Image Format), fichier unique facile à déplacer. |

---

### Piège : « Le LD_LIBRARY_PATH toxique »

Mettre `export LD_LIBRARY_PATH=/path/to/lib` dans le **~/.bashrc** casse silencieusement des commandes système (`ls`, `ssh`) ou les autres modules Lmod. **Règle** : l'environnement doit être **vierge** au login ; tout chargement via **modules** uniquement.

---

### Check-list production (Chapitre 16)

- [ ] Hiérarchie Lmod stricte : **Core → Compilateur → MPI**
- [ ] Configurer Apptainer pour **lier (bind)** automatiquement les **drivers GPU** hôtes (`--nv`)

---

## Chapitre 17 : Parallélisme et MPI (Deep Dive)

### Objectifs d'apprentissage

- Comprendre les protocoles de transfert MPI (**Eager** vs **Rendezvous**)
- Maîtriser le **placement des processus** (rank mapping, binding NUMA)
- Configurer la couche de transport **UCX**

---

### 17.1 Sémantique MPI : Eager vs Rendezvous

Le temps de communication peut être modélisé par l'**équation de Hockney** :

```
T_comm = α + L/β
```

*(α = latence réseau, L = taille du message, β = bande passante.)*

Pour minimiser α, MPI utilise deux protocoles selon la **taille du message** :

| Protocole | Usage | Comportement |
|-----------|--------|----------------|
| **Eager** (petits messages) | Envoi direct, buffer pré-alloué côté récepteur | Très rapide ; risque d'engorgement mémoire si trop de messages. |
| **Rendezvous** (gros messages) | RTS (Ready to Send) → récepteur répond CTS (Clear to Send) → transfert (souvent **RDMA** direct) | Évite la saturation des buffers. |

---

### 17.2 Rank mapping, binding et topologie NUMA

Sur un processeur multi-chiplets (ex. AMD EPYC), si un rang MPI s'exécute sur le **cœur 0** mais alloue sa mémoire sur la **RAM du socket 1** (cœur 60), la bande passante mémoire s'effondre.

**Schéma : Importance du binding**

```
MAUVAIS BINDING (migration OS)       BON BINDING (--bind-to core)
T0: Rank 0 sur CPU 0                 T0: Rank 0 bloqué sur CPU 0
T1: Rank 0 migre sur CPU 8           T1: Rank 0 reste sur CPU 0
(Cache L3 perdu, latence explose)    (Cache L3 chaud, perfs maximales)
```

**Commande de lancement optimisée (OpenMPI via Slurm) :**

```bash
# Slurm alloue les cœurs ; OpenMPI force le binding (--bind-to core)
# et place les rangs séquentiels sur le même nœud (--map-by node)
srun --mpi=pmix mpirun --map-by node --bind-to core ./mon_code_fluides
```

---

### 17.3 UCX (Unified Communication X)

OpenMPI et MPICH ne gèrent plus directement InfiniBand ; ils délèguent à **UCX**. UCX choisit dynamiquement le meilleur chemin : **mémoire partagée** (intra-nœud), **RDMA** (inter-nœuds), **GPU-to-GPU**.

---

## Chapitre 18 : Accélération GPU et IA en HPC

### Objectifs d'apprentissage

- Appréhender le **modèle d'exécution** matériel des GPU
- Comprendre **NCCL** et **GPUDirect RDMA**
- Configurer le **couplage CPU-GPU** dans [Slurm](Guide-SLURM-Complet)

---

### 18.1 Le goulot d'étranglement PCIe

Un GPU (ex. NVIDIA H100) est connecté au CPU via **PCIe** (ex. Gen5 ≈ 64 GB/s), bien plus lent que la **VRAM** du GPU (HBM3 ≈ 3 TB/s).

**Anti-pattern** : copier CPU → GPU, faire une opération, rapatrier CPU à **chaque itération**.

---

### 18.2 GPUDirect RDMA et NCCL

Pour l'entraînement IA sur **100 GPU** (25 nœuds), les GPU s'échangent les **gradients** (AllReduce).

- **Sans GPUDirect** : GPU → RAM CPU → HCA → Réseau → HCA distante → RAM CPU → GPU distant → **catastrophique**.
- **Avec GPUDirect RDMA** : la carte réseau (ex. ConnectX-7) **lit directement la VRAM** du GPU via PCIe, **sans réveiller le CPU**.

**NCCL** (NVIDIA Collective Communication Library) orchestre les échanges (anneaux, arbres) pour maximiser la bande passante.

---

### 18.3 Lancement hybride CPU/GPU sous Slurm

Il faut **lier** chaque processus MPI au **bon GPU** (même racine PCIe).

**Snippet : Job IA multi-GPU avec binding strict**

```bash
#!/bin/bash
#SBATCH --job-name=train_llm
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4      # 1 tâche MPI par GPU
#SBATCH --gpus-per-node=4
#SBATCH --gpu-bind=closest       # Tâche MPI liée au GPU le plus proche (topologie)

srun python train.py
```

---

### DANGER en prod : « Le pilote mismatch »

Mettre à jour le **noyau Linux** sans recompiler les **modules kernel NVIDIA** (DKMS) ou le pilote **OFED**. **Symptôme** : les GPU disparaissent ou les jobs NCCL tombent en **segmentation fault**.

---

## 🧪 Lab 6 & 7 : Toolchains et déploiement IA

### Énoncé

**Lab 6 (Spack)** : Installez Spack. Compilez **osu-micro-benchmarks** (OMB) avec OpenMPI. Générez le module Lmod, chargez-le, et exécutez un test **osu_bw** (bande passante point à point) entre **deux processus sur le même nœud**.

**Lab 7 (Apptainer)** : Créez un fichier de définition Apptainer (`pytorch.def`) basé sur l'image Docker officielle **NVIDIA PyTorch**. Buildez l'image SIF. Soumettez un job Slurm qui exécute `python -c "import torch; print(torch.cuda.is_available())"` **dans le conteneur**.

### Critères de réussite

- **osu_bw** affiche un tableau de bande passante atteignant la limite de la **mémoire RAM** (intra-nœud).
- Le job Slurm retourne **True** et a utilisé l'intégration GPU native d'Apptainer (`--nv`).

### Corrigé (grandes lignes)

```bash
# Lab 6 : Spack & OMB
git clone -c feature.manyFiles=true https://github.com/spack/spack.git
source spack/share/spack/setup-env.sh
spack install osu-micro-benchmarks ^openmpi
spack module lmod refresh -y
module load osu-micro-benchmarks
mpirun -np 2 --bind-to core osu_bw

# Lab 7 : Apptainer & PyTorch
cat << EOF > pytorch.def
Bootstrap: docker
From: nvcr.io/nvidia/pytorch:23.10-py3
EOF
apptainer build pytorch.sif pytorch.def
# Exécution via Slurm (GRES GPU configurés)
srun --gpus=1 apptainer exec --nv pytorch.sif python -c "import torch; print(torch.cuda.is_available())"
```

---

## 📝 Examen de fin de volume 5

### QCM (1 point chaque)

**1.** Pourquoi Lmod est-il structuré de manière **hiérarchique** (ex. Core → Compiler → MPI) ?  
- A) Pour des raisons esthétiques dans `module avail`  
- B) **Pour empêcher de charger une bibliothèque (ex. HDF5 compilé avec GCC) si un compilateur incompatible (ex. Intel) est déjà chargé**  
- C) Parce que Spack l'impose par défaut  

**2.** Quel est l'avantage principal d'**Apptainer** par rapport à Docker en HPC ?  
- A) Apptainer est plus rapide pour exécuter du Python  
- B) **Apptainer fonctionne sans démon root ; l'utilisateur ne peut pas élever ses privilèges sur l'hôte**  
- C) Apptainer inclut nativement toutes les licences logicielles  

---

### Question ouverte (Optimisation MPI)

Un utilisateur lance une simulation MPI sur **2 nœuds** (128 cœurs chacun, 256 rangs). Si le cluster est **vide**, le job dure **1 h**. Si le cluster est **très chargé** (mais ses 2 nœuds lui sont dédiés à 100 %), le job dure **1 h 30**. L'application fait de **lourds MPI_Allreduce**.

**Expliquez** le phénomène physique/réseau qui ralentit le job et **comment** les concepteurs de réseaux HPC tentent de le mitiger (indices : congestion, topologie de la fabric).

**Réponse attendue** : Le **réseau** (InfiniBand ou Ethernet) est **partagé**. **Congestion réseau** (network contention) : les flux d'autres jobs saturent les liens des switches Spine/Leaf et perturbent la synchronisation des **MPI_Allreduce**. **Mitigations** : routage adaptatif (OpenSM), contrôle de congestion (ECN), **topology-aware scheduling** (Slurm place les nœuds sur le même Leaf pour limiter le passage par le Spine).

---

### Étude de cas : « Le goulot d'étranglement fantôme du Deep Learning »

Une équipe entraîne un modèle sur **4 nœuds × 4 GPU A100** (NVLink interne, InfiniBand 200 Gbps entre nœuds). **nvtop** montre une **utilisation GPU plafonnant à 30 %**. **ib_write_bw** confirme 200 Gbps sur la carte réseau.

1. **Quel mécanisme** de transfert direct est probablement **désactivé ou mal configuré** ?
2. **Quelle variable d'environnement NCCL** demanderiez-vous pour activer un mode **débogage réseau** (ex. `NCCL_DEBUG=...`) ?

**Réponses attendues :**

1. **GPUDirect RDMA** n'est pas actif (souvent : module noyau **nv_peer_mem** manquant ou incompatibilité IOMMU/PCIe). Les transferts NCCL passent par le **CPU** → saturation PCIe, GPU en attente (starvation).
2. **`export NCCL_DEBUG=INFO`**. Les logs indiquent si NCCL utilise la couche **SYS** (CPU/RAM) au lieu de **NET/IB** (RDMA direct).

---

## Solutions des QCM

- **Q1** : **B** — Hiérarchie pour éviter les conflits de dépendances (compilateur/bibliothèque).
- **Q2** : **B** — Rootless, pas de démon root, pas d'élévation de privilèges.

---

## 📋 Relecture qualité du volume 5

- [x] Couverture : Lmod/Spack, Apptainer vs Docker, MPI (Eager/Rendezvous), binding NUMA, UCX, GPU, NCCL, GPUDirect
- [x] Rigueur technique : équation de Hockney, bypass mémoire GPUDirect RDMA
- [x] Format : Markdown, schémas (binding, protocoles)
- [x] Pédagogie : Labs Spack + OMB, Apptainer + PyTorch, études de cas (congestion, NCCL)

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](Manuel-HPC-Sommaire-Complet)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Vol. 1 à 4](Manuel-Architecture-HPC-Volume1)** : fondations, réseaux, stockage, Slurm
- **[Guide SLURM Complet](Guide-SLURM-Complet)** : partitions, GRES, sbatch, srun
- **[Glossaire et Acronymes](Glossaire-et-Acronymes)** : MPI, RDMA, NUMA, NCCL, UCX, etc.
- **[Home](Home)** : page d'accueil du wiki

---

**Volume 5** — Toolchains, MPI, GPU et conteneurs  
**Dernière mise à jour** : 2024
