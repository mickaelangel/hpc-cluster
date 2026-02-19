# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 3 : Stockage parallèle et gestion des données (Deep Dive Lustre)**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

Le système de fichiers parallèle est l'un des composants les **plus critiques, complexes et onéreux** d'un supercalculateur. C'est ici que se gagnent ou se perdent les performances d'une application scientifique à grande échelle. Ce volume couvre l'architecture du stockage HPC (POSIX, tiering), les **internals Lustre** (MGS, MDS/MDT, OSS/OST, LNet, DNE), le déploiement et le tuning (striping, `lctl`), puis le panorama des alternatives (BeeGFS, GPFS, CephFS). Un [lab Lustre](#-lab-3--déploiement-dun-mini-lustre-tcp-et-analyse-du-striping) et un [examen de fin de volume](#-examen-de-fin-de-volume-3) permettent de valider les acquis.

**Prérequis :**
- Systèmes de fichiers locaux (ext4, XFS) et réseaux (NFS) — Ch. 8
- Réseaux HPC (InfiniBand, RDMA) — [Volume 2](Manuel-Architecture-HPC-Volume2) — Ch. 9–10
- Administration Linux avancée (block devices, LVM, multipathing) — Ch. 10

---

## Chapitre 8 : Architecture du stockage HPC et sémantique POSIX

### Objectifs d'apprentissage

- Comprendre les **limites de la norme POSIX** dans un environnement massivement distribué
- Concevoir une **hiérarchie de stockage (tiering)** adaptée au cycle de vie des données scientifiques

---

### 8.1 Le goulot d'étranglement POSIX

Le standard **POSIX** (Portable Operating System Interface) a été conçu pour des systèmes **mono-nœuds**. Il impose une **cohérence forte** (strict consistency) : si le nœud A écrit dans un fichier, le nœud B doit voir cette modification **instantanément** s'il lit ce même fichier.

Dans un cluster de **2000 nœuds**, maintenir cette cohérence lors d'écritures concurrentes génère un **trafic massif de verrous** (lock traffic). C'est le défi fondamental des systèmes de fichiers parallèles.

---

### 8.2 Hiérarchisation du stockage (Tiering)

Un cluster HPC performant ne stocke **pas** toutes les données au même endroit. On divise le stockage en **tiers** distincts :

| Tier | Rôle | Caractéristiques |
|------|------|------------------|
| **Scratch (Tier 0/1)** | Espace de travail des jobs en cours | Ultra-rapide (NVMe/SSD), parallèle (Lustre/BeeGFS), **sans sauvegarde**. Purgé automatiquement (ex. fichiers > 30 jours). |
| **Project / Work (Tier 2)** | Datasets actifs d'un projet | Capacitif performant (HDD + cache SSD), **sauvegardé**. |
| **Archive (Tier 3)** | Stockage froid | Bandes LTO, S3, Erasure Coding. Géré par un **HSM** (Hierarchical Storage Management) ou **DLM** (Data Lifecycle Management). |

---

### Piège : « Le syndrome du /home saturé »

Laisser les utilisateurs lancer des calculs produisant des **I/O massifs** dans leur répertoire personnel (souvent NFS). **Symptôme** : le serveur NFS s'effondre, bloquant le login de tous les utilisateurs et figeant des commandes basiques comme `ls`.

---

### Check-list production (Chapitre 8)

- [ ] **Quotas stricts** sur `/home` (capacité **et** inodes)
- [ ] Script de **purge automatique** (Robinhood ou `find`) actif et documenté pour le `/scratch`

---

## Chapitre 9 : Lustre — Les entrailles (Internals)

### Objectifs d'apprentissage

- Cartographier l'**architecture logique et physique** de Lustre
- Comprendre le rôle du réseau **LNet** (Lustre Network)
- Appréhender **DNE** (Distributed Namespace) pour la scalabilité des métadonnées

---

### 9.1 L'architecture Lustre

[Lustre](Glossaire-et-Acronymes#l) (Linux Cluster) **sépare physiquement** les **métadonnées** (noms, permissions, arborescence) des **données** (contenu des fichiers).

| Composant | Rôle |
|-----------|------|
| **MGS** (Management Server) | Registre global, détient la configuration du cluster. Unique (mais HA), peu de ressources. |
| **MDS** (Metadata Server) & **MDT** (Metadata Target) | Serveur + disque (idéalement NVMe) pour l'arborescence. Un client qui fait `ls` ou `open()` parle au MDS. |
| **OSS** (Object Storage Server) & **OST** (Object Storage Target) | Serveurs et disques capacitifs (HDD/SSD) qui stockent les **objets** (morceaux) des fichiers. |
| **Client Lustre** | Module kernel sur les nœuds de calcul ; `mount -t lustre`. |

**Schéma : Flux d'I/O Lustre**

```
 +-----------------+
 | Client (Node 1) |  1. open("/scratch/data.h5")
 +--------+--------+ ---------------------------> +-------+-------+
          |                                       | MDS / MDT 1   |
          |  2. Reçoit la liste des OSTs contenant | (Métadonnées) |
          |     les objets du fichier              +---------------+
          |
          |  3. Lit/Écrit les données directement aux OSS (OS Bypass / RDMA)
          v
 +--------+--------+       +--------+--------+
 | OSS 1 / OST 1,2 |       | OSS 2 / OST 3,4 |
 | (Données Pures) |       | (Données Pures) |
 +-----------------+       +-----------------+
```

---

### 9.2 LNet (Lustre Network)

**LNet** est la couche d'abstraction réseau de Lustre. Elle permet de faire transiter les I/O de manière transparente sur :

- **TCP** (Ethernet)
- **o2ib** (InfiniBand / RDMA)
- **Routage** entre les deux via des nœuds **LNet Routers**

---

### 9.3 DNE (Distributed Namespace)

Historiquement, un Lustre n'avait qu'**un seul MDT** → goulot d'étranglement massif. **DNE** permet de répartir l'arborescence sur **plusieurs MDTs** (ex. `/scratch/projet_A` sur MDT1, `/scratch/projet_B` sur MDT2), ou de distribuer un seul gros dossier sur plusieurs MDTs (DNE phase 2).

---

### Piège : « Le MDT sur disques lents »

Mettre un **MDT sur des HDD**. Les métadonnées sont des I/O **minuscules et hautement aléatoires**. Un HDD saturera à ~200 IOPS, **figeant tout le cluster**. Un MDT doit **toujours** être sur **NVMe/SSD** ou en RAM-cache (Optane).

---

### Check-list production (Chapitre 9)

- [ ] Vérifier que le **MGS** et le **MDS** sont en **haute disponibilité** (Corosync/Pacemaker + disques partagés/multipath)

---

## Chapitre 10 : Déploiement, tuning et opérations Lustre

### Objectifs d'apprentissage

- Déployer et formater des cibles Lustre (**DANGER**)
- Maîtriser le concept vital de **striping** (entrelacement)
- Réaliser du **troubleshooting** de base via `lctl`

---

### 10.1 Le striping (entrelacement)

Un gros fichier peut être **découpé en bandes** (stripes) et réparti sur **plusieurs OSTs**. Lorsqu'un job MPI lit ce fichier avec 1000 processus, il lit **simultanément** sur des dizaines de serveurs → multiplication de la bande passante par N.

**Exemples (côté client) :**

```bash
# Vérifier le striping d'un fichier existant
lfs getstripe /scratch/mon_fichier.dat

# Répertoire : nouveaux fichiers strippés sur 4 OSTs, bandes de 2 MB
lfs setstripe -c 4 -S 2M /scratch/gros_run_mpi/

# Fichier "Wide Stripe" (tous les OSTs) — idéal pour fichier > 1 To
lfs setstripe -c -1 /scratch/massive_checkpoint.out
```

---

### 10.2 Formatage et déploiement (côté serveur)

Lustre s'appuie sur un backend : **ldiskfs** (ext4 modifié) ou **ZFS**.

**Exemple de déploiement d'un OST (ldiskfs) :**

```bash
# DANGER : Détruit toutes les données sur /dev/sdb
mkfs.lustre --reformat --fsname=lustre --ost --mgsnode=10.0.0.5@o2ib /dev/sdb

# Montage de l'OST
mkdir -p /mnt/ost1
mount -t lustre /dev/sdb /mnt/ost1
```

---

### 10.3 Opérations et lctl

**lctl** (Lustre Control) : outil d'administration.

```bash
# État du réseau LNet et interfaces actives
lctl network up
lctl list_nids

# Statistiques de santé (MDS ou OSS)
lctl get_param health_check
```

---

### Piège : « L'over-striping »

Forcer un **stripe count à -1** (tous les OSTs) pour des **millions de petits fichiers** de quelques Ko → trafic de métadonnées et de locks **catastrophique**.

> **Règle d'or** : Petit fichier = **1 OST** (défaut). Gros fichier = **plusieurs OSTs**.

---

### Check-list production (Chapitre 10)

- [ ] Définir des **Project Quotas** (Lustre supporte les quotas POSIX)
- [ ] Toujours **démonter proprement** les clients avant de rebooter un routeur LNet

---

## Chapitre 11 : Panorama des alternatives (BeeGFS, GPFS, CephFS)

### Objectifs d'apprentissage

- Comparer Lustre avec les autres standards du marché HPC
- Identifier l'émergence du **stockage objet** (S3, DAOS) dans le HPC

---

### 11.1 BeeGFS

Alternative **open-source** (ThinkParQ) la plus populaire à Lustre.

| Avantage | Inconvénient |
|----------|--------------|
| Très simple à déployer (services userspace, pas de modules kernel exotiques). Métadonnées **distribuées par défaut**. | Un peu moins performant que Lustre en accès concurrent direct sur un seul très gros fichier partagé (MPI-IO). |

---

### 11.2 GPFS / IBM Spectrum Scale

Système **orienté blocs** (Lustre est orienté objets).

| Avantage | Inconvénient |
|----------|--------------|
| Richesse fonctionnelle (ILM natif, snapshots fiables). Ultra-robuste en environnement « Entreprise ». | Coût des licences, complexité (mmchconfig, mmcrfs). |

---

### 11.3 CephFS

Issu du monde Cloud/OpenStack, en montée en puissance en HPC.

| Avantage | Inconvénient |
|----------|--------------|
| Tolérance aux pannes gérée par **CRUSH** (pas besoin de RAID matériel complexe). | Surcoût CPU/réseau de la réplication → souvent trop lent pour un `/scratch` pur calcul intensif ; **excellent** en `/project`. |

---

## 🧪 Lab 3 : Déploiement d'un mini-Lustre (TCP) et analyse du striping

### Énoncé

Vous avez **3 VMs** (CentOS/Rocky) avec disques additionnels virtuels et le dépôt Lustre activé.

1. **vm-mgs** : Formatez un disque hybride **MGS/MDT**.
2. **vm-oss** : Formatez 2 disques (`/dev/sdb`, `/dev/sdc`) comme **OST0000** et **OST0001**.
3. **vm-client** : Montez le système de fichiers sur `/mnt/lustre`.
4. Créez un dossier `test_stripe`, configurez-le pour **2 stripes**.
5. Générez un fichier de **100 MB** dedans et observez sa répartition matérielle.

### Critères de réussite

- `lfs df -h` sur le client affiche le **MDT** et les **deux OSTs** avec leurs capacités.
- `lfs getstripe /mnt/lustre/test_stripe/fichier_test` affiche l'utilisation des **deux OSTs** (index 0 et 1).

### Corrigé (snippets)

```bash
# Sur vm-mgs (IP: 10.0.0.10)
mkfs.lustre --fsname=mini --mgs --mdt /dev/sdb
mount -t lustre /dev/sdb /mnt/mdt

# Sur vm-oss
mkfs.lustre --fsname=mini --mgsnode=10.0.0.10@tcp0 --ost --index=0 /dev/sdb
mkfs.lustre --fsname=mini --mgsnode=10.0.0.10@tcp0 --ost --index=1 /dev/sdc
mount -t lustre /dev/sdb /mnt/ost0
mount -t lustre /dev/sdc /mnt/ost1

# Sur vm-client
mount -t lustre 10.0.0.10@tcp0:/mini /mnt/lustre
lfs setstripe -c 2 /mnt/lustre/test_stripe
dd if=/dev/urandom of=/mnt/lustre/test_stripe/data.bin bs=1M count=100
lfs getstripe /mnt/lustre/test_stripe/data.bin
```

---

## 📝 Examen de fin de volume 3

### QCM (1 point chaque)

**1.** Quel composant de Lustre est interrogé lorsqu'un utilisateur exécute `ls -l` ?  
- A) Le MGS  
- B) **Le MDT**  
- C) L'OST  

**2.** Pourquoi un fichier de 5 Ko ne devrait-il **pas** avoir un stripe count de 4 ?  
- A) Parce que Lustre ne gère pas les fichiers de moins de 1 Mo  
- B) **Parce que cela oblige le client à contacter 4 OSTs pour récupérer 5 Ko, augmentant la latence sans bénéfice de débit**  
- C) Parce que cela corrompt le fichier  

---

### Question ouverte (Exploitation)

Un chercheur signale que son job (qui génère **5 millions de fichiers textes de 10 octets** chacun) **fige totalement** le cluster. Vous observez les métriques de la baie Lustre. **Quel composant** (MGS, MDS ou OSS) affiche une charge de 100 %, **pourquoi** ce workload est-il inadapté au stockage HPC, et **que proposez-vous** au chercheur ?

**Réponse attendue** : Le **MDS** (Metadata Server) sera à 100 %. Créer un fichier = créer un inode (métadonnée). 5 millions de micro-fichiers = **tempête d’IOPS aléatoires** (metadata storm). **Solution** : utiliser **HDF5**, **NetCDF**, ou regrouper les sorties via **MPI-IO** dans un seul gros fichier structuré ; à défaut, SQLite ou format d’archive non compressée.

---

### Étude de cas : « Le Split-Brain Lustre et la panique des locks »

Vous avez un cluster Lustre. Le **lien réseau du MDS** « bagotte » (déconnexions/reconnexions toutes les 5 secondes).

1. **Décrivez** l’impact immédiat sur les clients Lustre en train d’écrire.
2. **Expliquez** le mécanisme d’**éviction** (Lustre Eviction).
3. **Quelle commande** l’administrateur peut-il utiliser sur le MDS pour forcer la purge des verrous obsolètes (ou permettre aux clients de crasher proprement) ?

**Réponses attendues :**

1. Les clients **bloquent** (hang) en mode **D state** (Uninterruptible Sleep) car ils perdent le contact avec le **DLM** (Distributed Lock Manager) du MDS.
2. Après un **timeout** (souvent 100 s, réglable via `obd_timeout`), le MDS considère les clients inaccessibles et les **évince** : il détruit leurs verrous pour protéger l’intégrité du FS.
3. **`lctl clear`** ou reboot ciblé du MDS (cassera les jobs en cours). La **vraie** solution est la **stabilisation du réseau LNet**.

---

## Solutions des QCM

- **Q1** : **B** — `ls -l` interroge les métadonnées (MDT).
- **Q2** : **B** — Petit fichier = 1 OST ; multi-OST pour 5 Ko est contre-productif.

---

## 📚 Références (Volume 3)

- OpenSFS & EOFS. (2024). *Lustre Operations Manual.*
- Shipman, G., et al. (2010). *Lustre: The default IO stack for the HPC community.*
- ThinkParQ. (2023). *BeeGFS Architecture Guide.*

---

## 📋 Relecture qualité du volume 3

- [x] Couverture : Hiérarchisation, internals Lustre, striping, LNet, comparatifs
- [x] Rigueur technique : DLM, stripe-count, DNE
- [x] Format : Markdown, schéma ASCII Lustre, blocs de code
- [x] Pédagogie : Lab Lustre en VM, questions d’examen orientées production

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](Manuel-HPC-Sommaire-Complet)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Volume 1](Manuel-Architecture-HPC-Volume1)** : fondations, provisioning
- **[Manuel Architecture HPC — Volume 2](Manuel-Architecture-HPC-Volume2)** : réseaux, InfiniBand, sécurité
- **[Cours HPC Complet](Cours-HPC-Complet)** : concepts, stockage, parallélisme
- **[Glossaire et Acronymes](Glossaire-et-Acronymes)** : Lustre, MDS, OST, LNet, HSM, etc.
- **[Home](Home)** : page d'accueil du wiki

---

**Volume 3** — Stockage parallèle et gestion des données (Deep Dive Lustre)  
**Dernière mise à jour** : 2024
