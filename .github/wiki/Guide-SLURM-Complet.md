# 🎯 Guide SLURM Complet — Scheduler HPC

> **Référence professionnelle Slurm — Niveau DevOps Senior & Utilisateurs avancés**

---

## 1. Présentation de Slurm

**Slurm** (Simple Linux Utility for Resource Management) est un **ordonnanceur de jobs** (job scheduler) et un **gestionnaire de ressources** pour clusters Linux. Il est utilisé dans une grande partie des clusters académiques et des supercalculateurs.

### 1.1 Rôles principaux

- **Ordonnancement** : décider quand et sur quels nœuds un job s’exécute
- **Allocation** : réserver CPU, mémoire, GPU, temps pour chaque job
- **Gestion de la file d’attente** : priorités, partitions, QoS (Quality of Service)
- **Comptabilité** : enregistrement de l’usage (comptes, projets) pour facturation ou quotas

### 1.2 Architecture Slurm (résumé)

| Composant | Rôle |
|-----------|------|
| **slurmctld** | Démon contrôleur (un primaire, éventuellement un backup) — décisions de scheduling |
| **slurmd** | Démon sur chaque nœud de calcul — exécute les étapes (steps) des jobs |
| **slurmdbd** | Démon base de données (optionnel) — historique, comptabilité, multi-cluster |
| **sbatch** | Soumettre un job batch (script) |
| **srun** | Lancer une tâche (souvent depuis un job alloué, ou en interactif) |
| **squeue** | Afficher la file d’attente |
| **scancel** | Annuler un job |
| **sinfo** | État des nœuds et partitions |

---

## 2. Concepts clés

### 2.1 Job, step, allocation

- **Job** : unité de travail soumise par l’utilisateur (un ou plusieurs steps).
- **Step** : sous-partie d’un job (ex. un `srun` dans un script sbatch). Les ressources peuvent être partagées entre steps ou réservées par step.
- **Allocation** : ensemble de nœuds/CPU/mémoire/GPU attribués à un job (ou à un step).

### 2.2 Partitions (queues)

Une **partition** est une **file d’attente** associée à un sous-ensemble de nœuds et à des limites (temps max, nombre de jobs, etc.).

Exemples :

- `normal` : usage standard
- `high` : priorité plus élevée ou nœuds dédiés
- `gpu` : nœuds avec GPU
- `short` : jobs courts (temps max faible)
- `long` : jobs longs

Commandes utiles :

```bash
sinfo -s                    # Résumé des partitions
sinfo -p normal,gpu          # Détail des partitions normal et gpu
scontrol show partition normal
```

### 2.3 QoS (Quality of Service)

Les **QoS** définissent des **contraintes et limites** (temps max, nœuds max, priorité) appliquées aux jobs. Un job est soumis dans une partition et peut être associé à une QoS.

```bash
sacctmgr show qos            # Lister les QoS (si slurmdbd configuré)
scontrol show qos            # Détails des QoS
```

### 2.4 Priorité et fair-share

- La **priorité** d’un job dépend souvent de : QoS, partition, **fair-share** (usage passé de l’utilisateur/projet), âge du job, taille de l’allocation.
- **Fair-share** : les utilisateurs (ou comptes) qui ont moins consommé récemment obtiennent une priorité plus élevée pour équilibrer l’usage.

---

## 3. Soumission de jobs

### 3.1 Job batch avec sbatch

Fichier `mon_job.sh` :

```bash
#!/bin/bash
#SBATCH --job-name=mon_job
#SBATCH --partition=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=01:00:00
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err

# Optionnel : répertoire de travail
# #SBATCH --chdir=/scratch/user/mon_projet

# Charger un module (si Environment Modules utilisé)
# module load openmpi/4.1

# Lancer l’application (ex. MPI)
srun ./mon_executable_mpi
```

Soumission :

```bash
sbatch mon_job.sh
```

### 3.2 Principales options sbatch / srun

| Option | Description | Exemple |
|--------|-------------|--------|
| `--job-name` | Nom du job | `--job-name=simu_a` |
| `--partition` | Partition (queue) | `--partition=gpu` |
| `--nodes` | Nombre de nœuds | `--nodes=4` |
| `--ntasks` | Nombre de tâches (processus) | `--ntasks=64` |
| `--ntasks-per-node` | Tâches par nœud | `--ntasks-per-node=16` |
| `--cpus-per-task` | CPU par tâche | `--cpus-per-task=2` |
| `--mem` | Mémoire totale pour le job | `--mem=32G` |
| `--mem-per-cpu` | Mémoire par CPU | `--mem-per-cpu=4G` |
| `--time` | Durée max (walltime) | `--time=02:30:00` |
| `--output` | Fichier stdout | `--output=out_%j.txt` |
| `--error` | Fichier stderr | `--error=err_%j.txt` |
| `--gres` | Ressources génériques (ex. GPU) | `--gres=gpu:2` |
| `--exclusive` | Nœuds dédiés au job | `--exclusive` |
| `--mail-type` | Mail (BEGIN, END, FAIL, etc.) | `--mail-type=END` |
| `--mail-user` | Adresse email | `--mail-user=user@domain` |

Format du temps : `JOURS-HOURS:MINUTES:SECONDS` ou `MINUTES` ou `HOURS:MINUTES:SECONDS`.  
`%j` dans output/error = Job ID.

### 3.3 Job interactif avec srun

Réserver des ressources et ouvrir un shell sur un nœud de calcul :

```bash
srun --partition=normal --nodes=1 --ntasks=1 --cpus-per-task=4 --mem=8G --time=01:00:00 --pty bash
```

Ou avec GPU :

```bash
srun --partition=gpu --gres=gpu:1 --cpus-per-task=4 --mem=16G --time=01:00:00 --pty bash
```

---

## 4. Consultation de l’état des jobs et des nœuds

### 4.1 File d’attente et jobs

```bash
squeue                    # Tous les jobs
squeue -u $USER           # Mes jobs
squeue -p normal          # Jobs dans la partition normal
squeue -j 12345           # Détail du job 12345
squeue --start            # Estimation du démarrage (si configuré)
```

États courants : `PENDING` (PD), `RUNNING` (R), `COMPLETING` (CG), `COMPLETED`, `FAILED`, `CANCELLED`, `TIMEOUT`.

### 4.2 Détails d’un job

```bash
scontrol show job 12345
scontrol show job 12345 -d   # Plus de détails
```

### 4.3 Historique des jobs (comptabilité)

```bash
sacct                      # Jobs récents (par défaut aujourd’hui)
sacct -j 12345             # Job 12345
sacct -u $USER --starttime 2024-01-01 --endtime 2024-01-31
sacct -l                   # Format long (nombreux champs)
sacct -o JobID,JobName,Partition,State,Elapsed,MaxRSS,ExitCode
```

### 4.4 Nœuds et partitions

```bash
sinfo                      # Vue compacte nœuds/partitions
sinfo -N -l                # Un ligne par nœud, détaillé
sinfo -p normal,gpu        # Partitions normal et gpu
scontrol show nodes        # Détail de tous les nœuds
scontrol show node compute01
```

États de nœud courants : `idle`, `allocated`, `mix`, `drain`, `down`, `reserved`.

---

## 5. Annulation et modification

### 5.1 Annuler un job

```bash
scancel 12345              # Un job
scancel -u $USER           # Tous mes jobs
scancel -p normal          # Tous les jobs dans la partition normal
scancel --state=PENDING -u $USER   # Tous mes jobs en attente
```

### 5.2 Modifier un job en attente

```bash
scontrol update jobid=12345 TimeLimit=02:00:00
scontrol update jobid=12345 Partition=high
```

Seuls les jobs **PENDING** peuvent être modifiés (selon la configuration du cluster).

---

## 6. Bonnes pratiques (résumé)

- **Toujours** demander un **temps réaliste** (`--time`) pour éviter de tuer le job ou de gaspiller des ressources.
- **Demander la mémoire** nécessaire (`--mem` ou `--mem-per-cpu`) pour éviter les OOM.
- Utiliser **partitions et QoS** adaptés (court/long, GPU, debug).
- Préférer **sbatch** pour les calculs longs et **srun** pour le debug court ou interactif.
- Dans les scripts, utiliser **srun** (et non mpirun) pour lancer des applications MPI dans un job Slurm.
- Vérifier **squeue** et **sacct** pour comprendre refus ou échecs (limites, nœuds down, etc.).

---

## 7. Intégration avec l’environnement

### 7.1 Variables d’environnement fournies par Slurm

En cours d’exécution d’un job, Slurm définit notamment :

- `SLURM_JOB_ID`, `SLURM_JOB_NAME`
- `SLURM_NODELIST`, `SLURM_NNODES`, `SLURM_NTASKS`, `SLURM_CPUS_PER_TASK`
- `SLURM_SUBMIT_DIR`, `SLURM_JOB_PARTITION`
- `SLURM_GPUS_ON_NODE`, `CUDA_VISIBLE_DEVICES` (si GPU configurés)

Utile pour des logs ou des chemins dépendant du job.

### 7.2 Modules (Environment Modules)

Beaucoup de sites utilisent **Environment Modules** pour charger compilateurs, MPI, librairies :

```bash
module avail
module load openmpi/4.1
module load gcc/11
module list
```

À appeler dans le script **sbatch** (ou en interactif) avant `srun` ou l’exécutable.

---

## 8. Référence rapide des commandes

| Commande | Usage |
|----------|--------|
| `sbatch script.sh` | Soumettre un job batch |
| `srun [options] cmd` | Lancer une tâche (souvent dans une allocation) |
| `squeue` | File d’attente |
| `scontrol show job JOBID` | Détail d’un job |
| `scontrol show node NODE` | Détail d’un nœud |
| `scancel JOBID` | Annuler un job |
| `sinfo` | État nœuds/partitions |
| `sacct` | Historique des jobs |

Pour plus de commandes système (Prometheus, Grafana, Slurm, Docker, etc.) : [Commandes-Utiles](Commandes-Utiles.md).

---

## 9. Aller plus loin

- **[Cours-HPC-Complet](Cours-HPC-Complet.md)** : architecture HPC, MPI, stockage, GPU
- **[Glossaire-et-Acronymes](Glossaire-et-Acronymes.md)** : acronymes et définitions (SLURM, PBS, MPI, etc.)
- **[Depannage](Depannage.md)** : problèmes courants et solutions
- **[FAQ](FAQ.md)** : questions fréquentes sur le cluster

---

**Niveau** : DevOps Senior / Utilisateurs avancés  
**Dernière mise à jour** : 2024
