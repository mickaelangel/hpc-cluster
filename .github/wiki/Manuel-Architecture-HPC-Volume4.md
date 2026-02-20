# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 4 : Ordonnancement, gestion des ressources et Slurm (Deep Dive)**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

L'**ordonnanceur** (scheduler) est le **cerveau** du cluster : il arbitre l'accès aux ressources entre les chercheurs, garantit le retour sur investissement du matériel et évite le chaos. Ce volume couvre la **théorie** de l'ordonnancement (FIFO, Backfill, Fairshare), l'**architecture et le déploiement** de [Slurm](Guide-SLURM-Complet.md) (slurmctld, slurmd, slurmdbd, HA, MUNGE), la **configuration avancée** (cgroups, GRES GPU, topology-aware), puis l'**exploitation et le troubleshooting**. Les [Labs 4 & 5](#-lab-4--5--déploiement-slurm-fairshare-et-cgroups) et l'[examen de fin de volume](#-examen-de-fin-de-volume-4) permettent de valider les acquis.

**Prérequis :**
- Algorithmique de base, théorie des files d'attente (Ch. 12)
- Administration Linux (systemd), TCP/IP (Ch. 13)
- Noyau Linux (cgroups, namespaces) (Ch. 14)
- Ligne de commande Linux, SQL basique (Ch. 15)

---

## Chapitre 12 : Théorie de l'ordonnancement HPC et algorithmique

### Objectifs d'apprentissage

- Maîtriser les algorithmes de base : **FIFO**, **Backfill** et **Fairshare**
- Comprendre le compromis **throughput** (taux d'occupation) vs **latency** (temps d'attente)
- Modéliser mathématiquement la **priorité** d'un job

---

### 12.1 Au-delà du FIFO : le Backfill Scheduling

Un ordonnanceur **pure FIFO** (First-In, First-Out) est inefficace en HPC : si le **Job A** (très gros) est en tête et attend que des nœuds se libèrent, il **bloque** tous les petits jobs derrière lui et laisse le cluster à moitié vide.

L'algorithme de **Backfill** résout ce problème :

1. Il calcule **à quel moment** le Job A pourra démarrer.
2. Il parcourt la file et **lance les petits jobs** (B, C) sur les nœuds inactifs.
3. **Condition stricte** : ces petits jobs doivent se **terminer avant** l'heure de démarrage prévue du Job A.

Cela exige que les utilisateurs déclarent un **temps d'exécution maximum** (le **walltime**).

---

### 12.2 La politique de Fairshare (partage équitable)

En environnement **multi-tenant**, le **Fairshare** garantit qu'un utilisateur ou un laboratoire obtient la part de ressources (CPU/GPU) pour laquelle il a **payé**, sur une période donnée.

- Si un utilisateur **consomme plus** que sa cible → sa **priorité diminue**.
- S'il **consomme moins** → sa priorité **augmente**.
- La mémoire de la consommation **s'estompe** avec le temps (facteur de **demi-vie**, half-life decay).

**Priorité finale d'un job dans Slurm** (équation composite) :

```
Priority = (W_FS × FairShare) + (W_Age × Age) + (W_QOS × QOS) + (W_Size × JobSize)
```

*(W = poids configuré par l'administrateur pour chaque facteur.)*

---

### Piège : « Le walltime paranoïaque »

Les utilisateurs demandent **48 h** de walltime pour un job qui dure **2 h**, par peur d'être coupés. **Conséquence** : le scheduler ne peut pas les utiliser pour le backfill → le cluster se vide, l'efficacité chute. Il faut **éduquer** (ou forcer via des limites) les utilisateurs à profiler leur temps d'exécution.

---

### Check-list production (Chapitre 12)

- [ ] Définir un paramètre **DefaultTime** raisonnable sur chaque partition
- [ ] Activer le plugin **sched/backfill** et ajuster **bf_window** (profondeur de prédiction)

---

## Chapitre 13 : Slurm — Architecture et déploiement

### Objectifs d'apprentissage

- Cartographier les **démons Slurm** et leurs interactions
- Mettre en place la **haute disponibilité (HA)** du contrôleur
- Intégrer **MUNGE** pour l'authentification intra-cluster

---

### 13.1 L'écosystème Slurm

Slurm est le **standard de facto** en HPC (plus de 60 % du Top500). Architecture décentralisée :

| Composant | Rôle |
|-----------|------|
| **slurmctld** (Controller) | Cerveau. Tourne sur le nœud de management. Maintient l'état du cluster, gère les files d'attente, alloue les ressources. |
| **slurmd** (Daemon) | Travailleur. Sur **chaque** nœud de calcul. Surveille les ressources, lance les jobs, nettoie après leur passage. |
| **slurmdbd** (Database Daemon) | Archiviste. Se connecte à MariaDB/MySQL pour l'**historique (Accounting)**, la hiérarchie des comptes et le **Fairshare**. |

**Schéma : Architecture haute disponibilité**

```
 +----------------+       +----------------+
 | Management 1   |       | Management 2   |
 | (Primary)      |       | (Backup)       |
 | - slurmctld    | <---> | - slurmctld    |
 | - slurmdbd     |       | - slurmdbd     |
 +-------+--------+       +--------+-------+
         |                         |
         +------------+------------+
                      | Shared State (StateSaveLocation sur NFS/Lustre)
                      v
 +-----------------------------------------+
 | Compute Nodes (slurmd)                  |
 | Node01, Node02, ..., Node1000           |
 +-----------------------------------------+
```

---

### 13.2 Authentification MUNGE

Slurm n'utilise **pas SSH** pour la communication entre démons. Il utilise **MUNGE** (MUNGE Uid 'N' Gid Emporium) : le payload (UID/GID de l'utilisateur) est **chiffré** avec une **clé symétrique partagée** (`/etc/munge/munge.key`). Tous les nœuds doivent posséder **exactement la même clé** et être **synchronisés** (NTP).

---

## Chapitre 14 : Configuration avancée (Cgroups, GPU et topologie)

### Objectifs d'apprentissage

- **Isoler** les jobs avec les **cgroups v2** (éviter les noisy neighbors)
- Configurer les **GRES** (Generic Resources) pour le placement **GPU**
- Implémenter le **topology-aware scheduling**

---

### 14.1 L'isolation par les cgroups

Sans isolation, le Job A et le Job B sur le **même nœud** peuvent se « vampiriser » (OOM Killer global). Avec le plugin **task/cgroup**, Slurm enferme chaque job, chaque step et chaque tâche dans des **Control Groups** du noyau Linux.

**Snippet production : cgroup.conf (Cgroups v2)**

```ini
CgroupAutomount=yes
ConstrainCores=yes       # Empêche un job d'utiliser les cœurs d'un autre
ConstrainRAMSpace=yes    # Tue le job s'il dépasse sa RAM (protège le nœud)
ConstrainDevices=yes     # Cache les GPUs non alloués (vital pour CUDA)
AllowedRAMSpace=98       # Laisse 2% de RAM pour l'OS (slurmd, sshd)
```

---

### 14.2 GRES (Generic Resources) et GPUs

Slurm ne gère nativement que CPU et RAM. Pour les **GPU** (ou des licences), on utilise les **GRES**.

**Snippet production : gres.conf** (nœud avec 4 GPUs)

```ini
# Déclaration des périphériques et affinité NUMA
Name=gpu Type=a100 File=/dev/nvidia0 Cores=0-15
Name=gpu Type=a100 File=/dev/nvidia1 Cores=16-31
Name=gpu Type=a100 File=/dev/nvidia2 Cores=32-47
Name=gpu Type=a100 File=/dev/nvidia3 Cores=48-63
```

On lie chaque GPU aux **cœurs CPU** sur le même bus PCIe (affinité **NUMA**) pour maximiser la bande passante et réduire la latence.

---

### 14.3 Partitions vs QOS

| Concept | Rôle |
|--------|------|
| **Partition** | Limite **matérielle ou logique** (ex. `partition=gpu`, `partition=high_mem`). File d'attente classique. |
| **QOS** (Quality of Service) | Limite **comportementale et priorité** (ex. `qos=premium` pour haute priorité, `qos=scavenger` pour jobs préemptibles sur ressources oisives). |

---

## Chapitre 15 : Exploitation et troubleshooting Slurm

### Objectifs d'apprentissage

- Diagnostiquer les pannes de nœuds (**drain**, **down**)
- Réaliser une **montée de version** sans interruption de service
- Lire et interpréter l'**Accounting**

---

### 15.1 Les états des nœuds

Surveillance via **sinfo** :

| État | Signification |
|------|----------------|
| **alloc** | 100 % alloué. Normal. |
| **idle** | 100 % libre. Normal. |
| **mix** | Partiellement alloué (ex. 10 cœurs sur 40). |
| **drain** | Nœud en vidage. Plus de nouveaux jobs ; jobs en cours peuvent finir. (Maintenance.) |
| **down** | Nœud mort ou injoignable par slurmctld. |
| **drng** | En train de se vider **et** injoignable (not responding). |

**Commande : Remettre un nœud en production après réparation**

```bash
scontrol update nodename=compute-045 state=RESUME
```

---

### 15.2 Procédure d'upgrade de Slurm (DANGER)

L'ordre est **absolu** :

1. Mise à jour de **slurmdbd** (met à jour le schéma MariaDB).
2. Mise à jour de **slurmctld** (peut gérer des slurmd plus anciens).
3. Mise à jour des **slurmd** (nœuds de calcul, progressivement).

> **DANGER** : Mettre à jour **slurmd avant slurmctld**. Le démon du nœud enverra des structures (RPCs) inconnues au contrôleur → **crash (Segfault)** ou comportement imprévisible, cluster figé.

---

## 🧪 Lab 4 & 5 : Déploiement Slurm, Fairshare et cgroups

### Énoncé

Sur votre mini-cluster (Master, Node01, Node02) :

1. Installez et configurez **MUNGE** sur tous les nœuds.
2. Déployez **MariaDB** et **slurmdbd** sur le Master.
3. Configurez **slurm.conf** avec une partition `normal` (Node01, Node02 ; 2 cœurs, 2 GB RAM chacun).
4. Activez l'**accounting** et les **cgroups**.
5. Créez un compte `science` et un utilisateur `alice` via **sacctmgr**.
6. Lancez un job demandant **plus de RAM** que physiquement disponible ou alloué.

### Critères de réussite

- **sinfo** affiche les nœuds en état **idle**.
- **sacctmgr show user** affiche `alice` liée au compte `science`.
- **Test OOM** : `srun --mem=100M dd if=/dev/zero of=/dev/null bs=200M` doit être **tué** (Killed) par le cgroup (OOM-Killer), avec statut **OUT_OF_MEMORY** dans **sacct**.

### Corrigé (snippets)

```bash
# 1. MUNGE (tous les nœuds)
dnf install munge -y
# Copier /etc/munge/munge.key depuis Master vers Node01/02
chown munge:munge /etc/munge/munge.key ; chmod 400 /etc/munge/munge.key
systemctl enable --now munge

# 2. SlurmDBD (Master)
dnf install slurmdbd mariadb-server -y
systemctl enable --now mariadb
mysql -e "create database slurm_acct; grant all on slurm_acct.* to 'slurm'@'localhost' identified by 'password';"
# Éditer /etc/slurm/slurmdbd.conf, puis démarrer le service

# 3. slurm.conf (tous les nœuds)
# NodeName=node[01-02] CPUs=2 RealMemory=2000 State=UNKNOWN
# PartitionName=normal Nodes=node[01-02] Default=YES MaxTime=24:00:00 State=UP

# 5. Création utilisateur
sacctmgr add cluster linux
sacctmgr add account science description="Projet Science" Organization="Univ"
sacctmgr add user alice account=science
```

---

## 📝 Examen de fin de volume 4

### QCM (1 point chaque)

**1.** Quel mécanisme permet à Slurm de lancer des **petits jobs courts** en attendant qu'un très gros job puisse démarrer ?  
- A) Fairshare  
- B) Preemption  
- C) **Backfill**  

**2.** Un job est en état **PD (Pending)** avec la raison **(Resources)**. Que cela signifie-t-il ?  
- A) Le job a planté à cause d'un manque de RAM  
- B) **Le job attend que les ressources (CPU/nœuds) demandées se libèrent**  
- C) L'utilisateur a dépassé son quota Fairshare et est banni  

**3.** Quel fichier de configuration permet de **lier un GPU** aux cœurs CPU les plus proches (topologie) ?  
- A) **gres.conf**  
- B) cgroup.conf  
- C) slurmdbd.conf  

---

### Question ouverte (Théorie et opérations)

Votre cluster comporte **1000 nœuds**. La commande **squeue** prend **30 secondes** ; **slurmctld** consomme **100 % d'un cœur** en permanence. Le réseau est sain. Vous constatez : `SchedulerParameters=bf_window=10080` (1 semaine de prédiction backfill) et `bf_resolution=60` (résolution 1 minute).

**Expliquez** pourquoi le contrôleur est surchargé et **comment** optimiser ces paramètres de backfill.

**Réponse attendue** : **bf_window=10080** oblige le contrôleur à **simuler** le placement de tous les jobs en attente sur **7 jours**, **minute par minute**. Charge algorithmique O(N×M) insoutenable pour le thread du scheduler. **Optimisation** : réduire **bf_window** à 1440 (24 h) ou 2880 (48 h), et augmenter **bf_resolution** à 600 (10 min) pour diviser le nombre de calculs temporels par 10.

---

### Étude de cas : « Le job fantôme et le nœud drainé »

Vous observez le nœud **node088** en état **drain**, avec la raison **(Reason) : Kill task failed**.

1. **Que s'est-il passé** au niveau de slurmd et des processus Linux du job précédent ?
2. **Quelle fonctionnalité** Slurm (cgroup.conf) aurait probablement dû empêcher cela ?
3. **Quelle séquence de commandes** pour nettoyer le nœud et le remettre en service ?

**Réponses attendues :**

1. Un job a atteint sa **limite de temps** (walltime) ou a été **annulé** (scancel), mais un **processus fils** est devenu **zombie** ou ignore **SIGKILL**. slurmd ne peut pas nettoyer complètement → Slurm **draine** le nœud par sécurité.
2. **ConstrainCores=yes** et le système **cgroups** permettent au noyau de tuer tout le sous-arbre de processus d'un coup.
3. SSH sur le nœud, trouver le processus (`htop` ou `ps aux | grep <user>`), le tuer (`kill -9`), puis **scontrol update nodename=node088 state=RESUME**.

---

## Solutions des QCM

- **Q1** : **C** — Backfill.  
- **Q2** : **B** — Pending (Resources) = attente de ressources.  
- **Q3** : **A** — gres.conf pour lier GPU et cœurs (affinité).

---

## 📋 Relecture qualité du volume 4

- [x] Couverture : Backfill, Fairshare, architecture Slurm (ctld, md, dbd), cgroups, GRES, upgrades, troubleshooting
- [x] Rigueur technique : ordre strict de l'upgrade Slurm (DANGER), liaison NUMA des GPUs dans gres.conf
- [x] Format : Markdown, formule de priorité, schémas
- [x] Pédagogie : Lab complet (MUNGE → SlurmDBD), études de cas SRE (bf_window surchargé, job fantôme)

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](Manuel-HPC-Sommaire-Complet.md)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Volume 1](Manuel-Architecture-HPC-Volume1.md)** : fondations, provisioning
- **[Manuel Architecture HPC — Volume 2](Manuel-Architecture-HPC-Volume2.md)** : réseaux, InfiniBand, sécurité
- **[Manuel Architecture HPC — Volume 3](Manuel-Architecture-HPC-Volume3.md)** : stockage parallèle, Lustre
- **[Guide SLURM Complet](Guide-SLURM-Complet.md)** : commandes utilisateur, sbatch, srun, partitions
- **[Glossaire et Acronymes](Glossaire-et-Acronymes.md)** : Slurm, MUNGE, GRES, cgroups, etc.
- **[Home](Home.md)** : page d'accueil du wiki

---

**Volume 4** — Ordonnancement, gestion des ressources et Slurm (Deep Dive)  
**Dernière mise à jour** : 2024
