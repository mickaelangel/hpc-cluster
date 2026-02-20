# 📚 Manuel d'architecture et d'ingénierie HPC

**Volume 6 : Ingénierie des performances et benchmarking**

> **Niveau** : DevOps Senior / Architecte HPC — **Public** : Master, Doctorat, ingénieurs système

---

## Vue d'ensemble du volume

L'infrastructure est stable, l'environnement logiciel est déployé. Ce volume couvre la phase la plus **scientifique** de l'ingénierie HPC : traquer la latence et saturer la bande passante matérielle. On y traite l'**architecture mémoire** (NUMA, pinning, Hugepages), la **méthodologie de profiling** (modèle Roofline, `perf`), puis le **benchmarking en production** (HPL, HPCG, IOR, mdtest). Les [Labs 8 & 9](#-lab-8--9--numa-stream-et-profiling-perf) et l'[examen de fin de volume](#-examen-de-fin-de-volume-6) permettent de valider les acquis.

**Prérequis :**
- Caches L1/L2/L3, RAM, TLB, gestion des pages (Ch. 19)
- Compilation C/Fortran avec symboles de débogage `-g` (Ch. 20)
- MPI, [Slurm](Guide-SLURM-Complet), [Lustre](Glossaire-et-Acronymes#l) (Ch. 21)

---

## Chapitre 19 : Architecture mémoire et optimisation (NUMA & Hugepages)

### Objectifs d'apprentissage

- Comprendre la **topologie NUMA** et l'impact des interconnexions inter-sockets (UPI, Infinity Fabric)
- Maîtriser le **pinning** (affinité) des processus et de la mémoire
- Optimiser via les **Hugepages**

---

### 19.1 La réalité de l'architecture NUMA

La plupart des serveurs HPC sont **bi-socket** ou à **chiplets** (ex. AMD EPYC). Chaque processeur/chiplet a son **contrôleur mémoire** et sa **RAM locale** → un **nœud NUMA** (Non-Uniform Memory Access).

Si le **CPU 0** lit une donnée dans la **RAM du CPU 1**, la requête passe par le bus d'interconnexion (Intel **UPI** ou AMD **Infinity Fabric**).

| Conséquence | Impact |
|-------------|--------|
| **Latence** | Augmentation d'environ **30 à 50 %** |
| **Bande passante** | Divisée : le bus inter-socket est souvent plus lent que la bande passante mémoire locale agrégée |

---

### 19.2 Pinning et outil numactl

Pour des **performances maximales**, un processus MPI (ou thread OpenMP) doit être **épinglé** (pinned) sur un cœur donné, et sa **mémoire** allouée sur le **nœud NUMA local**. Linux utilise la politique **« First Touch »** : la page physique est allouée sur le nœud NUMA du **premier thread** qui écrit dedans.

**Exemple avec numactl :**

```bash
# Topologie NUMA et distances entre nœuds
numactl --hardware

# Forcer le code sur les cœurs du nœud NUMA 0 et la mémoire sur la RAM du nœud 0
numactl --cpunodebind=0 --membind=0 ./mon_code_intensif
```

---

### 19.3 L'optimisation par les Hugepages

Le **TLB** (Translation Lookaside Buffer) traduit les adresses virtuelles en physiques. Par défaut, Linux utilise des **pages de 4 Ko**. Une application avec **64 Go** de RAM → **16 millions de pages** → le TLB (quelques milliers d'entrées) est **saturé** → **TLB misses** coûteux.

Les **Hugepages** (2 Mo ou 1 Go) réduisent le **nombre de pages**, limitant fortement les TLB misses pour les grands tableaux.

---

### Piège : « Le First Touch fatal »

En **OpenMP**, le **thread maître (0)** initialise souvent un grand tableau en **séquentiel** avant le calcul parallèle. **Conséquence** : toute la mémoire est allouée sur le **nœud NUMA du thread 0**. Pendant le calcul, les autres threads **saturent le bus inter-socket**. **Solution** : **paralléliser l'initialisation** aussi.

---

### Check-list production (Chapitre 19)

- [ ] Surveiller **numad** ou **numastat**
- [ ] Pour clusters MPI purs : configurer Slurm avec **TaskPlugin=task/affinity,task/cgroup**

---

## Chapitre 20 : Méthodologie de profiling et modèle Roofline

### Objectifs d'apprentissage

- Diagnostiquer les **goulots d'étranglement** (CPU-bound vs Memory-bound)
- Utiliser les **compteurs de performance** via **perf**
- Interpréter le **modèle Roofline**

---

### 20.1 Le modèle Roofline

Le **modèle Roofline** relie les **performances flottantes** (GFLOPS), la **bande passante mémoire** (Go/s) et l'**intensité arithmétique** d'un algorithme.

**Intensité arithmétique (I)** = nombre d'**opérations flottantes** par **octet** transféré depuis la RAM (FLOP/byte).

**Performance théorique maximale P :**

```
P = min(P_peak, I × b_peak)
```

*(P_peak = puissance crête du CPU, b_peak = bande passante mémoire crête.)*

| Zone | Signification | Optimisation typique |
|------|----------------|----------------------|
| **Memory-bound** (pente) | Intensité faible (ex. addition de vecteurs). Le code attend la RAM. | Cache blocking, tuning NUMA. |
| **Compute-bound** (plafond plat) | Intensité élevée (ex. multiplication matricielle dense). | Vectorisation (AVX-512), multithreading. |

---

### 20.2 Profiling léger avec perf

**perf** lit les registres **PMU** (Performance Monitoring Unit) du processeur avec un **overhead** quasi nul.

**Commandes de base :**

```bash
# Statistiques globales (IPC, cache misses, branch misses)
perf stat ./mon_code_calcul

# Enregistrer l'arbre d'appels (call graph)
perf record --call-graph fp ./mon_code_calcul

# Analyser le rapport
perf report
```

---

## Chapitre 21 : Benchmarking en production et acceptation

### Objectifs d'apprentissage

- Déployer et tuner le benchmark **HPL** (Top500)
- Exécuter la suite **OSU Micro-Benchmarks** pour valider l'interconnexion
- Valider les performances **I/O** avec **IOR** et **mdtest**

---

### 21.1 HPL (High Performance Linpack)

**HPL** résout un système d'équations linéaires denses **Ax = b**. Très **compute-bound**, basé sur **BLAS** (DGEMM). C'est le **mètre étalon** du classement **Top500**.

**Méthodologie de tuning :**
- La taille du problème **N** doit remplir environ **80–90 %** de la RAM totale du cluster.
- La grille MPI **(P×Q)** doit être la plus **carrée** possible pour limiter les communications de bordure.

---

### 21.2 HPCG (High Performance Conjugate Gradients)

**HPL** ne reflète plus les charges réelles (souvent **memory-bound**). **HPCG** mesure les accès mémoire irréguliers, la bande passante et les collectives. Un système à **80 %** du pic sur HPL peut n'atteindre que **2–3 %** sur HPCG.

---

### 21.3 Benchmarking I/O : IOR et mdtest

| Outil | Mesure | Usage |
|-------|--------|--------|
| **IOR** | Bande passante brute (Go/s) | Gros fichiers (MPI-IO ou fichier par processus). |
| **mdtest** | Métadonnées (IOPS) | Création/lecture/suppression de millions de fichiers → stress du **MDS** Lustre. |

**Exemple IOR (File-Per-Process, write puis read) :**

```bash
# -F : fichier par processus, -w : write, -r : read, -b : block size, -t : transfer size
srun mpirun -np 128 ior -F -w -r -b 10G -t 1M -o /scratch/test_ior/data
```

---

### DANGER en prod : « Le benchmark destructeur »

Lancer **mdtest** avec des **millions de fichiers** à la racine de `/scratch` en production peut **saturer le MDT** (100 %) et bloquer tous les jobs. **Isoler** les benchmarks I/O, idéalement en **fenêtre de maintenance**.

---

## 🧪 Lab 8 & 9 : NUMA, STREAM et profiling perf

### Énoncé

**Lab 8 (NUMA/STREAM)** : Compilez le benchmark **STREAM** (bande passante mémoire). Exécutez-le **sans contrainte**, puis en le **forçant sur un seul nœud NUMA** via `numactl`. Observez la différence en **Mo/s**.

**Lab 9 (Perf)** : Écrivez un petit programme C qui itère sur un tableau 2D **10000×10000** : une version **par lignes** (row-major, cache friendly) et une **par colonnes** (column-major, cache hostile). Utilisez **perf stat -e cache-misses** sur les deux et analysez.

### Critères de réussite

- STREAM avec **numactl** montre une bande passante **locale maximale et stable** par rapport à une exécution inter-socket.
- **perf stat** montre un nombre de **cache-misses** nettement plus élevé (souvent ×10 à ×20) sur la version **par colonnes** en C.

### Corrigé (Lab 9 — piège column-major en C)

```c
// Le CPU charge des lignes de cache (64 octets). Parcourir par colonne
// détruit l'efficacité du Hardware Prefetcher.
int matrix[10000][10000];

// CACHE FRIENDLY (C)
for (int i = 0; i < 10000; i++)
    for (int j = 0; j < 10000; j++)
        matrix[i][j] = 1;

// CACHE HOSTILE (à proscrire en C ; en Fortran c'est l'inverse)
for (int j = 0; j < 10000; j++)
    for (int i = 0; i < 10000; i++)
        matrix[i][j] = 1;
```

**Exécution :** `perf stat -e L1-dcache-load-misses ./bad_code`

---

## 📝 Examen de fin de volume 6

### QCM (1 point chaque)

**1.** Pourquoi recommande-t-on souvent d'activer les **Hugepages** pour un code MPI ?  
- A) Pour augmenter la fréquence du CPU  
- B) **Pour réduire les TLB misses lors de l'accès à de grandes zones mémoire contiguës**  
- C) Pour forcer l'utilisation du GPU  

**2.** Dans le modèle Roofline, que représente la zone **« plafond »** horizontale du graphique ?  
- A) La limite de bande passante du réseau InfiniBand  
- B) La limite causée par les accès mémoire (Memory-bound)  
- C) **La limite de performance de calcul maximale du CPU (Compute-bound)**  

**3.** Quel benchmark est utilisé historiquement pour le **classement Top500** (résolution de systèmes linéaires) ?  
- A) IOR  
- B) **HPL**  
- C) HPCG  

---

### Question ouverte (Analyse de métriques)

Vous analysez un job avec **perf stat**. **IPC = 0,2** (Instructions Per Cycle) et **Branch miss rate = 15 %**. Le processeur peut exécuter jusqu'à **4 instructions par cycle**.

**Expliquez** ce que signifie un IPC de 0,2 et **comment** le fort taux de branch misses contribue à ce résultat au niveau du **pipeline**.

**Réponse attendue** : Un IPC de **0,2** signifie que le CPU **stalle** ~80 % du temps (attend la RAM ou vide son pipeline). Le **branch predictor** devine les branches (if/else). À **15 %** de miss, le processeur **annule** les instructions spéculatives, jette les calculs et recharge le bon chemin → **pénalité** importante en cycles perdus.

---

### Étude de cas : « La recette magique HPL qui ne marche pas »

Vous validez l'**acceptation** d'un cluster **100 nœuds** (AMD EPYC, 128 cœurs, **512 Go RAM** par nœud). L'intégrateur fournit **HPL.dat** avec la taille **N** réglée pour **50 Go** de RAM par nœud. Le résultat est d'à peine **30 %** des FLOPS théoriques.

1. **Pourquoi** sous-dimensionner N détériore le score HPL ?  
2. **Donnez** un calcul rapide pour un **N idéal** (≈ 80 % des 512 Go).  
3. **Pourquoi** la configuration **topology.conf** de Slurm est-elle critique pour ce test ?

**Réponses attendues :**

1. HPL fait des calculs en **O(N³)** et des communications en **O(N²)**. Plus **N** est grand, plus le ratio **Calculs/Communications** augmente (intensité arithmétique) → meilleure saturation du CPU et masquage de la latence réseau.

2. **80 % × 512 Go ≈ 410 Go** par nœud. Matrice **A** : N²×8 octets (double). Total cluster : 410 Go × 100 = 41 000 Go. N² × 8 = 41×10¹² octets → **N ≈ √(41×10¹²/8) ≈ 2,26×10⁶**.

3. HPL envoie des données en continu. Si les rangs MPI ne sont pas **cartographiés** (topology.conf) pour minimiser les **sauts** sur les switches, la **congestion réseau** ralentit tout le système.

---

## Solutions des QCM

- **Q1** : **B** — Hugepages réduisent les TLB misses.  
- **Q2** : **C** — Plafond = Compute-bound (pic CPU).  
- **Q3** : **B** — HPL (Top500).

---

## 📋 Relecture qualité du volume 6

- [x] Couverture : NUMA (numactl), Hugepages/TLB, Roofline, perf, HPL, HPCG, IOR/mdtest
- [x] Rigueur technique : formules Roofline et HPL, distinction Memory-bound / Compute-bound
- [x] Format : Markdown, structure claire
- [x] Pédagogie : Labs (STREAM, piège column-major), étude de cas Top500

---

## Liens utiles

- **[Sommaire complet du Manuel HPC](Manuel-HPC-Sommaire-Complet)** : plan des 8 volumes, chapitres, labs
- **[Manuel Architecture HPC — Vol. 1 à 5](Manuel-Architecture-HPC-Volume1)** : fondations, réseaux, stockage, Slurm, toolchains
- **[Guide SLURM Complet](Guide-SLURM-Complet)** : partitions, topology, task/affinity
- **[Glossaire et Acronymes](Glossaire-et-Acronymes)** : NUMA, TLB, HPL, HPCG, etc.
- **[Home](Home)** : page d'accueil du wiki

---

**Volume 6** — Ingénierie des performances et benchmarking  
**Dernière mise à jour** : 2024
