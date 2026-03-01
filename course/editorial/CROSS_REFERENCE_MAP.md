# Plan 40 volumes — Références croisées et métadonnées

**Niveau** : Licence (V01–V14), Master (V15–V30), Doctorat (V31–V40).  
Chaque volume : titre, niveau, prérequis, objectifs, TDM haute-niveau, labs, évaluations, dépendances.

---

## Licence — Fondations (V01–V14)

| Vol | Titre | Prérequis | Objectifs principaux | Labs (nb) | Dépendances |
|-----|--------|-----------|------------------------|-----------|-------------|
| V01 | Fondations Linux pour HPC | Aucun | CLI, système de fichiers, processus, paquets (zypper), services (systemd) | 2 | — |
| V02 | Réseau Linux et services | V01 | TCP/IP, firewall (firewalld), SSH, DNS basique, NTP | 2 | V01 |
| V03 | Scripting shell (Bash) | V01 | Bash, variables, tests, boucles, scripts d’administration | 2 | V01 |
| V04 | Services et daemons (systemd) | V01, V03 | Unités, cibles, logs (journalctl), démarrage | 2 | V01, V03 |
| V05 | Sécurité Linux de base | V01, V02 | Utilisateurs, permissions, SELinux/AppArmor basique, bonnes pratiques | 2 | V01, V02 |
| V06 | Stockage et systèmes de fichiers | V01 | Partitions, LVM, RAID logiciel, NFS client | 2 | V01 |
| V07 | Introduction au calcul parallèle | V01 | Notions HPC, CPU/RAM/I/O, parallélisme (processus, threads) | 2 | V01 |
| V08 | Introduction à Slurm (utilisateur) | V01, V07 | Partitions, sbatch, srun, squeue, sacct, bonnes pratiques | 2 | V01, V07 |
| V09 | Gestion des jobs et files d’attente | V08 | QoS, priorités, dépendances, job arrays, ressources | 2 | V08 |
| V10 | Stockage partagé et données | V06, V08 | Scratch/project/archive, chemins, quotas, bonnes pratiques I/O | 2 | V06, V08 |
| V11 | Logs et diagnostic de base | V01, V04 | journalctl, fichiers log, grep, bases du troubleshooting | 2 | V01, V04 |
| V12 | Notions de monitoring (utilisateur) | V08, V11 | Métriques (CPU, RAM), Grafana/Prometheus (vue utilisateur) | 1 | V08, V11 |
| V13 | Environnements et modules (Lmod) | V01, V08 | Modules, environnement de calcul, reproductibilité | 2 | V01, V08 |
| V14 | Projet intégré Licence | V01–V13 | Mise en œuvre complète : soumission, analyse, rapport | 1 projet | V01–V13 |

---

## Master — Conception et optimisation (V15–V30)

| Vol | Titre | Prérequis | Objectifs principaux | Labs (nb) | Dépendances |
|-----|--------|-----------|------------------------|-----------|-------------|
| V15 | Slurm avancé (administration) | V08, V09 | slurm.conf, slurmctld, slurmd, slurmdbd, accounting | 3 | V08, V09 |
| V16 | Ordonnancement et politiques | V15 | Fairshare, backfill, preemption, QoS avancées | 2 | V15 |
| V17 | Réseaux datacenter (HPC) | V02 | Spine-Leaf, Jumbo Frames, InfiniBand/RoCE notions | 2 | V02 |
| V18 | Stockage parallèle (Lustre/BeeGFS) | V06, V10 | POSIX parallèle, Lustre (MDS/OSS), striping, quotas | 3 | V06, V10 |
| V19 | Conteneurs et HPC (Docker, Apptainer) | V01, V08 | Docker, Apptainer/Singularity, intégration Slurm | 3 | V01, V08 |
| V20 | MPI (concepts et pratique) | V07, V08 | MPI, rank, communicateurs, collectives, binding | 3 | V07, V08 |
| V21 | GPU et accélération (CUDA/ROCm) | V07, V08 | GRES, allocation GPU, NCCL, bonnes pratiques | 3 | V07, V08 |
| V22 | Observabilité (Prometheus, Grafana) | V12, V15 | Métriques, alertes, dashboards, exporters (Slurm, Node) | 3 | V12, V15 |
| V23 | Logs centralisés (Loki, Promtail) | V11, V22 | Agrégation logs, requêtes, corrélation avec métriques | 2 | V11, V22 |
| V24 | Infrastructure as Code (Ansible) | V01, V03, V04 | Playbooks, inventaire, idempotence, rôles | 3 | V01, V03, V04 |
| V25 | Haute disponibilité et résilience | V15, V22 | Slurm HA, failover, santé des services | 2 | V15, V22 |
| V26 | Sauvegarde et reprise (backup/DR) | V06, V18, V24 | Stratégies, RPO/RTO, runbooks | 2 | V06, V18, V24 |
| V27 | Capacity planning et coûts | V15, V22 | Utilisation, tendances, dimensionnement | 2 | V15, V22 |
| V28 | Sécurité avancée (auth, hardening) | V05, V15 | LDAP, Kerberos, FreeIPA, durcissement SSH, segmentation | 3 | V05, V15 |
| V29 | CI/CD et qualité (lint, tests) | V03, V24 | Pipelines, lint (shellcheck, yamllint), tests | 2 | V03, V24 |
| V30 | Projet intégré Master | V15–V29 | Conception/extension d’un mini-cluster (repo hpc-cluster) | 1 projet | V15–V29 |

---

## Doctorat — Recherche et sujets avancés (V31–V40)

| Vol | Titre | Prérequis | Objectifs principaux | Labs (nb) | Dépendances |
|-----|--------|-----------|------------------------|-----------|-------------|
| V31 | Théorie de l’ordonnancement | V16 | Modèles, fairness, garanties, limites | 2 | V16 |
| V32 | Ordonnancement énergie-aware | V16, V31 | Power capping, DVFS, métriques énergie | 2 | V16, V31 |
| V33 | Filesystems à grande échelle | V18 | Lustre/GPFS/CephFS avancé, tiering, HSM | 2 | V18 |
| V34 | Chaos engineering et résilience | V25, V26 | Tests de chaos, injection de pannes, SRE | 2 | V25, V26 |
| V35 | Science des incidents (post-mortem) | V11, V22, V23 | RCA, blameless, runbooks, MTTR | 2 | V11, V22, V23 |
| V36 | Benchmarking rigoureux (HPL, IOR, etc.) | V07, V18, V20 | Méthodologie, reproductibilité, interprétation | 3 | V07, V18, V20 |
| V37 | Reproductibilité et open science | V13, V19, V36 | Containers, environnements, données, publications | 2 | V13, V19, V36 |
| V38 | Sécurité avancée (Zero Trust, gouvernance) | V28 | Zero Trust réaliste, conformité, audit | 2 | V28 |
| V39 | SRE et opérations HPC | V22, V25, V26, V35 | SLO/SLA, on-call, amélioration continue | 2 | V22, V25, V26, V35 |
| V40 | Thème libre / synthèse Doctorat | V31–V39 | Mémoire ou projet de recherche appliquée | 1 | V31–V39 |

---

## Table des matières haute-niveau (exemple V01)

- Chapitre 1 : Introduction au système Linux et à la ligne de commande
- Chapitre 2 : Système de fichiers et permissions
- Chapitre 3 : Processus et gestion des tâches
- Chapitre 4 : Gestion des paquets (zypper, rpm)
- Chapitre 5 : Services et systemd (notions)
- Chapitre 6 : Réseau de base (IP, ping, curl)
- Chapitre 7 : Édition et scripts minimalistes
- Chapitre 8 : Lab 1 — Environnement de travail
- Chapitre 9 : Lab 2 — Installation d’un service type (ex. Node Exporter)
- Annexes : Glossaire, références, corrigés

---

## Dépendances entre volumes (graphe simplifié)

- V01 → V02, V03, V04, V05, V06, V07, V08, …
- V08 → V09, V10, V12, V13, V15, V19, V20, V21
- V15 → V16, V22, V25, V28
- V22 → V23, V27, V35, V39
- V18 → V26, V33
- V31, V32 dépendent de V16 ; V34–V40 synthétisent les volumes précédents.

---

**Utilisation** : Pour chaque volume, générer la structure (book.md + chapters/) en s’appuyant sur cette carte et sur SOURCE_INDEX.md pour les exemples concrets tirés du repo.
