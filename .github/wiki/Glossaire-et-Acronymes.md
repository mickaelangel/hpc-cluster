# 📖 Glossaire et dictionnaire des acronymes HPC

> **Référence Master Data Science / Doctorat & DevOps Senior**

---

## Comment utiliser ce glossaire

- **Acronymes** : tri alphabétique, avec expansion et courte définition (tableaux par lettre).
- **Termes** : notions importantes du domaine HPC, clusters, stockage, réseau, logiciels.
- **Glossaire technique détaillé (A→Z)** : en bas de page, définitions longues avec exemples et termes liés pour les notions les plus critiques (architecture, Slurm, Lustre, IA, réseaux).
- **Dictionnaire encyclopédique HPC** : entrées encyclopédiques complètes (définition rigoureuse, internals, bonnes/mauvaises pratiques, commandes, tuning, troubleshooting, références) — voir [Dictionnaire-Encyclopedique-HPC](Dictionnaire-Encyclopedique-HPC).

---

## A

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **ACL** | Access Control List — liste de contrôle d’accès (fichiers, réseaux). |
| **API** | Application Programming Interface — interface de programmation. |
| **AWX** | Projet open source fournissant une interface web et API pour Ansible (Automation Controller). |
| **ANSSI** | Agence nationale de la sécurité des systèmes d’information (référentiels sécurité France). |
| **Apptainer** | Nouveau nom du projet Singularity (conteneurs HPC). |
| **AVX** | Advanced Vector Extensions — jeux d’instructions SIMD x86 (AVX, AVX2, AVX-512). |

---

## B

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **BeeGFS** | Système de fichiers parallèle (ex-Parallel Virtual File System, puis Fraunhofer). Très utilisé en HPC. |
| **BLAS** | Basic Linear Algebra Subprograms — bibliothèque standard d’algèbre linéaire (performance CPU). |
| **Burst buffer** | Couche de stockage tampon (souvent SSD/NVMe) entre calcul et stockage parallèle pour absorber les pics I/O. |

---

## C

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Ceph** | Système de stockage distribué (objet, bloc, fichier) open source. |
| **CI/CD** | Continuous Integration / Continuous Delivery (or Deployment) — intégration et déploiement continus. |
| **CIS** | Center for Internet Security — benchmarks de durcissement (ex. CIS Level 2). |
| **Cloud** | Informatique en nuage (IaaS, PaaS, SaaS) ; parfois utilisé pour offres HPC (cloud HPC). |
| **CPU** | Central Processing Unit — processeur. |
| **CUDA** | Compute Unified Device Architecture — plateforme NVIDIA pour calcul sur GPU. |
| **cgroups** | Control groups — mécanisme Linux pour limiter et mesurer l’usage des ressources (CPU, mémoire, I/O). |

---

## D

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Daemon** | Programme qui tourne en arrière-plan (ex. slurmd, slurmctld). |
| **Data parallelism** | Parallélisme par les données (même code, données différentes). |
| **DISCO** | Terme parfois utilisé pour stockage ou données distribuées (selon contexte). |
| **DISA STIG** | Defense Information Systems Agency Security Technical Implementation Guide — durcissement sécurité (US). |
| **DNS** | Domain Name System — résolution noms de domaine. |
| **DPU** | Data Processing Unit — processeur dédié au réseau/stockage (ex. NVIDIA BlueField). |
| **DRAM** | Dynamic Random Access Memory — mémoire vive classique. |

---

## E

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Efficacité** | En parallélisme : E(n) = Speedup(n) / n. Mesure l’utilisation des cœurs. |
| **Ethernet** | Technologie réseau (1G, 10G, 25G, 100G) ; souvent utilisée pour interconnexion HPC (avec ou sans RoCE). |
| **Exascale** | Ordre de grandeur : 10^18 opérations/s (1 exaflops). |
| **Exporters** | Programmes qui exposent des métriques pour Prometheus (ex. node_exporter, slurm_exporter). |

---

## F

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Fair-share** | Politique d’ordonnancement qui favorise les utilisateurs/projets qui ont moins consommé récemment. |
| **FLOPS** | Floating Point Operations Per Second — opérations en virgule flottante par seconde (K/M/G/T/P FLOPS). |
| **FreeIPA** | Suite d’authentification (LDAP, Kerberos, DNS, certificats) pour environnements Linux. |
| **Frontal** | Nœud d’accès utilisateur (login, soumission de jobs), par opposition aux nœuds de calcul. |
| **FS** | File System — système de fichiers. |

---

## G

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **GFLOPS** | Giga FLOPS — 10^9 opérations/s. |
| **GitOps** | Gestion de l’infrastructure et des déploiements via Git (déclaratif, ex. ArgoCD, Flux). |
| **GlusterFS** | Système de fichiers distribué (scale-out) open source. |
| **GPU** | Graphics Processing Unit — processeur graphique, utilisé pour calcul (CUDA, ROCm, etc.). |
| **Grafana** | Outil de visualisation de métriques et de logs (dashboards). |
| **GRES** | Generic Resource — ressource générique dans Slurm (ex. GPU, licences). |

---

## H

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **HA** | High Availability — haute disponibilité. |
| **HDF5** | Hierarchical Data Format version 5 — format et bibliothèques pour données scientifiques (I/O parallèle possible). |
| **HPC** | High Performance Computing — calcul haute performance. |
| **HTC** | High Throughput Computing — grand nombre de tâches indépendantes (vs. gros jobs parallèles). |

---

## I

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **IaaS** | Infrastructure as a Service. |
| **IaC** | Infrastructure as Code — infrastructure définie en code (Terraform, Ansible, etc.). |
| **IAM** | Identity and Access Management — gestion des identités et des accès. |
| **IB** | InfiniBand — réseau à haute performance (faible latence, haut débit). |
| **InfluxDB** | Base de données temporelle (time-series) pour métriques et événements. |
| **IOPS** | Input/Output Operations Per Second — opérations d’I/O par seconde. |
| **I/O** | Input/Output — entrées/sorties (disque, réseau). |

---

## J

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **JupyterHub** | Serveur multi-utilisateurs pour Jupyter (notebooks). |
| **Job** | Unité de travail soumise au scheduler (ex. un script sbatch, une session srun). |
| **JWT** | JSON Web Token — jeton d’authentification. |

---

## K

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Kerberos** | Protocole d’authentification réseau (tickets, SSO). |
| **Kubernetes (K8s)** | Orchestrateur de conteneurs (pods, services, déploiements). |

---

## L

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **LAN** | Local Area Network. |
| **LDAP** | Lightweight Directory Access Protocol — annuaire (utilisateurs, groupes). |
| **Lustre** | Système de fichiers parallèle très répandu en HPC (metadata servers + object storage servers). |
| **LSF** | Load Sharing Facility — scheduler commercial (IBM). |
| **Loki** | Système de stockage et requêtes de logs (intégré à Grafana). |

---

## M

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **MDS** | Metadata Server — serveur de métadonnées (Lustre). |
| **MFA** | Multi-Factor Authentication — authentification multi-facteurs. |
| **MPI** | Message Passing Interface — standard de programmation parallèle à mémoire distribuée (multi-nœuds). |
| **MPICH** | Implémentation open source de MPI. |
| **MVAPICH** | Implémentation MPI optimisée pour InfiniBand. |

---

## N

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **NAS** | Network Attached Storage — stockage en réseau. |
| **NetCDF** | Network Common Data Form — format et API pour données scientifiques (I/O parallèle possible). |
| **NFS** | Network File System — système de fichiers réseau (partage de répertoires). |
| **NVMe** | Non-Volatile Memory Express — interface pour SSD rapides. |

---

## O

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **OOM** | Out Of Memory — manque de mémoire (processus tué par le noyau). |
| **OpenMP** | API de parallélisme à mémoire partagée (threads sur un nœud). |
| **OpenMPI** | Implémentation open source de MPI. |
| **OSS** | Object Storage Server — serveur de stockage d’objets (Lustre). |

---

## P

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **PaaS** | Platform as a Service. |
| **PBS** | Portable Batch System — famille de schedulers (PBS Pro, OpenPBS). |
| **PDU** | Power Distribution Unit — unité de distribution électrique (racks). |
| **PFLOPS** | Peta FLOPS — 10^15 opérations/s. |
| **Prometheus** | Système de collecte et de requêtes de métriques (PromQL). |
| **PromQL** | Langage de requête des métriques Prometheus. |
| **PV** | Persistent Volume — volume persistant (Kubernetes). |
| **PXE** | Preboot eXecution Environment — démarrage réseau. |

---

## Q

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **QoS** | Quality of Service — dans Slurm : ensemble de limites (temps, nœuds, etc.) et priorités associées à un type de job. |
| **Quota** | Limite d’usage (CPU-heures, espace disque, nombre de jobs). |

---

## R

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **RBAC** | Role-Based Access Control — contrôle d’accès par rôles. |
| **RDMA** | Remote Direct Memory Access — accès mémoire distant (sans CPU), utilisé en InfiniBand et RoCE. |
| **RoCE** | RDMA over Converged Ethernet — RDMA sur Ethernet. |
| **ROCm** | Plateforme AMD pour calcul sur GPU. |
| **RPC** | Remote Procedure Call — appel de procédure à distance. |

---

## S

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **SaaS** | Software as a Service. |
| **Scheduler** | Ordonnanceur de jobs (Slurm, PBS, LSF, etc.). |
| **SIMD** | Single Instruction Multiple Data — une instruction, plusieurs données (vectorisation). |
| **Singularity** | Conteneurs pour HPC (projet renommé Apptainer). |
| **Slurm** | Simple Linux Utility for Resource Management — scheduler et gestionnaire de ressources. |
| **slurmctld** | Démon contrôleur Slurm. |
| **slurmd** | Démon Slurm sur chaque nœud de calcul. |
| **slurmdbd** | Démon base de données Slurm (comptabilité, multi-cluster). |
| **Speedup** | S(n) = T(1)/T(n) — accélération obtenue avec n processeurs. |
| **SSD** | Solid State Drive — disque à semi-conducteurs. |
| **SSH** | Secure Shell — accès à distance sécurisé. |
| **SSL/TLS** | Protocoles de sécurisation des communications. |

---

## T

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **TFLOPS** | Tera FLOPS — 10^12 opérations/s. |
| **TLB** | Translation Lookaside Buffer — cache matériel pour la traduction d’adresses virtuelles en physiques. |
| **TOTP** | Time-based One-Time Password — mot de passe à usage unique (ex. Google Authenticator). |
| **Torque** | Scheduler dérivé de PBS (open source). |

---

## U

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **UCX** | Unified Communication X — couche de communication unifiée pour MPI et RPC (support InfiniBand, RoCE, GPU). |
| **UID** | User Identifier — identifiant numérique d’un utilisateur (Linux). |

---

## V

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **VRAM** | Video RAM — mémoire dédiée au GPU. |
| **VPN** | Virtual Private Network. |

---

## W

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Walltime** | Temps réel (horloge) alloué à un job (vs. temps CPU). |
| **Workload** | Charge de travail — ensemble des jobs ou tâches à exécuter. |

---

## X

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **x86** | Architecture processeur (Intel, AMD). |
| **x86_64** | Architecture 64 bits (AMD64 / Intel 64). |

---

## Z

| Acronyme / Terme | Expansion / Définition |
|------------------|------------------------|
| **Zero Trust** | Modèle de sécurité où rien n’est considéré comme fiable par défaut (vérification continue). |

---

## Termes métier (définitions courtes)

| Terme | Définition |
|-------|------------|
| **Allocation** | Ensemble de ressources (nœuds, CPU, mémoire, GPU) attribuées à un job par le scheduler. |
| **Cluster** | Ensemble de nœuds (frontaux + calcul + éventuellement stockage) gérés comme une ressource commune. |
| **Compute node** | Nœud dédié à l’exécution des jobs (pas de login utilisateur direct en général). |
| **Interconnect** | Réseau reliant les nœuds de calcul (InfiniBand, Ethernet, RoCE). |
| **Login node** | Nœud frontal pour connexion SSH et soumission de jobs. |
| **Metadata** | Données décrivant les fichiers (nom, taille, permissions) — séparées des données en Lustre/BeeGFS. |
| **Partition** | Dans Slurm : file d’attente associée à un ensemble de nœuds et des règles (temps max, etc.). |
| **Step** | Sous-partie d’un job Slurm (ex. un appel à srun dans un script). |
| **Supercomputer** | Très gros système HPC (souvent classé Top500). |
| **Throughput** | Débit — volume de travail ou de données traité par unité de temps. |

---

## Glossaire technique détaillé (A→Z)

Définitions longues avec exemples et termes liés pour les notions les plus critiques (architecture, Slurm, Lustre, IA, réseaux).

---

### A

**Affinity (Affinité)**  
- **Courte** : Fait de forcer l’exécution d’un processus ou l’allocation de la mémoire sur un composant matériel spécifique (cœur CPU ou nœud NUMA).  
- **Longue** : En architectures multi-sockets ou multi-chiplets, l’OS déplace les processus pour équilibrer la charge ; en HPC cela détruit la localité du cache (cache misses). L’affinité (pinning / binding) verrouille le processus MPI sur un cœur pour des perfs maximales et prédictibles.  
- **Exemple** : `numactl --physcpubind=0-7` ou l’option Slurm `--bind-to core`.  
- **Termes liés** : NUMA, Cgroups, Slurm GRES, First Touch.

**Apptainer (ex-Singularity)**  
- **Courte** : Moteur de conteneurs conçu pour le calcul intensif (HPC).  
- **Longue** : Pas de démon root comme Docker ; l’utilisateur garde son UID/GID dans le conteneur. Monte nativement les FS parallèles (Lustre) et lie les pilotes GPU (`--nv`) dans un fichier image unique (.sif).  
- **Exemple** : `apptainer exec --nv mon_image.sif python script.py`  
- **Termes liés** : Docker, OCI, SIF, environnements utilisateurs.

---

### B

**Backfill (Ordonnancement par remplissage)**  
- **Courte** : Algorithme de Slurm qui lance des petits jobs sur des nœuds inactifs en attendant qu’un grand job démarre.  
- **Longue** : Le scheduler calcule l’heure de démarrage du prochain job prioritaire ; si un petit job peut finir avant, il est lancé. Nécessite un **walltime** précis.  
- **Exemple** : Un job de 2 h est lancé sur un nœud qui doit rester libre 3 h pour une grosse simulation.  
- **Termes liés** : Slurm, Walltime, Fairshare, Scheduler.

**BeeGFS**  
- **Courte** : Système de fichiers parallèle open-source (ThinkParQ), alternative à Lustre pour le HPC.  
- **Longue** : Sépare métadonnées (MDS) et stockage (storage targets) ; client en espace utilisateur ou noyau, protocole propriétaire sur TCP ou RDMA. Pas de DLM centralisé comme Lustre ; déploiement plus simple, scaling horizontal.  
- **Exemple** : `beegfs-ctl`, `beegfs-df` pour le diagnostic.  
- **Termes liés** : Lustre, Striping, POSIX, MPI-IO.

**Burst Buffer**  
- **Courte** : Couche de stockage intermédiaire ultra-rapide (souvent NVMe) entre les nœuds de calcul et le FS parallèle (Lustre/GPFS).  
- **Longue** : Absorbe les pics d’écritures synchrones (ex. checkpointing MPI). Les données sont écrites très vite sur le burst buffer puis drainées vers le stockage capacitif en arrière-plan.  
- **Exemple** : Cray DataWarp, allocations NVMe locales via Slurm.  
- **Termes liés** : Checkpoint/Restart, Lustre OST, Tiering.

---

### C

**Cgroups (Control Groups) / Cgroups v2**  
- **Courte** : Mécanisme du noyau Linux pour limiter, isoler et mesurer l’usage des ressources (CPU, RAM, I/O) par un groupe de processus.  
- **Longue** : En HPC, Slurm utilise les **Cgroups v2** (task/cgroup) : un cgroup par job avec limite mémoire (ConstrainRAMSpace, AllowedRAMSpace). Si le job dépasse, l’OOM-Killer n’agit que dans ce cgroup → seul le job est tué, pas slurmd.  
- **Exemple** : `ConstrainRAMSpace=yes`, `AllowedRAMSpace=98` dans cgroup.conf.  
- **Termes liés** : Namespaces, Slurm, OOM-Killer, Multi-tenancy.

**Co-design**  
- **Courte** : Conception conjointe et itérative du matériel et du logiciel pour maximiser les performances.  
- **Longue** : On ne choisit pas des serveurs au hasard : on analyse le profil du code (memory-bound, compute-bound, I/O-bound) pour dimensionner réseau, CPU/GPU et stockage et éliminer le goulot.  
- **Exemple** : Choisir des processeurs avec HBM pour un code de dynamique des fluides (memory-bound).  
- **Termes liés** : Roofline Model, Profiling, Benchmarking.

---

### D

**DLM (Distributed Lock Manager)**  
- **Courte** : Sous-système Lustre (LDLM) qui garantit la cohérence POSIX des données et métadonnées entre clients concurrents.  
- **Longue** : Gère les verrous d’étendue (extent locks) : un client qui écrit reçoit un verrou exclusif ; un autre qui lit déclenche une AST pour flush et rétrogradation. Le trafic de verrous (lock traffic) peut dégrader les perfs si les applications font du false sharing.  
- **Exemple** : `lctl get_param ldlm.namespaces.*.lock_count` pour le nombre de verrous actifs.  
- **Termes liés** : Lustre, POSIX, Striping, MPI-IO, False Sharing.

**DNE (Distributed Namespace)**  
- **Courte** : Fonctionnalité Lustre qui répartit la charge des métadonnées sur plusieurs MDT.  
- **Longue** : Un seul MDT créait un goulot (millions de fichiers). DNE permet d’affecter des répertoires (Phase 1) ou des fichiers d’un même répertoire (Phase 2) à plusieurs MDTs pour scaler les métadonnées.  
- **Exemple** : `/scratch/projetA` sur MDT0, `/scratch/projetB` sur MDT1.  
- **Termes liés** : Lustre, MDS/MDT, Métadonnées, IOPS.

---

### E

**Eager Protocol**  
- **Courte** : Protocole MPI pour l’envoi de **petits** messages.  
- **Longue** : L’expéditeur envoie directement la donnée en supposant des buffers de réception pré-alloués ; pas de handshake, donc très faible latence, mais inadapté aux gros transferts (saturation RAM).  
- **Exemple** : Un `MPI_Send` de 10 Ko utilise typiquement Eager.  
- **Termes liés** : Rendezvous Protocol, MPI, Latence, RDMA.

---

### F

**Fairshare**  
- **Courte** : Algorithme qui répartit équitablement le temps de calcul entre utilisateurs sur une période.  
- **Longue** : Ajuste la priorité des jobs : si un labo a consommé plus que sa part, la priorité de ses prochains jobs baisse au profit des sous-consommateurs. L’historique s’estompe (demi-vie).  
- **Exemple** : `PriorityWeightFairshare=100000` dans Slurm donne un poids fort à l’équité.  
- **Termes liés** : Slurm, Priority, Accounting, Chargeback.

**Fat-Tree (Topologie de Clos)**  
- **Courte** : Architecture réseau où tous les nœuds ont la même bande passante pour communiquer.  
- **Longue** : En remontant vers le core, les liens sont multipliés (Spine-Leaf). Un Fat-Tree non-blocking (1:1) garantit qu’aucun lien ne sature quand la moitié du cluster parle à l’autre.  
- **Exemple** : Chaque nœud à 200 Gbps sur le Leaf, assez de liens montants vers les Spines pour écouler tout le trafic.  
- **Termes liés** : Spine-Leaf, InfiniBand, Oversubscription.

---

### G

**GPUDirect RDMA**  
- **Courte** : Technologie NVIDIA permettant à une carte réseau de lire/écrire **directement** dans la VRAM d’un GPU.  
- **Longue** : Sans cela, GPU→RAM CPU→carte réseau→réseau→… ; avec GPUDirect, la carte réseau accède à la VRAM via PCIe, sans CPU, divisant la latence et libérant le processeur.  
- **Exemple** : Indispensable pour l’entraînement distribué de LLM via NCCL.  
- **Termes liés** : RDMA, NCCL, PCIe, VRAM, OS Bypass.

**GPU Tensor Cores**  
- **Courte** : Unités de calcul matriciel (GEMM) dans les GPU NVIDIA (Volta et suivants), optimisées FP16/BF16/INT8.  
- **Longue** : Accélèrent massivement les multiplications matricielles des réseaux de neurones (convolutions, attention). Un nœud avec Tensor Cores atteint des TFLOP/s bien supérieurs aux cœurs CUDA classiques pour ces opérations.  
- **Exemple** : PyTorch avec `torch.autocast` ou TF32 sur Ampere.  
- **Termes liés** : CUDA, cuBLAS, cuDNN, NVLink, Mixed Precision.

---

### H

**HPL (High Performance Linpack)**  
- **Courte** : Benchmark standard du classement **Top500**.  
- **Longue** : Résout un grand système linéaire dense ; très compute-bound, stresse les FPU et la consommation. Critiqué car il ne reflète pas les accès mémoire irréguliers de la science actuelle.  
- **Exemple** : Frontier a atteint 1,194 ExaFLOPS sur HPL.  
- **Termes liés** : HPCG, FLOPS, Top500, Benchmarking.

**Hugepages / TLB**  
- **Courte** : Pages mémoire de 2 Mo ou 1 Go (vs 4 Ko standard) pour réduire les TLB misses et accélérer la traduction d’adresses.  
- **Longue** : Un code avec 128 Go de RAM = 33 M de pages 4 Ko → le TLB (cache d’adresses) sature. Avec des Hugepages 1 Go, 128 entrées suffisent. En HPC : activer les Hugepages explicites pour RDMA (memory registration) ; désactiver les Transparent Hugepages (THP) sur les nœuds de calcul (jitter).  
- **Exemple** : `cat /proc/meminfo | grep Huge` ; GRUB `hugepagesz=1G hugepages=64`.  
- **Termes liés** : NUMA, RDMA, OOM-Killer, perf.

---

### I

**InfiniBand (IB)**  
- **Courte** : Réseau à très haut débit et très faible latence, dominant en HPC.  
- **Longue** : Conçu pour le calcul parallèle : RDMA natif, fabric lossless, Subnet Manager pour les routes optimales (pas de BGP/OSPF).  
- **Exemple** : Générations FDR (56G), EDR (100G), HDR (200G), NDR (400G), XDR (800G).  
- **Termes liés** : RoCE, Subnet Manager, RDMA, HCA.

---

### L

**LNet (Lustre Network)**  
- **Courte** : Couche d’abstraction réseau de Lustre.  
- **Longue** : Permet à Lustre de tourner sur plusieurs protocoles (TCP/Ethernet, o2ib/InfiniBand) et gère le routage (LNet Routers), ex. clients 10G vers stockage IB 200G.  
- **Exemple** : `10.0.0.5@tcp` ou `192.168.1.10@o2ib`.  
- **Termes liés** : Lustre, RDMA, OS Bypass.

**Lustre**  
- **Courte** : Système de fichiers parallèle open-source le plus utilisé dans les supercalculateurs.  
- **Longue** : Sépare les métadonnées (MDS) des données (OSS). En strippant les fichiers sur de nombreux serveurs, il permet des écritures simultanées à des débits dépassant le To/s.  
- **Exemple** : Espace `/scratch` temporaire d’un cluster.  
- **Termes liés** : MDS/MDT, OSS/OST, MGS, Striping, POSIX.

---

### M

**MPI (Message Passing Interface)**  
- **Courte** : Standard de programmation pour la communication entre processus en environnement parallèle distribué.  
- **Longue** : Les processus sur des milliers de nœuds n’ont pas la même RAM ; ils s’envoient des messages via le réseau. MPI définit les appels (point-à-point : MPI_Send ; collectifs : MPI_Allreduce).  
- **Exemple** : OpenMPI, MPICH, MVAPICH2.  
- **Termes liés** : OpenMP, RDMA, Eager, Rendezvous, Rank.

**MPI Collectives / AllReduce**  
- **Courte** : Opérations de groupe où tous les rangs participent (réduction + diffusion du résultat).  
- **Longue** : MPI_Allreduce combine les données locales (somme, max, etc.) et renvoie le résultat à tous. En deep learning, la synchro des gradients utilise des AllReduce (NCCL ou MPI). Algorithmes typiques : ring, recursive halving ; la bande passante réseau et le choix d’algorithme déterminent la scalabilité.  
- **Exemple** : OSU Micro-Benchmarks `osu_allreduce` ; PyTorch DDP avec NCCL.  
- **Termes liés** : MPI, NCCL, RDMA, Ring AllReduce.

**MUNGE (MUNGE Uid 'N' Gid Emporium)**  
- **Courte** : Service d’authentification pour sécuriser les communications intra-cluster.  
- **Longue** : Chiffre et signe les identités (UID/GID) sans mot de passe. Slurm l’utilise. Tous les nœuds doivent avoir la même clé (munge.key) et être synchronisés (NTP).  
- **Exemple** : L’erreur « Munge decode failed » indique souvent une désynchronisation d’horloge (> 5 min).  
- **Termes liés** : Slurm, NTP, Sécurité intra-nœud.

---

### N

**NCCL (NVIDIA Collective Communication Library)**  
- **Courte** : Bibliothèque optimisée pour les communications multi-GPU et multi-nœuds.  
- **Longue** : Équivalent de MPI pour les topologies GPU (NVLink, PCIe, GPUDirect RDMA). Détecte la topologie pour créer anneaux ou arbres de transfert optimaux (entraînement distribué).  
- **Exemple** : PyTorch DDP utilise NCCL par défaut.  
- **Termes liés** : GPUDirect RDMA, MPI, NVLink.

**NUMA (Non-Uniform Memory Access)**  
- **Courte** : Architecture où le temps d’accès à la mémoire dépend de sa position par rapport au processeur.  
- **Longue** : En bi-processeur, chaque CPU a sa RAM locale ; accéder à la RAM de l’autre CPU passe par le bus inter-socket (latence et bande passante dégradées). Le tuning HPC vise à garder calcul et données sur la mémoire locale.  
- **Exemple** : `numactl --hardware` pour voir les distances entre sockets.  
- **Termes liés** : Affinity, Binding, Hugepages.

**NVLink**  
- **Courte** : Interconnexion NVIDIA à haut débit entre GPU (et optionnellement CPU) au sein d’un nœud.  
- **Longue** : Bande passante bien supérieure au PCIe ; permet aux GPU d’échanger tenseurs et gradients sans saturer le bus. NVSwitch (nœuds type DGX) connecte tous les GPU en full bisection.  
- **Exemple** : `nvidia-smi topo -m` pour la matrice de connectivité GPU.  
- **Termes liés** : GPUDirect RDMA, NCCL, Tensor Cores, Multi-GPU.

---

### O

**OOM-Killer (Out-Of-Memory Killer)**  
- **Courte** : Mécanisme du noyau Linux qui tue un processus quand la RAM est saturée.  
- **Longue** : Sans cgroups, un job qui dépasse sa part peut déclencher l’OOM-Killer ; celui-ci peut tuer sshd ou slurmd au lieu du job, rendant le nœud DOWN.  
- **Exemple** : `dmesg` : « Out of memory: Kill process 1234 (python) score 950 or sacrifice child ».  
- **Termes liés** : Cgroups, Slurm, Swap (proscrit en HPC).

---

### R

**RDMA (Remote Direct Memory Access)**  
- **Courte** : Technologie permettant à une carte réseau de lire/écrire directement dans la RAM d’un autre ordinateur sans solliciter l’OS ni le CPU.  
- **Longue** : Clé de la faible latence (~1 µs). Contourne le noyau (OS Bypass) et la pile TCP/IP, supprimant copies de buffers et interruptions.  
- **Exemple** : InfiniBand et RoCE v2 sont basés sur RDMA.  
- **Termes liés** : InfiniBand, RoCE, GPUDirect RDMA, OS Bypass.

**RoCE v2 (RDMA over Converged Ethernet)**  
- **Courte** : RDMA sur Ethernet (UDP/IP), alternative à InfiniBand pour datacenters Ethernet.  
- **Longue** : Permet une latence proche de l’IB sur 25/100 GbE à condition d’activer PFC (Priority Flow Control) et éventuellement ECN pour éviter les pertes. Sensible aux pertes de paquets.  
- **Exemple** : `rdma link` ; UCX avec RoCE.  
- **Termes liés** : RDMA, InfiniBand, PFC, Spine-Leaf.

**Root Squash**  
- **Courte** : Mesure de sécurité sur NFS/Lustre : les requêtes de l’UID 0 (root) sont rétrogradées en « nobody ».  
- **Longue** : Empêche qu’un root local (ex. via faille ou sudo) lise/écrive les fichiers des autres sur le stockage central.  
- **Exemple** : Paramètre d’export NFS `root_squash`.  
- **Termes liés** : NFS, Sécurité, IAM, Multi-tenancy.

---

### S

**Slurm (Simple Linux Utility for Resource Management)**  
- **Courte** : Ordonnanceur (scheduler / workload manager) open-source le plus utilisé en HPC.  
- **Longue** : Gère la file d’attente, l’allocation des ressources (nœuds, CPU, GPU, mémoire) et fournit l’environnement (srun) pour lancer les tâches parallèles de façon synchronisée.  
- **Exemple** : `sbatch` (soumettre), `squeue` (file), `sinfo` (nœuds).  
- **Termes liés** : Backfill, Fairshare, Cgroups, Partition, QOS.

**Spine-Leaf**  
- **Courte** : Architecture réseau datacenter à deux couches optimisant le trafic Est-Ouest.  
- **Longue** : Serveurs sur des switches Leaf (ToR) ; chaque Leaf est relié à tous les Spine. Le chemin entre deux serveurs a toujours le même nombre de sauts → latence constante, vitale pour MPI.  
- **Exemple** : Remplace le modèle Core/Aggregation/Access en cascade.  
- **Termes liés** : Fat-Tree, Oversubscription.

**Stripe / Striping (Entrelacement)**  
- **Courte** : Découper un grand fichier en morceaux répartis sur plusieurs disques ou serveurs.  
- **Longue** : En Lustre, le striping permet à des centaines de processus MPI de lire/écrire un même fichier en parallèle. Fichier sur 4 OSTs → bande passante ×4.  
- **Exemple** : `lfs setstripe -c 8 /scratch/mon_dossier`  
- **Termes liés** : Lustre, OSS/OST, MPI-IO, Bande passante.

---

### W

**Walltime**  
- **Courte** : Temps maximum d’exécution autorisé (et déclaré) pour un job.  
- **Longue** : Si le job dépasse cette limite (temps « mur »), le scheduler le tue (SIGKILL). Indispensable pour que le Backfill soit déterministe.  
- **Exemple** : `#SBATCH --time=24:00:00`  
- **Termes liés** : Slurm, Backfill, Scheduler.

**Warewulf**  
- **Courte** : Outil de provisionnement conçu pour le HPC.  
- **Longue** : Gestion de cluster « stateless » : les nœuds démarrent en PXE et chargent l’OS en RAM (tmpfs) depuis une image. Mise à jour de 1000 nœuds = redémarrage, sans dérive de config.  
- **Exemple** : Warewulf v4 importe des images OCI (type Docker) pour l’OS des nœuds.  
- **Termes liés** : PXE, Stateless, Provisioning.

---

## Liens utiles dans le wiki

- **[Dictionnaire encyclopédique HPC](Dictionnaire-Encyclopedique-HPC)** : 17 entrées (Backfill, BeeGFS, Burst Buffers, Cgroups v2, DLM, Fairshare, Slurm Fairshare, GPUDirect RDMA, GPU Tensor Cores, Hugepages, MPI Collectives, NUMA, NVLink, OOM-Killer, RDMA, RoCE v2, Striping) — format Doctorat/Architecte
- **[Sommaire du Manuel HPC](Manuel-HPC-Sommaire-Complet)** : 8 volumes (architecture, Slurm, Lustre, toolchains, performances, observabilité, fil rouge)
- **[Cours-HPC-Complet](Cours-HPC-Complet)** : cours complet HPC (concepts, architecture, MPI, stockage)
- **[Guide-SLURM-Complet](Guide-SLURM-Complet)** : Slurm en détail (commandes, partitions, QoS)
- **[Home](Home)** : page d’accueil du wiki

---

**Public** : Master Data Science, Doctorat, DevOps Senior  
**Dernière mise à jour** : 2024
