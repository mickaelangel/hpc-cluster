# 🏛️ Dictionnaire encyclopédique HPC

> **Standard de l'ouvrage — Niveau Doctorat / Architecte — Format encyclopédique rigoureux**

---

## Présentation du dictionnaire

Ce dictionnaire adopte un **format encyclopédique** à entrées détaillées. Chaque entrée majeure suit la structure ci-dessous, permettant une lecture à la fois **rigoureuse** et **opérationnelle**.

**Structure type d'une entrée :**

| Section | Contenu |
|--------|--------|
| **Définition rigoureuse** | Définition précise, sans ambiguïté. |
| **Pourquoi c'est important** | Impact sur les performances, les coûts ou l'architecture. |
| **Comment ça marche (internals)** | Mécanismes internes (algorithmes, couches logicielles, matériel). |
| **Bonnes pratiques / Mauvaises pratiques** | Ce qu'il faut faire et éviter. |
| **Commandes / outils associés** | Outils de diagnostic et de configuration. |
| **Paramètres & tuning** | Fichiers de config, variables, réglages typiques. |
| **Troubleshooting rapide** | Symptômes → Causes → Actions. |
| **Renvois croisés** | Voir aussi (autres entrées du dictionnaire ou du manuel). |
| **Références** | Articles, livres, documentation officielle. |

Les entrées sont classées **alphabétiquement** par nom principal. Ce document constitue l'**extrait fondamental** ; le dictionnaire complet (800–1500 entrées) peut être étendu progressivement selon le même format.

---

## B

### Backfill Scheduling (Ordonnancement par remplissage)

**Définition rigoureuse**  
Algorithme d'ordonnancement **non préemptif** qui autorise des tâches (jobs) de **faible priorité** et de **courte durée** à s'exécuter **avant** des tâches de haute priorité, à la condition stricte que leur exécution **n'entraîne aucun retard** sur l'heure de démarrage calculée (Start Time) de la tâche prioritaire en tête de file.

**Pourquoi c'est important**  
En FIFO classique, un job demandant 100 nœuds bloque toute la file alors qu'il ne reste que 90 nœuds libres → ces 90 nœuds restent inactifs (« drainage »). Le Backfill permet de porter l'**utilisation globale** d'un supercalculateur de ~60 % à souvent **plus de 95 %**, en garantissant un retour sur investissement massif sans pénaliser les gros calculs scientifiques.

**Comment ça marche (niveau internals)**  
- Slurm maintient : la **file d'attente** triée par priorité (Fairshare) et l'**état des nœuds**.  
- Le thread **sched/backfill** simule le placement du **job en tête** (Job A), parcourt le temps futur jusqu'à trouver assez de nœuds qui se libèrent, et **verrouille** cette réservation temporelle.  
- Il examine les jobs suivants (B, C…). Si le Job B demande 10 nœuds pendant 2 h et que 10 nœuds sont **libres maintenant** et ne seront réquisitionnés par A que dans 3 h, le Backfill **lance B immédiatement**.  
- **Contrainte** : chaque job doit déclarer un **Walltime** (temps max d'exécution). L'algorithme utilise ce temps déclaré pour ses prédictions.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Imposer des Walltimes par défaut courts (ex. 1 h) sur les partitions standard ; pénaliser ou restreindre les utilisateurs qui demandent systématiquement 7 jours pour des jobs de 10 minutes.  
- **Mauvaise** : Configurer **bf_window** sur 30 jours → le contrôleur passe 100 % de son CPU à calculer des calendriers théoriques inutiles.

**Commandes / outils associés**  
- `sdiag` : statistiques internes du thread backfill (temps moyen du cycle, profondeur de file traitée).  
- `squeue --start` : heure de démarrage **prédictive** pour les jobs en attente.

**Paramètres & tuning (slurm.conf)**  
- `SchedulerParameters=bf_window=1440` : limite la prédiction à 24 h (clusters très chargés).  
- `bf_resolution=600` : blocs de 10 min au lieu de 1 min → réduction forte de la complexité.  
- `bf_max_job_test=1000` : limite le nombre de jobs que le backfill tente de caser par itération.

**Troubleshooting rapide**  
- **Symptômes** : `squeue` met 30 s à répondre ; slurmctld à 100 % sur un cœur.  
- **Causes** : Boucle Backfill trop lourde **O(N×M)** (trop de jobs + fenêtre trop profonde).  
- **Actions** : Augmenter `bf_resolution`, diminuer `bf_window` ou `bf_max_job_test` ; `scontrol reconfigure`.

**Renvois croisés**  
Voir aussi : Fairshare, Walltime, Slurmctld, Scheduler.

**Références**  
Feitelson, D. G., et al. (2001). *The Case for Workload-Based Evaluation of HPC Systems.*

---

### BeeGFS (Bee Parallel File System)

**Définition rigoureuse**  
Système de **fichiers parallèles** (POSIX) à logiciel libre, développé par ThinkParQ (ex Fraunhofer), qui répartit **données et métadonnées** sur des serveurs de stockage (**storage servers**) et des serveurs de métadonnées (**metadata servers**) distincts, avec un **client en espace utilisateur** (FUSE ou noyau) et un protocole propriétaire sur TCP ou RDMA.

**Pourquoi c'est important**  
Alternative **open-source** à Lustre pour les clusters HPC et les environnements où la simplicité de déploiement et l'**agilité** (ajout de nœuds à chaud, pas de dépendance à un noyau Lustre spécifique) priment. Très utilisé en recherche et en mid-range HPC ; performances comparables à Lustre pour de nombreux workloads (I/O séquentiel, petits fichiers si les MDS sont bien dimensionnés).

**Comment ça marche (niveau internals)**  
- **Metadata** : un ou plusieurs MDS gèrent les noms, permissions, layout (répartition des blocs sur les storage targets).  
- **Storage** : les **storage targets** (OST équivalent) stockent les blocs de données ; le client connaît le **layout** et envoie les I/O directement aux storage servers concernés (parallélisme).  
- Pas de DLM centralisé comme Lustre ; cohérence via protocole et verrous côté serveur. Support **RDMA** (verbs) pour les chemins de données à faible latence.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Dimensionner les MDS (CPU, RAM) pour la charge en métadonnées ; utiliser des **stripes** adaptées à la taille des fichiers ; réseau dédié (ou VLAN) pour le trafic BeeGFS.  
- **Mauvaise** : Un seul MDS pour des millions de petits fichiers sans cache métadonnées côté client → goulot MDS.

**Commandes / outils associés**  
- `beegfs-ctl` : statut des services, listes des storage/metadata servers, paramètres.  
- `beegfs-df` : utilisation par storage target (équivalent `lfs df`).  
- Fichiers de config : `/etc/beegfs/beegfs-client.conf`, `beegfs-storage.conf`, `beegfs-meta.conf`.

**Paramètres & tuning**  
- **tuneFileReadSize**, **tuneFileWriteSize** : tailles de transfert.  
- **tuneRemoteFSync** : comportement fsync (sécurité vs perfs).  
- **connInterfaces**, **connNetFilter** : binding réseau / interfaces.

**Troubleshooting rapide**  
- **Symptômes** : I/O lents, erreurs « No route to host » ou déconnexions.  
- **Causes** : MDS ou storage server down ; réseau saturé ou mauvaise config interface.  
- **Actions** : `beegfs-ctl --getentryinfo` ; vérifier les services (`systemctl status beegfs-*`) et les logs ; tester la connectivité entre clients et serveurs.

**Renvois croisés**  
Voir aussi : Lustre, Striping, POSIX, MPI-IO, IOR, Stockage parallèle.

**Références**  
ThinkParQ. *BeeGFS Documentation.* — Lustre Operations Manual (comparaison conceptuelle).

---

### Burst Buffers (Tampons d'éclatement)

**Définition rigoureuse**  
Couche de stockage **intermédiaire**, généralement à **latence très faible** (SSD/NVMe, voire NVDIMM ou mémoire), positionnée entre les **nœuds de calcul** et le système de fichiers parallèle de production (Lustre, etc.), utilisée pour **absorber les pics d'I/O** (checkpoints, restarts, sorties massives) sans saturer le FS global ni dégrader les autres jobs.

**Pourquoi c'est important**  
Les applications HPC ont des phases d'I/O **très bursty** : des milliers de processus écrivent en même temps un checkpoint, puis reprennent le calcul. Si tout transite directement vers Lustre, le **MDS** et les **OST** subissent une tempête de requêtes → latence qui explose et débit effectif qui chute pour tout le monde. Les burst buffers **découplent** : le job écrit d'abord sur un espace rapide (nœud local ou dédié), puis un **drain** asynchrone pousse les données vers Lustre.

**Comment ça marche (niveau internals)**  
- **Modèle typique** : espace **par job** ou **par nœud** sur NVMe (tmpfs, LVM, ou FS local). L'application écrit en **scratch local** ; un démon ou un script post-job copie vers Lustre.  
- **Intégration Slurm** : **GRES** (Generic Resource) peut réserver des « burst buffer » ; des plugins ou des **prolog/epilog** allouent et libèrent l'espace.  
- **Niveau avancé** : systèmes dédiés (DataWarp, DDN IME, etc.) avec API et intégration scheduler.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Réserver une **taille cohérente** avec la taille du checkpoint (Slurm `--bb` ou partition dédiée) ; prévoir un **drain** fiable (retry, monitoring) pour éviter de perdre des données.  
- **Mauvaise** : Burst buffer trop petit → dépassement et écriture directe sur Lustre (pic non absorbé) ; pas de politique de purge → disques pleins et jobs suivants en échec.

**Commandes / outils associés**  
- Slurm : `sbatch --bb "capacity=100G"` (si burst buffer GRES configuré).  
- `scontrol show burst` (si plugin activé).  
- Scripts prolog/epilog pour allouer un répertoire local (ex. `/tmp/job_$SLURM_JOB_ID`) et copier vers Lustre en fin de job.

**Paramètres & tuning**  
- Taille par job (capacity), politique de drain (immédiat vs différé), durée de rétention.  
- Choix du backend : tmpfs (RAM), NVMe local, ou appliance dédiée.

**Troubleshooting rapide**  
- **Symptômes** : Job échoue avec « No space left » sur le burst buffer ; ou checkpoint jamais visible sur Lustre.  
- **Causes** : Capacité sous-dimensionnée ; script de drain en échec (réseau, quota Lustre).  
- **Actions** : Vérifier la taille réservée et l'usage effectif ; consulter les logs du prolog/epilog et du drain.

**Renvois croisés**  
Voir aussi : Lustre, Striping, Checkpoint, I/O burst, Slurm GRES, Scratch.

**Références**  
NVIDIA Data Center. *Burst Buffer Concepts.* — Documentation Slurm : *Burst Buffer Guide.*

---

## C

### Cgroups v2 (Control Groups v2) — Contexte HPC

**Définition rigoureuse**  
Mécanisme du **noyau Linux** (depuis 2.6.24, unifié en v2) permettant de **grouper des processus** dans une hiérarchie et d'appliquer des **limites et compteurs** (CPU, mémoire, I/O, devices) à chaque groupe. En HPC, **Slurm** utilise les **Cgroups v2** pour **isoler** chaque job (ou step) dans un sous-arbre dédié, avec des plafonds stricts sur la RAM et les CPU visibles.

**Pourquoi c'est important**  
Sans isolation, un job qui dépasse sa réserve mémoire peut **affamer** les autres processus du nœud et provoquer un **OOM global** ; le noyau peut alors tuer **slurmd** ou un processus critique. Avec **ConstrainRAMSpace=yes** et **AllowedRAMSpace=98**, Slurm crée un **cgroup** par job avec une limite mémoire (ex. 250 Go sur un nœud de 256 Go). Si le job dépasse, l'**OOM-Killer** n'agit **que dans ce cgroup** → seul le job est tué, l'OS et les autres jobs (ou slurmd) restent intacts.

**Comment ça marche (niveau internals)**  
- **Cgroups v2** : hiérarchie unique sous `/sys/fs/cgroup/` ; sous-arbre **slurm** (ou `slurmstepd`) avec un répertoire par **job_id** et **step_id**.  
- Slurm (slurmd) crée le cgroup au lancement du step, y **attache** les processus du job, et écrit les **limites** (memory.max, cpuset.cpus, etc.).  
- À la fin du job, slurmd supprime le cgroup ; le noyau garantit qu'aucun processus du job ne peut dépasser les limites du groupe.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Activer **ConstrainCores=yes**, **ConstrainRAMSpace=yes**, **ConstrainDevices=yes** ; fixer **AllowedRAMSpace** à 95–98 % pour laisser de la marge au système.  
- **Mauvaise** : Désactiver les cgroups pour « simplifier » → risque OOM global et nœuds en drain ; ou AllowedRAMSpace=100 % (aucune marge pour le noyau et les démons).

**Commandes / outils associés**  
- `cat /sys/fs/cgroup/.../memory.current` : usage mémoire du cgroup (depuis l'hôte).  
- `cgroup.conf` (Slurm) : **CgroupAutomount=yes**, **ConstrainCores**, **ConstrainRAMSpace**, **AllowedRAMSpace**, **ConstrainDevices**.  
- `systemd-cgls` : arbre des cgroups (si Slurm utilise cgroup v2 avec systemd).

**Paramètres & tuning**  
- **slurm.conf** : `TaskPlugin=task/cgroup` (ou task/cgroup/v2).  
- **cgroup.conf** : **ConstrainCores**, **ConstrainRAMSpace**, **AllowedRAMSpace**, **ConstrainDevices** ; **CgroupAutomount=yes** pour que Slurm gère le montage.

**Troubleshooting rapide**  
- **Symptômes** : Job tué sans message ; nœud en drain « Kill task failed ».  
- **Causes** : Dépassement mémoire → OOM dans le cgroup ; ou cgroup non monté / permission refusée.  
- **Actions** : Vérifier `dmesg` et `sacct -j <id>` (ExitCode, MaxRSS) ; confirmer que **cgroup.conf** et **TaskPlugin** sont cohérents ; tester avec un job qui alloue volontairement trop de RAM.

**Renvois croisés**  
Voir aussi : OOM-Killer, Slurmd, AllowedRAMSpace, ConstrainRAMSpace, Slurm.

**Références**  
Documentation noyau Linux : *Control Groups v2.* — Slurm : *Cgroup Guide*, *cgroup.conf.*

---

## D

### DLM (Distributed Lock Manager) & Cohérence POSIX

**Définition rigoureuse**  
Le **DLM** (gestionnaire de verrous distribué), dans Lustre le **LDLM**, est le sous-système qui garantit la **cohérence des données et des métadonnées** (norme POSIX) entre des milliers de clients concurrents. Il assure que si le client A modifie un fichier, le client B ne lira pas une donnée obsolète ou corrompue présente dans son cache local.

**Pourquoi c'est important**  
C'est l'un des composants les plus **complexes et sensibles** d'un système de fichiers parallèle. Sans DLM, les lectures/écritures concurrentes provoqueraient des **corruptions silencieuses**. En revanche, l'échange constant de messages pour accorder, révoquer ou vérifier les verrous (**lock traffic**) est une cause majeure de **dégradation des performances** sur un cluster mal utilisé.

**Comment ça marche (niveau internals)**  
- Lustre utilise des **verrous d'étendue** (Extent Locks).  
- Si le **client A** veut écrire les octets 0–1 M d'un fichier, il demande un **verrou exclusif (Write)** à l'OSS. L'OSS l'accorde ; le client A écrit en cache local puis envoie les données à l'OSS.  
- Si le **client B** veut lire les mêmes octets, l'OSS envoie une **AST** (Asynchronous System Trap) au client A pour lui ordonner de **vider (flush)** son cache vers le disque et de **relâcher** le verrou (ou de le rétrograder en lecture partagée).  
- Une fois fait, l'OSS accorde le verrou de **lecture** au client B.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Utiliser les **API collectives MPI-IO** (HDF5, NetCDF) qui orchestrent les processus pour qu'un seul gère une grande plage contiguë → réduction des conflits de verrous.  
- **Mauvaise** : **False sharing** — 1000 processus écrivent chacun 8 octets dans le même fichier, entremêlant les écritures. Le DLM passe 99 % du temps à révoquer et réassigner des verrous → débit qui tombe à quelques Ko/s.

**Commandes / outils associés**  
- `lctl get_param ldlm.namespaces.*.lock_count` : nombre de verrous actifs.

**Paramètres & tuning**  
- **obd_timeout** (défaut 100 s) : si un client qui détient un verrou exclusif crashe (ex. coupure réseau) et ne répond pas aux AST, le serveur attend ce délai avant de l'**évincer** (Eviction) et de libérer de force le verrou.

**Troubleshooting rapide**  
- **Symptômes** : Des dizaines de jobs figent (processus en état **D** — Uninterruptible Sleep). `dmesg` : `LustreError: ... ping timeout`.  
- **Causes** : Un client ou un routeur LNet défaillant détient des verrous et ne répond plus ; le MDS/OSS attend **obd_timeout** avant d'agir.  
- **Actions** : Attendre l'éviction automatique. Si ça persiste : isoler ou redémarrer le client fautif (identifié dans les logs MGS).

**Renvois croisés**  
Voir aussi : POSIX, False Sharing, Striping, MPI-IO.

**Références**  
Braam, P. J. (2019). *Lustre File System: Architecture and Internals.*

---

## G

### GPUDirect RDMA (Remote Direct Memory Access for GPUs)

**Définition rigoureuse**  
Technologie matérielle et logicielle (NVIDIA) permettant à des **périphériques sur le bus PCI Express** (ex. carte réseau InfiniBand Mellanox) d'effectuer des **accès mémoire directs (DMA)** vers et depuis la **mémoire locale d'un GPU (VRAM)**, en **contournant** la mémoire système (RAM) et le processeur (CPU) de l'hôte.

**Pourquoi c'est important**  
En entraînement distribué (LLM, Deep Learning), les GPU échangent massivement des **gradients** (collectives type AllReduce). Sans GPUDirect : VRAM → PCIe → RAM CPU → PCIe → Carte réseau → … Ce double saut **sature le bus PCIe** et le contrôleur mémoire, limite la bande passante et augmente la latence → les GPU restent « affamés » de données.

**Comment ça marche (niveau internals)**  
- Spécification **PCIe** (DMA standard) et mappage **BAR** (Base Address Register).  
- Le driver NVIDIA **expose la VRAM** du GPU dans l'espace d'adressage physique via le **BAR1**.  
- Le module noyau réseau (ex. **nv_peer_mem** ou OFED) mappe ces adresses PCIe virtuelles.  
- La **HCA** (carte réseau) lit/écrit **directement** dans les adresses du GPU sur le bus PCIe (souvent via les PCIe Switches de la carte mère), **sans réveiller le CPU**.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : **Topology-aware placement** : la carte réseau doit être sur la **racine PCIe (Root Complex)** qui contrôle le GPU avec lequel elle communique ; sinon le transfert traverse l'interconnexion inter-CPU (QPI/UPI) et les perfs s'effondrent.  
- **Mauvaise** : Activer l'**IOMMU** de façon trop restrictive dans le BIOS sans configurer les groupes IOMMU pour le passthrough → blocage du Peer-to-Peer.

**Commandes / outils associés**  
- `nvidia-smi topo -m` : matrice de topologie (PIX, PXB, SYS) entre GPU et NIC.  
- `ib_write_bw --use_cuda=<gpu_id>` : test bande passante InfiniBand directe depuis/vers la VRAM.

**Paramètres & tuning**  
- Variables **NCCL** : `NCCL_P2P_DISABLE=0`, `NCCL_NET_GDR_LEVEL=5` (niveau minimum pour autoriser GPUDirect RDMA).

**Troubleshooting rapide**  
- **Symptômes** : perfs d'entraînement IA multi-nœuds qui plafonnent ; **nvtop** → PCIe saturé (Tx/Rx) ; **htop** → fort %sys CPU.  
- **Causes** : GPUDirect RDMA **inactif** ; fallback par la mémoire système. OFED sans support CUDA ou module noyau peer-to-peer manquant.  
- **Actions** : Vérifier le module noyau (`lsmod | grep nv_peer_mem` ou équivalent OFED). Relancer les services de la carte réseau.

**Renvois croisés**  
Voir aussi : NCCL, PCIe, InfiniBand, RDMA, NUMA.

**Références**  
NVIDIA Corporation. (2023). *Developing a Linux Kernel Module using GPUDirect RDMA.*

---

### GPU Tensor Cores (Cœurs tenseur)

**Définition rigoureuse**  
Unités de calcul **matriciel** intégrées aux GPU NVIDIA (à partir de Volta, puis Turing, Ampere, Hopper) et conçues pour accélérer les opérations **GEMM** (General Matrix Multiply) et les **transformations** de basse précision (FP16, BF16, INT8, TF32), au cœur des **réseaux de neurones** (convolutions, attention) et du calcul scientifique mixte précision.

**Pourquoi c'est important**  
En **IA / Deep Learning**, la majorité des FLOPs sont des multiplications matricielles. Les **Tensor Cores** exécutent des **blocs** (ex. 16×16×16) en une seule instruction avec un débit (TFLOP/s) **plusieurs fois supérieur** aux cœurs CUDA classiques pour ces opérations. Sans Tensor Cores, l'entraînement de grands modèles (LLM, vision) serait considérablement plus long ; en HPC scientifique, les bibliothèques (cuBLAS, cuDNN) les utilisent automatiquement pour les kernels compatibles.

**Comment ça marche (niveau internals)**  
- **Architecture** : sous-unités dédiées au **D = A × B + C** (matrix multiply-accumulate) en FP16/BF16/INT8/TF32 ; accumulation souvent en FP32.  
- **Logiciel** : les API CUDA (WMMA), cuBLAS (GEMM), cuDNN (convolutions) génèrent des instructions **tensor** ; le compilateur (NVCC, libs) doit cibler la bonne architecture (sm_70, sm_80, etc.).  
- **NVLink** (entre GPU) et **NVSwitch** (multi-GPU) permettent d'alimenter les Tensor Cores en données à haut débit.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Utiliser **FP16** ou **BF16** (et TF32 si Ampere+) quand la précision le permet ; choisir des **tailles de batch et de matrice** alignées sur les blocs Tensor (multiples de 8/16) ; profiler avec **Nsight Compute** pour confirmer l'utilisation des Tensor Cores.  
- **Mauvaise** : Forcer FP64 partout → les Tensor Cores ne s'activent pas ou peu ; kernels custom mal alignés → régression par rapport aux cœurs CUDA classiques.

**Commandes / outils associés**  
- `nvidia-smi` : modèle GPU, utilisation.  
- **Nsight Compute** : rapport par kernel (utilisation Tensor Cores, throughput).  
- **PyTorch / TensorFlow** : `torch.autocast`, `tf.keras.mixed_precision` pour activer FP16/BF16 et exploiter les Tensor Cores.

**Paramètres & tuning**  
- **CUDA_ARCH** (compilation) : sm_70 (Volta), sm_80 (Ampere), sm_90 (Hopper).  
- **TF32** (Ampere+) : `NVIDIA_TF32_OVERRIDE=1` pour forcer TF32 en matmul (par défaut activé dans beaucoup de frameworks).  
- **Environment** : `NVIDIA_TF32_OVERRIDE=0` pour désactiver si besoin de reproductibilité FP32 stricte.

**Troubleshooting rapide**  
- **Symptômes** : Performances GPU « normales » alors qu'on attend une accélération (ex. entraînement pas plus rapide qu'en FP32).  
- **Causes** : Kernel non éligible aux Tensor Cores (taille, type) ; précision FP64 ; driver/CUDA trop ancien.  
- **Actions** : Vérifier l'architecture GPU et la version CUDA ; profiler avec Nsight Compute ; activer mixed precision (FP16/BF16) dans le framework.

**Renvois croisés**  
Voir aussi : NVLink, GPUDirect RDMA, NCCL, cuBLAS, cuDNN, Roofline, Mixed Precision.

**Références**  
NVIDIA. *Tensor Core Programming (CUDA).* — *NVIDIA A100 Tensor Core GPU Architecture.*

---

## H

### Hugepages & TLB (Translation Lookaside Buffer)

**Définition rigoureuse**  
Les **Hugepages** sont des blocs de mémoire vive gérés par le noyau Linux dont la taille est **supérieure à la page standard** (généralement 4 Ko). En HPC on utilise des pages de **2 Mo** ou **1 Go** pour optimiser la **traduction d'adresses virtuelles en physiques** par le processeur (MMU).

**Pourquoi c'est important**  
Un code allouant 128 Go de RAM représente, en pages 4 Ko, **33 millions de pages**. Le CPU utilise un cache matériel (le **TLB**) pour mémoriser où se trouvent ces pages ; le TLB ne contient que quelques milliers d'entrées → **saturation** (TLB misses). Chaque miss impose un **Page Walk** en RAM et dégrade fortement les perfs (jusqu'à ~20 % de pénalité). Avec des Hugepages de 1 Go, 128 Go = **128 entrées** → le TLB ne sature pas.

**Comment ça marche (niveau internals)**  
- La **MMU** parcourt des structures arborescentes (Page Directory, Page Table). Une Hugepage permet de **s'arrêter plus haut** dans l'arbre.  
- **Explicit Hugepages** : réservées au démarrage, contiguës ; l'application doit les demander (ex. `mmap()` avec `MAP_HUGETLB`).  
- **Transparent Hugepages (THP)** : le noyau (khugepaged) regroupe en arrière-plan des pages 4 Ko en pages 2 Mo.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Activer les **Hugepages explicites** pour les buffers RDMA/InfiniBand → accélération de la **Memory Registration** par la carte réseau.  
- **Mauvaise** : Laisser **THP en mode always** sur des serveurs critiques (Slurmdbd, MDS Lustre) : la défragmentation provoque des **pics de latence** (system jitter).

**Commandes / outils associés**  
- `cat /proc/meminfo | grep Huge` : vérifier l'allocation des pages.  
- `perf stat -e dTLB-load-misses ./code` : mesurer le goulot TLB.

**Paramètres & tuning**  
- **GRUB** : `hugepagesz=1G hugepages=64`.  
- **Désactiver THP** : `echo never > /sys/kernel/mm/transparent_hugepage/enabled`.

**Troubleshooting rapide**  
- **Symptômes** : CPU à 100 % sur un processus **kcompactd0** ; job utilisateur très ralenti.  
- **Causes** : THP activé, mémoire physique fragmentée ; le noyau cherche des blocs contigus de 2 Mo.  
- **Actions** : Désactiver THP ou libérer du contigu (ex. `echo 3 > /proc/sys/vm/drop_caches`).

**Renvois croisés**  
Voir aussi : NUMA, Perf, RDMA, OS Jitter.

**Références**  
Gorman, M. (2004). *Understanding the Linux Virtual Memory Manager.*

---

## M

### MPI Collectives — AllReduce (Collectives MPI)

**Définition rigoureuse**  
Les **collectives MPI** sont des opérations de **communication de groupe** où **tous** les processus d'un communicateur participent selon un schéma défini par la norme MPI. **MPI_Allreduce** est une collective qui combine (réduction : somme, max, min, etc.) les données **locales** de chaque rang puis **redistribue le résultat à tous** les rangs, de sorte qu'à la fin chaque processus possède la **même valeur** (ou le même vecteur) globale.

**Pourquoi c'est important**  
En calcul parallèle (optimisation, deep learning distribué), **AllReduce** est la collective la **plus coûteuse** en bande passante et en latence : chaque nœud doit contribuer et recevoir le résultat. Les algorithmes (arbre binaire, ring, réduction puis broadcast) et l'**overlap** calcul/communication déterminent la scalabilité. En **IA**, les frameworks (NCCL, Horovod) implémentent des **AllReduce** optimisés (ring, tree) sur GPU pour la synchronisation des gradients ; la performance du réseau (InfiniBand, RoCE) et du logiciel (NCCL, MPI) est critique.

**Comment ça marche (niveau internals)**  
- **MPI_Allreduce** : la bibliothèque MPI choisit un algorithme (souvent **ring AllReduce** ou **recursive halving/doubling**) en fonction de la taille du message et du nombre de rangs.  
- **Ring AllReduce** : les rangs forment un anneau ; en N-1 étapes, chaque rang envoie un bloc au suivant et reçoit du précédent ; à la fin tous ont la somme complète. Bande passante proche de l'optimal.  
- **Implémentations** : OpenMPI, MPICH, MVAPICH utilisent des chemins optimisés (RDMA, collectives offload) ; **NCCL** côté GPU fournit des collectives GPU-GPU (AllReduce, AllGather, ReduceScatter) très optimisées.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Réduire la **fréquence** des AllReduce (accumuler des gradients avant de réduire) ; utiliser des **tailles de message** alignées ; profiler avec **IPM** ou **TAU** pour identifier les collectives dominantes.  
- **Mauvaise** : AllReduce à chaque itération avec des messages minuscules → latence dominante ; ou choix d'un algorithme MPI sous-optimal pour la taille de message (vérifier les tuned collectives).

**Commandes / outils associés**  
- **MPI** : `mpirun -np N ./app` ; variables `MPICH_*`, `OMPI_*` pour forcer l'algorithme de collective.  
- **NCCL** : `NCCL_DEBUG=INFO`, `NCCL_ALGO=Ring` (ou Tree) pour le debug.  
- **OSU Micro-Benchmarks** : `osu_allreduce` pour mesurer la latence et le débit AllReduce en fonction de la taille.

**Paramètres & tuning**  
- **OpenMPI** : `--mca coll_tuned_use_dynamic_rules 1`, `coll_tuned_allreduce_algorithm` (pour forcer ring, binominal, etc.).  
- **UCX** : choix du transport (rc, ud) pour les collectives.  
- **NCCL** : `NCCL_IB_DISABLE` (forcer TCP), `NCCL_NET` (sélection du backend).

**Troubleshooting rapide**  
- **Symptômes** : Application MPI ou entraînement distribué très lent ; un rang « en retard » bloque tout le monde.  
- **Causes** : AllReduce dominant ; déséquilibre de charge ; réseau lent ou pertes ; algorithme de collective inadapté.  
- **Actions** : Profiler (IPM, Nsight Systems) ; lancer `osu_allreduce` entre les mêmes nœuds ; vérifier les erreurs réseau (ibstat, RoCE PFC).

**Renvois croisés**  
Voir aussi : MPI, RDMA, NCCL, GPUDirect RDMA, InfiniBand, RoCE v2, OSU Benchmarks.

**Références**  
MPI Forum. *MPI-4.0 Standard.* — Thakur et al. *Optimization of Collective Communication Operations in MPICH.*

---

## N

### NUMA (Non-Uniform Memory Access) & Pinning

**Définition rigoureuse**  
Architecture multiprocesseur où le **temps d'accès** à une zone de la mémoire principale **dépend de l'emplacement physique** de cette mémoire par rapport au processeur qui fait la requête. Chaque socket (ou chiplet) a son **contrôleur mémoire local** ; accéder à la mémoire d'un autre socket impose de traverser un **bus inter-processeur** (ex. Intel UPI, AMD Infinity Fabric).

**Pourquoi c'est important**  
Un **mauvais tuning NUMA** est une cause majeure de sous-performance en HPC. Si un processus MPI alloue des tableaux dans la RAM du **CPU 2** mais s'exécute sur le **CPU 1**, la requête traverse le bus inter-socket : bande passante **divisée par deux**, latence **+30 % à +50 %**. Les caches **L3** (spécifiques au nœud NUMA) deviennent peu efficaces.

**Comment ça marche (niveau internals)**  
- Linux utilise par défaut la politique **First Touch**. La mémoire n'est pas allouée physiquement au `malloc()` (adresses virtuelles seulement), mais au **premier accès en écriture** (page fault). Linux place alors la **page physique** dans la RAM du **nœud NUMA** sur lequel le thread s'exécute à ce moment.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Toujours **épingler** (pinning / binding) les processus aux cœurs. En OpenMP, **paralléliser l'initialisation** des grands tableaux pour que chaque thread fasse le First Touch sur sa fraction de mémoire locale.  
- **Mauvaise** : Utiliser `numactl --interleave=all` pour un code de dynamique des fluides → répartition des pages sur tous les nœuds → statistiquement ~50 % (bi-socket) d'accès **distants** et lents.

**Commandes / outils associés**  
- `numactl -H` : nœuds matériels, mémoire par nœud, **matrice des distances** (pénalités).  
- `lstopo` (hwloc) : représentation graphique des cœurs, caches L3 partagés et nœuds NUMA.

**Paramètres & tuning**  
- **Slurm** : `TaskPlugin=task/affinity,task/cgroup`.  
- **MPI** : `--bind-to core --map-by socket` (OpenMPI).  
- **OS** : Désactiver **numad** sur les nœuds de calcul (éviter que l'OS déplace des processus déjà optimisés par Slurm/MPI).

**Troubleshooting rapide**  
- **Symptômes** : benchmark **STREAM** affiche 150 Go/s au lieu de 300 Go/s.  
- **Causes** : Migration des threads d'un CPU à l'autre (OS scheduler jitter) ou mémoire allouée de façon distante.  
- **Actions** : Relancer avec `OMP_PLACES=cores OMP_PROC_BIND=close` ou `numactl --cpunodebind=0 --membind=0 ./stream`.

**Renvois croisés**  
Voir aussi : Affinity, MPI, Hugepages, Roofline Model, Cgroups.

**Références**  
Drepper, U. (2007). *What Every Programmer Should Know About Memory.*

---

### NVLink (NVIDIA High-Speed Interconnect)

**Définition rigoureuse**  
Interconnexion **point à point** à **très haut débit** et **faible latence** développée par NVIDIA pour connecter **plusieurs GPU** au sein d'un même nœud (ou entre nœuds avec NVLink Switch). Elle permet des transferts **GPU-GPU** directs (mémoire à mémoire) sans passer par le **PCIe** de l'hôte, avec une bande passante agrégée bien supérieure (ex. 600 Go/s par paire de GPU en NVLink 3.0) et une latence plus basse que PCIe.

**Pourquoi c'est important**  
En **multi-GPU** (entraînement, inference, calcul scientifique), les GPU échangent des **tenseurs** et des **gradients** en permanence. Le **PCIe** (typiquement 32 Go/s en PCIe 4.0 x16) devient le **goulot** dès que deux GPU ou plus partagent des données. **NVLink** multiplie la bande passante (jusqu'à des centaines de Go/s) et réduit la latence, ce qui permet de **scaler** les applications sur 4, 8 ou 16 GPU par nœud sans être limité par le bus.

**Comment ça marche (niveau internals)**  
- **Topologie** : liens **symétriques** entre GPU (mesh ou switch). Chaque lien est un bus série multi-lanes (NVLink 3 : 50 Gb/s par sens par lien ; plusieurs liens par GPU).  
- **NVSwitch** (nœuds type DGX) : switch interne qui connecte tous les GPU en full bisection, évitant les chemins en plusieurs sauts.  
- **Software** : NCCL, CUDA Unified Memory, et les runtimes MPI/GPU utilisent NVLink automatiquement quand il est disponible ; `nvidia-smi topo -m` affiche la topologie.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Préférer les nœuds avec **NVLink** (ou NVLink Switch) pour les jobs multi-GPU ; lier les processus aux GPU **proches** (même NVLink domain) via **CUDA_VISIBLE_DEVICES** ou Slurm **GPU binding** ; vérifier la topologie avec `nvidia-smi topo -m`.  
- **Mauvaise** : Placer 8 GPU sur un nœud sans NVLink et saturer le PCIe ; ou binder les rangs MPI de façon à ce que les paires qui communiquent le plus soient sur des GPU non reliés par NVLink.

**Commandes / outils associés**  
- `nvidia-smi topo -m` : matrice de connectivité GPU (NVLink, PCIe).  
- `nvidia-smi nvlink --status` : état des liens NVLink.  
- **NCCL** : `NCCL_DEBUG=INFO` pour voir les chemins utilisés (NVLink vs PCIe).

**Paramètres & tuning**  
- **Slurm** : **Gres** et **topology/plugin** pour réserver des GPU et (si supporté) respecter la topologie.  
- **NCCL** : utilise NVLink par défaut quand disponible ; pas de paramètre spécifique à activer en général.  
- **CUDA** : pas de réglage utilisateur ; le driver et le runtime sélectionnent le chemin.

**Troubleshooting rapide**  
- **Symptômes** : Multi-GPU plus lent qu'attendu ; bande passante inter-GPU faible.  
- **Causes** : NVLink absent (carte ou nœud sans NVLink) ; topologie non respectée (binding) ; un lien NVLink down (rare).  
- **Actions** : `nvidia-smi topo -m` et `nvlink --status` ; vérifier le binding des processus aux GPU ; comparer avec un nœud connu NVLink.

**Renvois croisés**  
Voir aussi : GPUDirect RDMA, GPU Tensor Cores, NCCL, PCIe, Multi-GPU, Slurm GRES.

**Références**  
NVIDIA. *NVLink and NVSwitch.* — *NVIDIA DGX Architecture.*

---

## O

### OOM-Killer (Out-Of-Memory Killer)

**Définition rigoureuse**  
Mécanisme de **survie** du noyau Linux : lorsque la mémoire physique (RAM) et l'échange (Swap) sont épuisés, le noyau risque une panique. L'**OOM-Killer** choisit **heuristiquement** un ou plusieurs processus à **tuer (SIGKILL)** pour libérer de la mémoire et sauver le système.

**Pourquoi c'est important**  
Sur un nœud HPC le **Swap est proscrit** (prédictibilité et perfs MPI). Les OOM sont donc possibles si un job est mal dimensionné (ex. maillage trop fin). L'heuristique Linux peut choisir de tuer **slurmd** ou **sshd** plutôt que le code utilisateur → nœud déclaré **DOWN**, job perdu, intervention admin.

**Comment ça marche (niveau internals)**  
- Lors d'une allocation qui échoue, la routine **out_of_memory()** est invoquée.  
- Le noyau calcule un **oom_score** par processus (RSS, uptime, **oom_score_adj**).  
- Le processus au **score le plus élevé** reçoit un **SIGKILL** (non interceptable).

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Utiliser les **Cgroups v2** de Slurm (**ConstrainRAMSpace=yes**). Le job est limité (ex. 250 Go sur 256 Go) ; en cas de dépassement, l'OOM-Killer agit **dans le Cgroup** uniquement → seul le job est tué, l'OS et slurmd sont protégés.  
- **Mauvaise** : Désactiver l'overcommit (`vm.overcommit_memory=2`) sur un cluster qui compile beaucoup (Spack/Make) → échecs **malloc** prématurés même avec de la RAM libre.

**Commandes / outils associés**  
- `dmesg -T | grep -i oom` : traces des exécutions de l'OOM-Killer.  
- `sacct -j <jobid>` : statut **OUT_OF_MEMORY** si géré par Slurm/Cgroups.

**Paramètres & tuning**  
- **Systemd** : `OOMScoreAdjust=-1000` sur l'unité de **slurmd** (et éventuellement sshd) pour les rendre quasi intouchables par l'OOM-Killer.

**Troubleshooting rapide**  
- **Symptômes** : « Mon job a crashé sans message dans le .out » ; nœud en **drain** avec « Kill task failed ».  
- **Causes** : Le job a saturé la mémoire ; OOM-Killer déclenché ; Cgroup a fonctionné ou OOM global a frappé, avec processus zombie empêchant le nettoyage.  
- **Actions** : Vérifier `dmesg` (ex. « Killed process 4567 (python) »). Vérifier **Cgroups** et **AllowedRAMSpace** (ex. 98 %) pour préserver le système.

**Renvois croisés**  
Voir aussi : Cgroups, Slurmd, Hugepages, Swap.

**Références**  
Documentation noyau Linux : *oom-killer.*

---

## F

### Fairshare (Partage équitable)

**Définition rigoureuse**  
Algorithme d'**ajustement dynamique de la priorité** des jobs dans la file d'attente, basé sur l'**historique de consommation** des ressources (CPU, GPU-heures) par utilisateur ou par compte (projet/laboratoire), sur une fenêtre temporelle glissante avec **décroissance** (demi-vie), de sorte que les entités ayant **sous-consommé** voient leur priorité augmenter et celles ayant **sur-consommé** la voir diminuer par rapport à une cible (share) prédéfinie.

**Pourquoi c'est important**  
En environnement **multi-tenant**, un ordonnancement purement FIFO ou par priorité fixe permet à un seul laboratoire de monopoliser le cluster. Le Fairshare garantit que chaque groupe reçoit, sur la durée, la **part de ressources** pour laquelle il a contracté (ou payé), tout en permettant des pics temporaires et en « récompensant » les sous-consommateurs.

**Comment ça marche (niveau internals)**  
- Slurm (via **slurmdbd** et la base **Accounting**) enregistre l'usage par utilisateur/compte.  
- La priorité d'un job est une **combinaison pondérée** : Fairshare + Âge du job + QOS + Taille du job.  
- Le composant Fairshare compare la **consommation récente** (avec demi-vie) à la **part cible** (share) ; un ratio &lt; 1 (sous-consommation) élève la priorité, un ratio &gt; 1 la baisse.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Définir des **comptes** (accounts) et des **associations** utilisateur↔compte cohérents avec la gouvernance (projets, labos). Ajuster les **shares** (Fairshare=) pour refléter les engagements.  
- **Mauvaise** : Laisser tous les utilisateurs dans le même compte sans hiérarchie → le Fairshare ne peut pas différencier les groupes.

**Commandes / outils associés**  
- `sshare` : affiche les parts (Fairshare) et l'usage par compte/utilisateur.  
- `sacctmgr show assoc` : hiérarchie comptes/utilisateurs et paramètres (Fairshare, MaxJobs, etc.).

**Paramètres & tuning**  
- `PriorityWeightFairshare` dans slurm.conf : poids du facteur Fairshare dans la priorité globale.  
- `PriorityDecayHalfLife`, `PriorityUsageResetPeriod` : demi-vie et reset de l'historique.

**Troubleshooting rapide**  
- **Symptômes** : un laboratoire se plaint de ne jamais voir ses jobs démarrer alors que le cluster est « à moitié vide ».  
- **Causes** : Sur-consommation passée → priorité Fairshare très basse ; ou ressources demandées (GPU, licence, partition) saturées alors que les CPU semblent libres.  
- **Actions** : Vérifier `sshare` et les limites du compte (MaxJobs, QOS). Expliquer le Fairshare ; éventuellement ajuster les shares ou les QOS.

**Renvois croisés**  
Voir aussi : Backfill, Slurm, Accounting, Chargeback, Partition, QOS.

**Références**  
Documentation Slurm : *Fairshare*, *Priority Multifactor*.

---

### Slurm Fairshare — Implémentation et paramètres

**Définition rigoureuse**  
Dans Slurm, le **Fairshare** est implémenté par le **plugin de priorité** (priority plugin) qui calcule un **score de priorité** pour chaque job en attente en combinant plusieurs facteurs, dont un **composant Fairshare** dérivé de l'**usage enregistré** (slurmdbd, base Accounting) par **utilisateur** et **compte** (association), avec **demi-vie** (decay) et comparaison à une **part cible** (Fairshare=) définie par l'administrateur.

**Pourquoi c'est important**  
Sans configuration explicite (comptes, associations, **PriorityType=priority/multifactor**), Slurm utilise des priorités **FIFO** ou **basic** qui ne reflètent pas l'équité entre projets. L'**implémentation Slurm** du Fairshare permet de **pondérer** la priorité selon l'historique de consommation (CPU, GPU-heures) et d'**ajuster** le comportement via **PriorityWeightFairshare**, **PriorityDecayHalfLife**, et les **shares** par compte, ce qui est indispensable en environnement multi-tenant (laboratoires, projets payants).

**Comment ça marche (niveau internals)**  
- **slurmdbd** enregistre l'usage par **job** (CPU time, etc.) dans la base ; le **slurmctld** interroge ou reçoit des mises à jour pour calculer l'**usage effectif** par association.  
- **Priority plugin** : à chaque cycle de scheduling, pour chaque job en file, calcul du **fairshare component** = f(usage récent avec decay, share cible). Un ratio **usage/share &lt; 1** (sous-consommation) augmente la priorité.  
- **Priorité finale** = combinaison pondérée : **Fairshare + Age + Job size + QOS + …** (voir **PriorityParameters** dans slurm.conf).

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Définir une **hiérarchie de comptes** (sacctmgr) et des **associations** utilisateur↔compte ; attribuer des **Fairshare=** réalistes ; utiliser **PriorityDecayHalfLife** (ex. 7–14 jours) pour que l'historique récent pèse plus ; documenter la politique pour les utilisateurs.  
- **Mauvaise** : Laisser **PriorityType=priority/basic** alors que la gouvernance exige du Fairshare ; ou **Fairshare=0** pour un compte (le rend quasi invisible au Fairshare).

**Commandes / outils associés**  
- **sshare** : affiche les parts (Fairshare) et l'usage par compte/utilisateur.  
- **sprio** : priorité détaillée des jobs en file (composant Fairshare, age, etc.).  
- **sacctmgr show assoc** : hiérarchie et paramètres (Fairshare, MaxJobs, QOS).  
- **scontrol show config** : PriorityType, PriorityWeightFairshare, PriorityDecayHalfLife, PriorityFavorSmall, etc.

**Paramètres & tuning (slurm.conf)**  
- **PriorityType=priority/multifactor** : active le calcul multifactor dont Fairshare.  
- **PriorityWeightFairshare=10000** (ex.) : poids du facteur Fairshare.  
- **PriorityDecayHalfLife=7-0** : demi-vie 7 jours (format jours-heures).  
- **PriorityUsageResetPeriod=monthly** (ou none) : reset périodique de l'usage pour le calcul.  
- **sacctmgr** : **Fairshare=** par association (nombre entier, relatif aux autres comptes).

**Troubleshooting rapide**  
- **Symptômes** : « Mes jobs ne partent jamais » alors que le cluster semble peu chargé ; ou priorité incohérente avec les attentes.  
- **Causes** : Fairshare très bas (sur-consommation passée) ; **slurmdbd** down ou base Accounting non à jour ; **PriorityWeightFairshare=0** (Fairshare désactivé dans le calcul).  
- **Actions** : Vérifier **sshare** et **sprio** ; confirmer que slurmdbd tourne et que les jobs terminés sont bien comptabilisés ; ajuster les shares ou **PriorityDecayHalfLife** si la politique le permet.

**Renvois croisés**  
Voir aussi : Fairshare, Backfill, Slurm, Accounting, slurmdbd, Partition, QOS, sacctmgr.

**Références**  
Slurm : *Priority Multifactor Plugin*, *Fairshare*, *sacctmgr.*

---

## R

### RDMA (Remote Direct Memory Access)

**Définition rigoureuse**  
Technologie permettant à une **carte réseau** (HCA) d'**écrire ou lire directement** dans la **mémoire RAM** d'un autre ordinateur, **sans intervention du processeur** (CPU) ni du noyau du système d'exploitation (OS Bypass), en utilisant le **bus** (PCIe) et le **protocole** adaptés (InfiniBand ou RoCE).

**Pourquoi c'est important**  
En calcul parallèle (MPI), la **latence** et la **bande passante** du réseau déterminent la scalabilité. Avec TCP/IP classique, chaque message traverse le noyau (copies, interruptions, checksums) → latence typique **10–50 µs**. Avec le RDMA, la HCA accède à la RAM distante en **~1–2 µs** et sans charger le CPU, ce qui permet aux applications MPI et aux collectives (NCCL, MPI_Allreduce) d'atteindre le débit physique du réseau.

**Comment ça marche (niveau internals)**  
- La **HCA** expose des **files de travail** (Work Queues) et des **clés d'accès** (Memory Keys) pour des zones mémoire enregistrées (Registered Memory).  
- L'application (ou la librairie MPI/UCX) enregistre un buffer avec le noyau/driver, obtient un **descripteur** (LKey, RKey).  
- L'envoi consiste à poster une **Work Request** (Send, RDMA Write, RDMA Read) qui référence l'adresse locale et l'adresse/distante (RKey). La HCA effectue le transfert en **DMA** sans réveiller le CPU.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Utiliser un **réseau dédié** (InfiniBand ou Ethernet avec RoCE + PFC/ECN) pour le trafic RDMA ; vérifier que le **Subnet Manager** (InfiniBand) ou la config **RoCE** (PFC, ECN) est correcte.  
- **Mauvaise** : Mélanger trafic RDMA et trafic TCP massif sur les mêmes liens sans QoS → congestion et perte de paquets (RoCE est sensible aux pertes).

**Commandes / outils associés**  
- `ibstat`, `ibv_devinfo` : état des ports InfiniBand.  
- `ib_write_bw`, `ib_read_bw` : tests bande passante RDMA point à point.  
- `perftest` (ib_send_bw, etc.) : micro-benchmarks latence et débit.

**Paramètres & tuning**  
- **UCX** : `UCX_NET_DEVICES`, `UCX_TLS=rc,ud` (InfiniBand).  
- **OpenMPI** : `--mca btl openib` ou utilisation d’UCX pour le transport.

**Troubleshooting rapide**  
- **Symptômes** : jobs MPI lents ; latence réseau élevée ; messages d'erreur « connection reset » ou « timeout ».  
- **Causes** : Câble ou port défectueux, Subnet Manager instable, ou RoCE mal configuré (pas de PFC).  
- **Actions** : `ibstat`, `ibdiagnet` ; vérifier les erreurs sur les ports (Symbol Errors, LinkDowned) ; stabiliser le SM ou la config RoCE.

**Renvois croisés**  
Voir aussi : InfiniBand, RoCE, GPUDirect RDMA, MPI, UCX, OS Bypass.

**Références**  
InfiniBand Trade Association. *InfiniBand Architecture Specification.*  
RDMA Aware Networks Programming Guide.

---

### RoCE v2 (RDMA over Converged Ethernet — Version 2)

**Définition rigoureuse**  
Protocole permettant d'effectuer des opérations **RDMA** (Remote Direct Memory Access) sur des **réseaux Ethernet** en utilisant une **pile de transport** (UDP/IP pour RoCE v2, contrairement à RoCE v1 qui utilisait Ethernet seul). La **HCA** (Host Channel Adapter) ou la **NIC** compatible RoCE encapsule les verbes RDMA dans des paquets Ethernet routables, permettant du **RDMA sans InfiniBand** dans des datacenters Ethernet.

**Pourquoi c'est important**  
Beaucoup de sites n'ont pas d'**InfiniBand** (coût, compétences) mais disposent d'Ethernet 25/100 GbE. **RoCE v2** permet d'obtenir une **latence proche de l'IB** (quelques µs) et une bande passante élevée sur Ethernet, à condition que le réseau soit **sans perte** (PFC — Priority Flow Control) et éventuellement avec **ECN** (Explicit Congestion Notification) pour éviter les drops qui dégradent fortement le débit RDMA.

**Comment ça marche (niveau internals)**  
- **RoCE v2** : trafic RDMA en **UDP** (ports de destination dédiés), avec **routage IP** possible (L3). La NIC expose les **verbs** RDMA (Send, Write, Read) et gère le transport en matériel.  
- **PFC** : pause frames sur les priorités utilisées par RoCE pour éviter les pertes de paquets en cas de congestion.  
- **DCQCN** (Data Center Quantized Congestion Notification) : variante avec ECN pour limiter le débit des flux en congestion au lieu de tout bloquer.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Activer **PFC** sur les classes de trafic RoCE ; isoler le trafic RDMA (VLAN, QoS) ; utiliser des switchs **low-latency** et une topologie **non bloquante** (Spine-Leaf).  
- **Mauvaise** : RoCE sur un réseau partagé sans PFC → pertes → retransmissions et effondrement du débit ; mélanger RoCE et TCP massif sans priorité.

**Commandes / outils associés**  
- `rdma link` : état des devices RDMA (RoCE).  
- `ibv_devinfo`, `perftest` (ib_write_bw, etc.) : vérifier que la NIC est en mode RoCE et tester latence/débit.  
- Configuration switch : PFC, ECN, DSCP pour les priorités RoCE.

**Paramètres & tuning**  
- **Kernel** : `rdma_cm`, modules RoCE (mlx5 avec RoCE).  
- **UCX** : `UCX_TLS=rc,ud` (si RoCE supporté), `UCX_NET_DEVICES` pour sélectionner l'interface.  
- Réseau : **MTU** (jumbo si cohérent partout), **PFC** sur la même priorité que les paquets RoCE.

**Troubleshooting rapide**  
- **Symptômes** : Latence élevée, débit faible, erreurs « connection reset » ou timeouts MPI.  
- **Causes** : PFC désactivé ou mal configuré ; pertes de paquets ; MTU incohérent ; driver ou firmware NIC obsolète.  
- **Actions** : Vérifier PFC/ECN sur les switchs ; `perftest` entre deux nœuds ; `ethtool -S` pour les drops ; mettre à jour firmware/driver.

**Renvois croisés**  
Voir aussi : RDMA, InfiniBand, GPUDirect RDMA, MPI, UCX, PFC, Spine-Leaf.

**Références**  
IBTA. *Supplement to InfiniBand Architecture — RoCE.* — IEEE 802.1Qbb (PFC).

---

## S

### Striping (Lustre) — Entrelacement d'objets

**Définition rigoureuse**  
Mécanisme fondamental de Lustre (et d'autres FS parallèles) consistant à **diviser logiquement** un fichier unique en segments de taille fixe (**chunks**) et à **distribuer** ces segments en **round-robin** sur plusieurs cibles de stockage physiques distinctes (**OST** — Object Storage Targets).

**Pourquoi c'est important**  
Un seul disque ou SSD a une bande passante physique limitée (ex. 200 Mo/s HDD, 3 Go/s NVMe). En HPC, un job MPI peut devoir écrire un fichier de checkpoint à **100 Go/s**. Le striping permet d'**agréger** la bande passante de dizaines ou centaines d'OST pour **un seul et même fichier**.  
*Image mentale : un fichier coupé en tranches — tranche 1 → serveur A, tranche 2 → B, tranche 3 → C, etc.*

**Comment ça marche (niveau internals)**  
- Lustre maintient cette information dans l'**EA** (Extended Attribute) du fichier sur le serveur de métadonnées (**MDT**), via le composant **LOV** (Logical Object Volume).  
- Quand un client ouvre le fichier, le MDS lui fournit la **« carte »** des objets. Si le **stripe_size** est 1 Mo, pour lire l'octet 1 048 577 (début du 2ᵉ mégaoctet), le client envoie une requête **RDMA directement à l'OST n°2** sans reconsulter le MDS → **OS-bypass** massif.

**Bonnes pratiques / Mauvaises pratiques**  
- **Bonne** : Adapter le **Stripe Count** à la taille finale estimée du fichier (règle empirique : ~1 OST par tranche de 100 Go). Utiliser **lfs setstripe** sur un **dossier** avant la création des fichiers, car le striping **ne peut pas être modifié** une fois le fichier créé (sans recopie complète).  
- **Mauvaise** : Appliquer un **Stripe Count maximal** (-c -1, « tous les OST du cluster ») sur un dossier contenant des **millions de fichiers de quelques Ko** → surcharge du MDS (allocation de millions d'objets vides) et **fragmentation** de l'espace libre des OST.

**Commandes / outils associés**  
- `lfs getstripe /chemin/fichier` : affiche l'index des OST hébergeant physiquement le fichier.  
- `lfs setstripe -c <count> -S <size> /chemin/dossier` : configure l'**héritage** d'entrelacement pour les fichiers créés dans ce dossier.  
- `lfs df -h` : voir l'utilisation par OST (détection **OST Imbalance**).  
- **lfs_migrate** : déplacer des fichiers d'un OST vers d'autres (rééquilibrage).

**Paramètres & tuning**  
- **stripe_size** : taille du segment (défaut souvent 1 Mo). L'augmenter à **4 Mo** ou **16 Mo** pour les écritures **massivement séquentielles** en très gros blocs.

**Troubleshooting rapide**  
- **Symptômes** : Erreur **ENOSPC** (No space left on device) alors que `df -h` montre qu'il reste beaucoup d'espace libre sur le FS global.  
- **Causes** : **Déséquilibre des OST** (OST Imbalance). Si beaucoup de fichiers ont été créés avec un stripe de 1 (un seul OST), certains OST peuvent être **pleins à 100 %** alors que d'autres sont vides ; un OST plein empêche toute écriture le ciblant.  
- **Actions** : Utiliser **lfs df -h** pour repérer l'OST plein à 100 %. **Rééquilibrer** avec **lfs_migrate** pour déplacer des fichiers depuis l'OST plein vers des OST moins chargés.

**Renvois croisés**  
Voir aussi : MDT/OST, LOV, EA, IOR, MPI-IO, DLM, Lustre, LNet.

**Références**  
Braam, P. J. (2019). *Lustre File System: Architecture and Internals.* — Lustre Operations Manual. *Striping.*

---

## Index des entrées (extrait fondamental)

| Lettre | Entrée | Thème |
|--------|--------|--------|
| B | Backfill Scheduling | Ordonnancement Slurm |
| B | BeeGFS | Stockage parallèle |
| B | Burst Buffers | Stockage, I/O |
| C | Cgroups v2 (HPC) | Linux / SRE, Isolation |
| D | DLM (Lustre) & Cohérence POSIX | Stockage parallèle |
| F | Fairshare | Ordonnancement Slurm |
| F | Slurm Fairshare | Ordonnancement Slurm |
| G | GPUDirect RDMA | Réseau, GPU, IA |
| G | GPU Tensor Cores | GPU, IA |
| H | Hugepages & TLB | Linux / SRE, Mémoire |
| M | MPI Collectives (AllReduce) | MPI, Réseau |
| N | NUMA & Pinning | Architecture, Mémoire |
| N | NVLink | GPU, Interconnexion |
| O | OOM-Killer | Linux / SRE, Mémoire |
| R | RDMA | Réseau, Latence |
| R | RoCE v2 | Réseau, Ethernet RDMA |
| S | Striping (Lustre) | Stockage parallèle |

**Extension du dictionnaire**  
Chaque nouvelle entrée doit respecter la structure en 9 sections ci-dessus. Entrées déjà présentes (B à S) : Backfill, BeeGFS, Burst Buffers, Cgroups v2, DLM, Fairshare, Slurm Fairshare, GPUDirect RDMA, GPU Tensor Cores, Hugepages, MPI Collectives (AllReduce), NUMA, NVLink, OOM-Killer, RDMA, RoCE v2, Striping. Entrées prévues (à rédiger au même format) : Affinity, Apptainer, Co-design, DNE, Eager Protocol, Fat-Tree, HPL, InfiniBand, LNet, Lustre, MPI, MUNGE, NCCL, Root Squash, Slurm, Spine-Leaf, Walltime, Warewulf, etc. Voir aussi le [Glossaire et Acronymes](Glossaire-et-Acronymes) pour les définitions courtes et le [Sommaire du Manuel HPC](Manuel-HPC-Sommaire-Complet) pour les chapitres détaillés.

---

## Liens utiles

- **[Glossaire et Acronymes](Glossaire-et-Acronymes)** : définitions courtes et liste d’acronymes
- **[Sommaire du Manuel HPC](Manuel-HPC-Sommaire-Complet)** : 8 volumes, chapitres et labs
- **[Guide SLURM Complet](Guide-SLURM-Complet)** : commandes et configuration Slurm
- **[Home](Home)** : page d’accueil du wiki

---

**Dictionnaire encyclopédique HPC — Extrait fondamental**  
**Niveau** : Doctorat / Architecte — **Dernière mise à jour** : 2024
