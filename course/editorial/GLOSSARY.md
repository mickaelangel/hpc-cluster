# Glossaire — Collection de cours HPC

**Usage** : Référence commune pour les 40 volumes. Les termes ci-dessous sont définis une fois ; les chapitres y renvoient.

---

## A–C

- **Allocation** : Ensemble de ressources (CPU, RAM, temps) accordé à un job par le scheduler (ex. Slurm).
- **Backfill** : Politique d’ordonnancement qui remplit les « trous » dans le planning avec des jobs plus courts.
- **Bare-metal** : Installation directe sur le matériel (sans VM), opposé à conteneur/cloud.
- **cgroups** : Control groups (Linux) — limitation et comptage des ressources (CPU, mémoire) par groupe de processus.
- **Compute node** : Nœud de calcul exécutant les jobs (dans ce projet : compute-01 … compute-06).

---

## D–F

- **Fairshare** : Mécanisme Slurm qui répartit les priorités en fonction de l’usage passé (équité).
- **Frontal (login node)** : Nœud d’accès utilisateur (SSH, compilation, soumission de jobs). Dans ce projet : frontal-01, frontal-02.
- **GRES** (Generic Resource) : Ressources génériques dans Slurm (ex. GPU, licences).

---

## H–L

- **HPC** : High Performance Computing — calcul haute performance (clusters, supercalculateurs).
- **LDAP** : Lightweight Directory Access Protocol — annuaire pour authentification et identité.
- **Lustre** : Système de fichiers parallèle (MDS, OSS, LNet) utilisé en HPC.
- **Lmod** : Gestionnaire de modules d’environnement (logiciels, versions).

---

## M–P

- **MPI** : Message Passing Interface — standard de communication pour programmes parallèles distribués.
- **Munge** : Service d’authentification utilisé par Slurm entre nœuds (clés partagées).
- **Partition** : Groupe de nœuds Slurm avec des règles communes (ex. normal, gpu).
- **POSIX** : Interface standard de systèmes de fichiers (portabilité).
- **QoS** (Quality of Service) : Contraintes Slurm (durée max, priorité, limites) attachées à une partition ou un groupe.

---

## R–Z

- **RDMA** : Remote Direct Memory Access — accès mémoire à distance (faible latence, InfiniBand, RoCE).
- **Slurm** : Scheduler et gestionnaire de ressources pour clusters (slurmctld, slurmd, slurmdbd).
- **SlurmCTLD** : Daemon contrôleur Slurm (scheduling, état des nœuds).
- **SlurmD** : Daemon Slurm sur chaque nœud de calcul (exécution des jobs).
- **SlurmDBD** : Daemon base de données Slurm (accounting).
- **Striping** : Répartition des données sur plusieurs cibles (ex. OST Lustre) pour le débit.
- **Walltime** : Durée maximale allouée à un job (temps « mur »).

---

*Pour les acronymes et termes complémentaires, voir aussi le wiki : [Glossaire et Acronymes](.github/wiki/Glossaire-et-Acronymes.md), [Dictionnaire encyclopédique HPC](.github/wiki/Dictionnaire-Encyclopedique-HPC.md).*
