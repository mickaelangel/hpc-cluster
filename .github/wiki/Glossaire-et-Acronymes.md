# 📖 Glossaire et dictionnaire des acronymes HPC

> **Référence Master Data Science / Doctorat & DevOps Senior**

---

## Comment utiliser ce glossaire

- **Acronymes** : tri alphabétique, avec expansion et courte définition.
- **Termes** : notions importantes du domaine HPC, clusters, stockage, réseau, logiciels.

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
| **TOTP** | Time-based One-Time Password — mot de passe à usage unique (ex. Google Authenticator). |
| **Torque** | Scheduler dérivé de PBS (open source). |

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

## Liens utiles dans le wiki

- **[Cours-HPC-Complet](Cours-HPC-Complet)** : cours complet HPC (concepts, architecture, MPI, stockage)
- **[Guide-SLURM-Complet](Guide-SLURM-Complet)** : Slurm en détail (commandes, partitions, QoS)
- **[Home](Home)** : page d’accueil du wiki

---

**Public** : Master Data Science, Doctorat, DevOps Senior  
**Dernière mise à jour** : 2024
