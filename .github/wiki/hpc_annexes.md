# Annexes SRE & Cheatsheets HPC

> **Référence opérationnelle — Niveau SRE / Admin production**  
> Complément au Manuel en 8 volumes et au Dictionnaire encyclopédique HPC.

---

## Annexe A — Cheatsheet Slurm (Admin & Utilisateur avancé)

### A.1 Commandes utilisateur courantes

| Commande | Description |
|----------|-------------|
| `sbatch script.sh` | Soumettre un job batch |
| `srun [options] --pty bash` | Job interactif (shell) |
| `squeue -u $USER` | Mes jobs (file d'attente) |
| `squeue --start` | Heure de démarrage **prédite** (backfill) |
| `scancel <jobid>` | Annuler un job |
| `sinfo -s` | Résumé partitions / nœuds |
| `sacct -j <jobid>` | Historique et statut détaillé d'un job |

### A.2 Commandes admin (slurmctld / nœud de contrôle)

| Commande | Description |
|----------|-------------|
| **scontrol show job \<id\>** | Détail complet d'un job (allocation, nœuds, limites) |
| **scontrol show node [name]** | État d'un ou tous les nœuds (reason, config) |
| **scontrol show partition \<name\>** | Limites, nœuds, état de la partition |
| **scontrol update jobid=\<id\> TimeLimit=...** | Modifier un job en attente |
| **scontrol update nodename=\<n\> state=drain reason="maintenance"** | Mettre un nœud en drain |
| **scontrol reconfigure** | Recharger la config Slurm (sans redémarrage) |
| **scontrol shutdown** | Arrêt propre du contrôleur (slurmctld) |

### A.3 Comptabilité et diagnostic (sacct, sdiag)

| Commande | Description |
|----------|-------------|
| **sacct -S YYYY-MM-DD -E YYYY-MM-DD -u user** | Jobs d'un utilisateur sur une période |
| **sacct -o JobID,JobName,Partition,State,Elapsed,MaxRSS,ExitCode,Reason** | Colonnes utiles pour RCA |
| **sacct -s FAILED,TIMEOUT,CANCELLED** | Jobs en échec / annulés / timeout |
| **sdiag** | Statistiques internes du scheduler (RPC, backfill, slurmctld) |
| **sdiag -f** | Format plus lisible (souvent utilisé pour vérifier santé du contrôleur) |

### A.4 Check-list rapide — Incident « jobs ne partent pas »

1. [ ] `sinfo` : des nœuds sont-ils `idle` ou tous `allocated`/`drain`/`down` ?
2. [ ] `scontrol show node` : vérifier **Reason** sur les nœuds en drain/down.
3. [ ] `squeue -t pending` : les jobs sont-ils **PENDING** avec une partition valide ?
4. [ ] `sdiag` : **Server thread count** et **Agent queue size** normaux ? (pas de saturation).
5. [ ] Logs : `journalctl -u slurmctld` (ou fichier log configuré) pour erreurs récentes.

---

## Annexe B — Cheatsheet Lustre (lfs, OST, lctl)

### B.1 Stripe et capacité

| Commande | Description |
|----------|-------------|
| **lfs getstripe /path/to/file** | OST(s) et stripe size/count du fichier |
| **lfs setstripe -c \<n\> -S \<size\> /path/dir** | Définir stripe count et taille pour les **nouveaux** fichiers du répertoire |
| **lfs df -h** | Utilisation par OST/MDT (détecter **OST Imbalance**) |
| **lfs find /path -stripe-count 1** | Fichiers sur un seul OST (candidats migration) |

### B.2 OST pleins et rééquilibrage

| Commande / outil | Description |
|------------------|-------------|
| **lfs df -h** | Repérer les OST à 100 % (cause classique d'ENOSPC malgré espace global libre) |
| **lfs_migrate** | Migrer des fichiers d'un OST vers d'autres (rééquilibrer) |
| **lfs setstripe** sur un **nouveau** répertoire | Pour les futures écritures, répartir sur plus d'OST |

> **Danger en prod** : Ne pas lancer de migration massive pendant des jobs I/O intensifs ; privilégier une fenêtre de maintenance ou un répertoire ciblé.

### B.3 Debug réseau et verrous (lctl)

| Commande | Description |
|----------|-------------|
| **lctl get_param ldlm.namespaces.\*.lock_count** | Nombre de verrous actifs (DLM/LDLM) |
| **lctl ping \<target\>** | Test de connectivité vers un nœud Lustre |
| **lctl list_param \*** | Lister les paramètres configurables (par nœud) |
| **lctl set_param obd_timeout=...** | Ajuster le délai avant éviction d'un client non réactif (tuning avancé) |

### B.4 Check-list rapide — ENOSPC ou I/O lent

1. [ ] `lfs df -h` : un ou plusieurs OST à 100 % ?
2. [ ] `lfs getstripe` sur les fichiers concernés : stripe count = 1 sur des gros fichiers ?
3. [ ] Pour nouveaux fichiers : `lfs setstripe` sur le répertoire parent.
4. [ ] Si déséquilibre : planifier **lfs_migrate** (ou migration ciblée).
5. [ ] Côté MDS : vérifier charge et latence (outils monitoring Lustre / dmesg).

---

## Annexe C — Cheatsheet Analyse de performance Linux (HPC)

### C.1 CPU, mémoire, processus

| Outil | Usage typique HPC |
|------|-------------------|
| **htop** | Vue processus en temps réel ; tri par CPU/RAM ; affichage par nœud NUMA si disponible. |
| **numactl --hardware** | Topologie NUMA (nœuds, distances). |
| **numactl --cpunodebind=0 --membind=0 ./app** | Pinning CPU et mémoire sur le nœud NUMA 0 (éviter cross-NUMA). |
| **taskset -c 0-7 ./app** | Épingler le processus sur les CPU 0–7 (sans contrainte mémoire). |

### C.2 Performance counters (perf)

| Commande | Description |
|----------|-------------|
| **perf stat -e cycles,instructions,cache-misses ./app** | Compteurs de base (IPC, cache). |
| **perf stat -e dTLB-load-misses,dTLB-loads ./app** | TLB misses (voir entrée Hugepages du Dictionnaire). |
| **perf record -g ./app ; perf report** | Profilage avec call-graph (identifier les hotspots). |
| **perf top** | Compteurs en temps réel (processus ou système). |

### C.3 I/O disque et réseau

| Outil | Usage typique HPC |
|------|-------------------|
| **iostat -x 5** | Utilisation disque (r/s, w/s, %util) — utile sur nœuds avec stockage local ou NFS/Lustre client. |
| **iotop** | Par processus (qui fait du I/O). |
| **nvidia-smi** | GPU : utilisation, mémoire, processus (nœuds GPU). |

### C.4 Check-list rapide — Job lent ou nœud instable

1. [ ] **CPU** : governor en `performance` ? (`cpupower frequency-info`).
2. [ ] **Mémoire** : OOM récents ? `dmesg -T \| grep -i oom` ; **Hugepages** activées si pertinent (RDMA, gros buffers).
3. [ ] **NUMA** : job multi-thread / MPI — pinning cohérent (numactl / Slurm binding).
4. [ ] **I/O** : Lustre/NFS — stripe count et OST balance (Annexe B) ; pas de surcharge MDS.
5. [ ] **Jitter** : Transparent Hugepages désactivé sur nœuds de calcul ? (`/sys/kernel/mm/transparent_hugepage/enabled`).

---

## Annexe D — Modèle Post-Mortem Blameless (RCA) pour le HPC

Modèle structuré pour une **Root Cause Analysis** sans recherche de coupable, centrée sur les processus et les correctifs.

### D.1 En-tête du document

- **Titre** : [Court résumé de l’incident]
- **Date de l’incident** :
- **Date du post-mortem** :
- **Auteur(s)** :
- **Statut** : Brouillon / Validé / Clôturé

### D.2 Symptômes

- Description **observable** : ce que les utilisateurs ou les monitoring ont constaté (ex. « tous les jobs en file d’attente depuis 14 h », « nœuds compute-01 à 10 en drain », « erreur ENOSPC sur /scratch »).
- **Métriques** : captures d’écran, extraits de `sinfo`, `squeue`, `lfs df`, alertes (si disponibles).

### D.3 Impact

- **Utilisateurs** : nombre de jobs annulés / retardés, projets affectés.
- **Disponibilité** : durée d’indisponibilité ou dégradation (SLA si applicable).
- **Données** : perte ou corruption (si aucune : préciser « aucune perte de données »).

### D.4 Timeline

| Heure (UTC) | Événement |
|-------------|------------|
| T+0 | … |
| T+… | … |

Objectif : ordre chronologique des faits (détection, actions, résolution).

### D.5 Analyse (5 Pourquoi — résumé)

1. **Pourquoi** [symptôme observable] ? → …
2. **Pourquoi** … ? → …
3. (Jusqu’à atteindre une cause racine ou un facteur contributif clair.)

Exemple schématique :  
*Pourquoi les jobs ne démarraient plus ? → Slurm considérait tous les nœuds comme down. Pourquoi ? → slurmd ne répondait plus. Pourquoi ? → OOM-Killer a tué slurmd. Pourquoi ? → Un job a dépassé sa limite mémoire et le Cgroup n’était pas activé (ConstrainRAMSpace).*

### D.6 Cause racine (et facteurs contributifs)

- **Cause racine** : une phrase claire (ex. « Cgroups v2 non activés pour la partition X, permettant à un job de saturer la RAM du nœud et de provoquer un OOM global. »).
- **Facteurs contributifs** : surveillance (alertes manquantes), documentation (runbook absent), configuration (valeur par défaut risquée), etc.

### D.7 Action Items

| # | Action | Responsable | Échéance | Statut |
|---|--------|-------------|----------|--------|
| 1 | Activer ConstrainRAMSpace + AllowedRAMSpace sur tous les nœuds | … | … | Ouvert / Fait |
| 2 | Ajouter alerte sur état « drain » des nœuds | … | … | … |
| 3 | Documenter la procédure OOM dans le runbook | … | … | … |

### D.8 Renvois utiles (documentation interne)

- Lien vers le **Dictionnaire encyclopédique** (entrées OOM-Killer, Cgroups, Slurmd).
- Lien vers **runbooks** (drain, redémarrage slurmd, vérification Lustre).
- Lien vers **Annexes A/B/C** (commandes Slurm, Lustre, perf/numactl).

---

**Annexes SRE & Cheatsheets HPC** — Manuel Architecture HPC  
**Niveau** : SRE / Admin production — **Dernière mise à jour** : 2024
