# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 9 : Data Science & Machine Learning sur cluster HPC (de l'ETL au training distribué)**

> **Niveau** : Ingénieur / Master / Doctorat — **Public** : Data Scientists, MLOps, chercheurs, admins HPC  
> **Objectif** : passer d'un notebook "mono-GPU" à un **pipeline reproductible** et un **entraînement multi-nœuds** performant sous **Slurm**.  
> **Chapitres** : 27 à 30 (suite du Volume 8).

---

## Vue d'ensemble du volume

Le HPC "classique" (MPI/CFD) et le ML/IA convergent : **mêmes supercalculateurs**, mêmes contraintes (I/O, réseau, quotas, fairshare), mais des **patterns logiciels** différents (datasets shardés, checkpoints, collectifs NCCL, hyperparam search, tracking).  
Ce volume apporte une méthode "senior" pour :

- construire des **pipelines Data/ML** adaptés à un stockage parallèle (Lustre/BeeGFS/GPFS) ;
- lancer un **training distribué** (PyTorch DDP) sur **plusieurs nœuds GPU** via Slurm ;
- industrialiser : **reproductibilité**, **traçabilité**, **profiling**, **scaling study**, **MLOps on-prem**.

**Prérequis recommandés :**
- Slurm : allocations, partitions, job arrays (voir [Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md)).
- Connaissances GPU (CUDA) et bases de PyTorch (ou équivalent).
- Notions de performance : latence, bande passante, saturation I/O (voir Vol. 6).
- Vol. 5 : NCCL, GPU, Apptainer (labs 6 & 7).

---

## Chapitre 27 : Workloads Data/ML sur HPC — data locality, I/O et formats

### Objectifs d'apprentissage

- Comprendre pourquoi le **goulot** ML est souvent **la donnée** (pas le GPU)
- Choisir un **format** et un **pattern d'accès** compatibles avec un FS parallèle
- Savoir quand utiliser **cache NVMe local**, sharding, préfetch, et quand **ne pas** le faire

---

### 27.1 Le triptyque "Compute / I/O / Réseau" (et pourquoi le ML casse les habitudes)

En ML, on a souvent :

- **beaucoup** de lectures (dataset) ;
- **des écritures périodiques** (checkpoints) ;
- un **réseau** sollicité par les collectifs (all-reduce) ;
- une sensibilité énorme à la **variance** (un OST saturé → training instable).

> Règle empirique : si l'utilisation GPU oscille (ex. 20% ↔ 95%) sans raison, suspectez d'abord **I/O** ou **data loader** avant "le modèle".

---

### 27.2 Formats : Parquet / Zarr / HDF5 / TFRecords / WebDataset

| Format | Forces | Limites | Quand l'utiliser |
|--------|--------|---------|------------------|
| **Parquet** | Excellent pour tabulaire, prédicats, compression | Moins naturel pour images/audio | ETL, features, analytics, Spark/Dask |
| **Zarr** | Chunking natif, cloud-friendly, bon pour arrays N-D | Demande un bon choix de chunks | Imagerie scientifique, grilles 3D, climat |
| **HDF5** | Très utilisé en science, structure riche | Concurrence d'accès, tuning nécessaire | Sci/Simu, gros tableaux + metadata |
| **TFRecords** | Streaming séquentiel efficace | Écosystème TF | Training TF, lecture séquentielle |
| **WebDataset (tar shards)** | Sharding simple, moins de "petits fichiers" | Opérations d'update plus complexes | Images/texte : dataset en tar.* shardés |

**Anti-pattern n°1 : "des millions de petits fichiers"**  
Même si le FS parallèle est puissant, l'overhead metadata tue le throughput. Préférez : *shards* (tar/parquet/zarr chunks).

---

### 27.3 Sharding & taille des shards (la partie la plus sous-estimée)

But : réduire les seeks, augmenter la séquentialité, amortir la latence metadata.

**Heuristiques (à adapter) :**
- Images : shards **256 Mo à 2 Go**
- NLP : shards **1 à 10 Go** (selon tokenisation / streaming)
- HPC data : chunks Zarr calés sur "un minibatch/worker"

> Un shard trop petit = metadata ; trop gros = moins de parallélisme et "stragglers".

---

### 27.4 Cache NVMe local : quand c'est magique… et quand c'est dangereux

**Cas où c'est excellent :**
- Datasets "read-only" réutilisés souvent
- Nœuds GPU qui relancent des runs similaires (grid search)
- FS réseau très chargé

**Cas où c'est un piège :**
- Datasets énormes (copie plus longue que l'entraînement)
- Nettoyage absent → `/scratch_local` saturé
- Incohérences (dataset versionné mais cache stale)

**Pattern robuste :**
1) calculer un **hash/version** de dataset (manifest, DVC ou équivalent)
2) si absent localement → **rsync** (ou `tar`/`aria2`) vers NVMe
3) pointer le loader sur le cache
4) purge contrôlée (LRU, quota)

---

### 27.5 Checkpoints : stratégie "écrire moins, reprendre mieux"

- **Fréquence** : basée sur *time-to-recover*, pas sur "toutes les N itérations"
- **Asynchrone** si possible (thread/process dédié)
- **Sharded checkpoint** (FSDP/DeepSpeed) pour réduire le "stall"
- **Compression** prudente : parfois CPU devient le bottleneck

**Piège :** checkpoint sur un seul fichier "monstre" → contention (lock), saturation OST unique.  
Préférer : **plusieurs fichiers** (shards) ou "save per rank".

---

### Check-list production (Chapitre 27)

- [ ] Dataset shardé (pas "N millions de petits fichiers")
- [ ] Mesure objective : *GPU utilization* + *dataloader time* + *throughput I/O*
- [ ] Politique de checkpoint (rétention, purge, emplacement)
- [ ] Option cache NVMe documentée + purge
- [ ] Données versionnées (manifest + hash, ex. DVC) pour reproductibilité

---

### Points clés à retenir (Ch. 27)

- Le goulot ML est souvent l'I/O ; formats et sharding sont critiques sur FS parallèle.
- Éviter les millions de petits fichiers ; privilégier Parquet/Zarr/WebDataset selon le cas.
- Cache NVMe : utile si dataset réutilisé et purge maîtrisée ; dangereux si cache stale ou quota non géré.
- Checkpoints : fréquence raisonnable, asynchrone si possible, shards pour limiter contention.

---

## Chapitre 28 : Entraînement distribué sur Slurm — DDP, rendezvous, NCCL

### Objectifs d'apprentissage

- Lancer un **PyTorch DDP multi-nœuds** de manière robuste avec Slurm
- Comprendre les variables d'environnement et les symptômes **NCCL**
- Mettre en place une démarche de **scaling study** (strong/weak)

---

### 28.1 Les trois modes "standard" de lancement DDP

| Mode | Principe | Avantages | Risques |
|------|----------|-----------|---------|
| **`srun python train.py`** | Slurm lance N tâches, votre code init le process group | Simple, "HPC natif" | Il faut bien mapper rank/world_size |
| **`torchrun`** | PyTorch gère rendezvous + ranks | Standard ML | Interaction Slurm à maîtriser |
| **Submitit** | Génère job Slurm + configure env PyTorch | Très productif | Abstraction à comprendre, sinon debug dur |

---

### 28.2 Template sbatch (multi-nœuds GPU) — "golden path"

> Hypothèse : 2 nœuds, 4 GPU/nœud, 1 process par GPU.  
> **Note** : `-c 8` (CPUs per task) doit être cohérent avec `num_workers` du DataLoader pour éviter contention.

```bash
#!/bin/bash
#SBATCH -J ddp-demo
#SBATCH -p gpu
#SBATCH -N 2
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-node=4
#SBATCH -c 8
#SBATCH --time=02:00:00
#SBATCH -o logs/%x-%j.out
#SBATCH -e logs/%j.err

module purge
module load opensource/miniforge
conda activate ml

# Debug utile en phase d'intégration
export NCCL_DEBUG=INFO
export TORCH_DISTRIBUTED_DEBUG=DETAIL

# Adresse maître = 1er nœud de l'allocation
MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
MASTER_PORT=29500

# Lancement : 1 process par tâche Slurm
srun --kill-on-bad-exit=1 \
  python -u train.py \
    --dist \
    --master_addr "$MASTER_ADDR" --master_port "$MASTER_PORT"
```

**Mapping minimal côté Python :**
- `RANK = int(os.environ["SLURM_PROCID"])`
- `WORLD_SIZE = int(os.environ["SLURM_NTASKS"])`
- `LOCAL_RANK = int(os.environ["SLURM_LOCALID"])`

**Piège** : sur certains clusters, `MASTER_PORT` doit être dans une plage autorisée ; vérifier la politique (ex. 29500–29600).

---

### 28.3 Débugger NCCL : méthode systématique

**Symptômes typiques :**
- freeze au démarrage (rendezvous, connectivité)
- crash `unhandled system error` (iface réseau, driver, mismatch)
- performance anormalement basse (mauvaise iface, topo, oversubscription)

**Méthode "du plus simple au plus probable" :**
1) **TCP OK** entre nœuds (ping, ports ouverts, DNS)
2) vérifier `CUDA_VISIBLE_DEVICES` par tâche (`srun env | grep CUDA_VISIBLE_DEVICES`)
3) forcer l'interface : `export NCCL_SOCKET_IFNAME=eth0` (adapter au cluster)
4) si InfiniBand mal configuré : `export NCCL_IB_DISABLE=1` (fallback TCP) ou `NCCL_NET` selon doc NCCL
5) augmenter logs : `NCCL_DEBUG=INFO` (+ éventuellement `NCCL_DEBUG_SUBSYS=ALL`)
6) valider collectifs avec `all_reduce` minimal avant d'entraîner le modèle

> Un "training qui démarre" n'est pas un "training correct" : un mauvais binding peut diviser la perf par 5.

---

### 28.4 Topologie-aware : ne pas gaspiller NVLink / PCIe / NUMA

- 1 process/GPU : standard DDP
- binding CPU : évite la contention dataloader (`--cpu-bind` via srun si nécessaire)
- si NVLink : privilégier des tailles de batch / buckets qui amortissent les collectifs

**Piège :** `num_workers` énorme + FS parallèle saturé → CPU bound + I/O bound.

---

### 28.5 Scaling study : comment prouver que ça scale (et pas juste "ça tourne")

**Strong scaling (dataset fixe)**
- objectif : réduire le temps
- limite : overhead comms + inefficacité batch

**Weak scaling (batch/global augmente)**
- objectif : maintenir le temps/epoch ~ constant
- limite : qualité (LR scaling), stabilité, mémoire

**Métriques à produire :**
- samples/s (global)
- temps/epoch
- % temps comms vs compute (profiling)
- taux d'échec / repro (stabilité)

---

### Check-list production (Chapitre 28)

- [ ] "Hello all-reduce" validé sur N nœuds
- [ ] `NCCL_DEBUG=INFO` en phase test, puis OFF en prod
- [ ] Interface réseau maîtrisée (`NCCL_SOCKET_IFNAME`)
- [ ] Stratégie de scaling documentée (strong/weak + graphiques)

---

### Points clés à retenir (Ch. 28)

- DDP multi-nœuds : MASTER_ADDR/MASTER_PORT + variables Slurm (PROCID, NTASKS, LOCALID) ; template sbatch + srun = chemin robuste.
- Debug NCCL : connectivité TCP, CUDA_VISIBLE_DEVICES, NCCL_SOCKET_IFNAME, NCCL_IB_DISABLE si besoin, puis logs INFO.
- Scaling study (strong/weak) et métriques (samples/s, temps comms) pour prouver l'efficacité.

---

## Chapitre 29 : Orchestration à l'échelle — job arrays, Submitit, Optuna, Ray/Dask/Spark

### Objectifs d'apprentissage

- Orchestrer 100–10 000 runs (grid / random / Bayesian) **sans casser le cluster**
- Comprendre quand utiliser **job arrays** vs Ray/Dask/Spark
- Mettre des garde-fous (quotas, backfill, priorités) et éviter les anti-patterns

---

### 29.1 Job arrays : le meilleur outil "simple et robuste"

Cas d'usage : hyperparam search, ablations, seeds multiples.

```bash
#SBATCH --array=0-199%20   # 200 runs, max 20 en parallèle
```

- `%20` protège le cluster et votre quota
- `SLURM_ARRAY_TASK_ID` indexe une config (YAML/JSON)

**Piège :** 10 000 jobs individuels sans `%` → scheduler flood.

---

### 29.2 Submitit : productivité Python + discipline HPC

Submitit automatise la soumission Slurm depuis Python, et gère le "torch distributed env" (ranks).

Usages typiques :
- lancer une **fonction** Python en batch
- faire un `map_array` pour soumettre un lot de runs
- récupérer les logs/retours proprement

**Hydra** (multirun) est une alternative courante pour des runs pilotés par fichier de config (plusieurs configs = plusieurs runs).

---

### 29.3 Optuna (ou équivalent) sur Slurm : pattern recommandé

- **Study** centralisée (SQLite/PostgreSQL)
- chaque trial = un job Slurm (array ou submitit)
- agrégation par un script "collector"

**Règle d'or :** le scheduler doit rester la source de vérité des ressources.

**Piège :** SQLite sur NFS/Lustre peut poser des problèmes de verrouillage ; préférer PostgreSQL ou un backend fichier sur stockage local (scratch du nœud) si beaucoup de writers.

---

### 29.4 Ray/Dask/Spark sur Slurm : quand ça vaut le coup

| Framework | Quand | Attention |
|----------|-------|-----------|
| **Dask** | ETL Python, pandas à l'échelle, arrays | Surveiller scheduler + spill disque |
| **Ray** | pipelines ML, tuning, actors | Démarrage cluster **dans une allocation Slurm** (jamais sur le nœud de login) |
| **Spark** | data lake, SQL, gros ETL | Intégration stockage + shuffle |

> Si vous avez 30 runs indépendants : job arrays.  
> Si vous avez un DAG de tâches dépendantes + scheduling applicatif : Ray/Dask.

---

### Anti-patterns fréquents (Chapitre 29)

| Anti-pattern | Pourquoi c'est mauvais | Alternative |
|-------------|------------------------|-------------|
| "Un Ray cluster permanent sur le login node" | Contourne l'ordonnanceur, risque sécurité | Ray/Dask **dans** une allocation Slurm |
| "10 000 petits jobs d'1 minute" | Overhead scheduler | Bundling, arrays, tâches plus grosses |
| "Un seul script qui spawn 1000 processes" | Non comptabilisé, casse la politique | `srun`, arrays, submitit |

---

### Points clés à retenir (Ch. 29)

- Job arrays avec `%K` = outil simple et robuste pour hyperparam / seeds ; éviter le flood du scheduler.
- Submitit/Hydra = productivité Python tout en restant dans le cadre Slurm.
- Ray/Dask/Spark : à lancer **dans** un job Slurm, pas sur le login.

---

## Chapitre 30 : Reproductibilité, MLOps on-prem, et perf-to-solution

### Objectifs d'apprentissage

- Construire un pipeline **reproductible** (environnement + données + code)
- Mettre en place un minimum de **MLOps** sans cloud public
- Mesurer et améliorer la **perf-to-solution** (pas juste "FLOPS")

---

### 30.1 Reproductibilité : les 4 axes

1) **Code** : Git + tags + CI
2) **Environnement** : Conda-lock / Spack-lock / conteneur Apptainer
3) **Données** : version (hash), manifest, sharding stable
4) **Exécution** : paramètres, seed, logs, métriques

**Minimum viable :**
- `requirements.lock` (ou `environment.yml` + lock)
- `config.yaml` versionné
- `run_id` unique (timestamp + git sha)
- sauvegarde des métriques (CSV/JSON)

---

### 30.2 Tracking d'expériences on-prem (MLflow : l'exemple classique)

- serveur MLflow interne (HTTP)
- stockage artifacts sur `/scratch` ou S3 interne
- traçabilité : params, metrics, artifacts, model registry (selon maturité)

**Alternatives** : TensorBoard (logs locaux), Weights & Biases (W&B) en mode self-hosted ou limité, ou simplement CSV + dossier `runs/` discipliné.

> Pour un cours, même un CSV + dossier `runs/` discipliné est déjà une énorme progression.

---

### 30.3 Profiling ML : relier symptômes et causes

- **GPU** : Nsight Systems / Nsight Compute
- **CPU** : perf, py-spy
- **I/O** : iostat, lustre stats, temps dataloader
- **Réseau** : collectifs (temps all-reduce), saturation NIC

**Plan de profiling recommandé :**
1) single GPU (baseline)
2) multi-GPU mono-nœud (NVLink/PCIe)
3) multi-nœuds (réseau)
4) augmenter batch / workers progressivement

---

### 30.4 Perf-to-solution : le KPI qui parle à tout le monde

**Définition** : temps (ou coût GPU-heures / énergie) pour atteindre une **cible de solution** (ex. précision, loss) — plutôt que de ne regarder que les TFLOPS.

Au lieu de "TFLOPS", on veut :

- temps pour atteindre une précision cible
- coût énergétique / GPU-hours
- taux de reprise après incident (checkpoint)

---

### Check-list production (Chapitre 30)

- [ ] environnement figé (lock/containers)
- [ ] données versionnées (manifest + hash)
- [ ] tracking minimal (params/metrics/artifacts)
- [ ] baseline + scaling study versionnés

---

### Points clés à retenir (Ch. 30)

- Reproductibilité : code (Git) + env (lock/container) + données (hash/manifest) + exécution (config, seed, run_id).
- Tracking : MLflow, TensorBoard ou CSV discipliné ; artifacts sur scratch/S3 interne.
- Perf-to-solution = temps/coût pour atteindre la cible (précision, loss), pas seulement FLOPS.

---

## 🧪 Lab 12 : PyTorch DDP multi-nœuds via Slurm + Apptainer (avec debugging NCCL)

### Objectif

Lancer un entraînement DDP **sur 2 nœuds GPU** (1 process/GPU), mesurer le scaling, et diagnostiquer un problème réseau simulé.

### Étapes

1) Construire un conteneur Apptainer (ou utiliser un module) avec PyTorch + CUDA  
2) Soumettre un job Slurm DDP (template Chap. 28.2)  
3) Vérifier :
   - `CUDA_VISIBLE_DEVICES` par tâche
   - `nvidia-smi` par nœud
   - logs `NCCL_DEBUG=INFO` (phase debug)
4) Mesurer : `samples/s`, temps/epoch (2 runs : 1 nœud puis 2 nœuds)
5) Simuler une erreur : mauvaise iface (`NCCL_SOCKET_IFNAME`) **ou** `MASTER_PORT` déjà utilisé → interpréter logs → corriger

### Critères de réussite

- Le run 2 nœuds est **plus rapide** que 1 nœud (strong scaling) *ou* expliquez pourquoi non (bottleneck I/O, batch trop petit, comms).
- Vous produisez un mini-rapport : command lines, métriques, conclusion.

---

## 🧪 Lab 13 : Recherche d'hyperparamètres (Submitit + Optuna) et agrégation de résultats

### Objectif

Lancer 50–200 trials sans "flooder" Slurm, agréger les résultats, et sortir le meilleur run reproductible.

### Étapes

1) Définir un espace de recherche (LR, batch, weight decay)  
2) Utiliser job arrays **ou** Submitit `map_array` avec un "cap" de concurrence  
3) Stocker :
   - `config.yaml` trial
   - métriques (CSV/JSON)
   - artifact (checkpoint minimal)
4) Script d'agrégation : top-k + export tableau + re-run du meilleur (même seed/env)

### Critères de réussite

- Concurrence contrôlée (`%MAX`) et logs exploitables
- Re-run du meilleur trial = résultat cohérent (métrique à ±1 % ou écart expliqué)

---

## 📝 Examen de fin de volume 9

### QCM (1 point chaque)

**1.** Pourquoi "des millions de petits fichiers" posent problème sur un stockage parallèle ?  
- A) Parce que les GPU ne savent pas lire des petits fichiers  
- B) **Parce que l'overhead metadata (création/stat/open) domine et réduit fortement le throughput**  
- C) Parce que Parquet ne supporte pas les petits fichiers

**2.** Dans un job DDP multi-nœuds, quelle variable est souvent utilisée pour choisir l'interface réseau NCCL ?  
- A) `CUDA_VISIBLE_DEVICES`  
- B) `OMP_NUM_THREADS`  
- C) **`NCCL_SOCKET_IFNAME`**

**3.** Quel outil Slurm est le plus "naturel" pour lancer 200 runs indépendants sans saturer le scheduler ?  
- A) Lancer 200 `ssh` depuis le login node  
- B) **`--array=...%K` (job arrays avec limite de concurrence)**  
- C) Un unique job qui lance 200 processus non gérés

---

### Question ouverte (architecture + méthode)

Vous devez entraîner un modèle sur un dataset de 200 To sur un cluster :  
- FS parallèle (Lustre), nœuds GPU avec NVMe local, réseau InfiniBand.  

Proposez une stratégie complète : **format + sharding + cache + checkpoints + lancement Slurm + métriques de scaling**.  
Expliquez aussi comment vous déboguez un **freeze NCCL** au démarrage.

---

## Références conseillées (lecture)

- Documentation Slurm (sbatch/srun), politiques GPU, cgroups  
- Documentation PyTorch Distributed / DDP (multi-node)  
- Documentation NCCL (variables d'environnement, debugging)  
- [Submitit](https://github.com/facebookresearch/submitit) (soumission Slurm depuis Python)  
- [Optuna](https://optuna.readthedocs.io/) (optimisation hyperparamètres, intégration Slurm)  
- [WebDataset](https://webdataset.github.io/webdataset/) (sharding tar pour ML)  
- Guides Ray/Dask sur Slurm (cas où scheduling applicatif est pertinent)  
- Nsight Systems / Nsight Compute (profiling GPU NVIDIA)

---

[← Sommaire Manuel](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md) · [← Accueil](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)
