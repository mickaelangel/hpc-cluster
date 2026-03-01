# Collection des 40 volumes — Cours HPC

Cette arborescence contient les **40 volumes** de la collection de cours (Licence → Master → Doctorat) sur l’administration HPC, l’observabilité, la sécurité et l’exploitation de clusters.

**Plan détaillé** : [CROSS_REFERENCE_MAP.md](../editorial/CROSS_REFERENCE_MAP.md) (titres, prérequis, objectifs, labs, dépendances).

---

## Statut des volumes

| Vol | Dossier | Titre | Niveau | Statut |
|-----|---------|--------|--------|--------|
| V01 | [V01_Fondations_Linux_HPC](V01_Fondations_Linux_HPC/) | Fondations Linux pour HPC | Licence | ✅ Rédigé (chapitres 1–9, 2 labs, exercices, corrigés) |
| V02 | [V02_Reseau_Linux_Services](V02_Reseau_Linux_Services/) | Réseau Linux et services | Licence | 🔜 Squelette |
| V03 | [V03_Scripting_Bash](V03_Scripting_Bash/) | Scripting shell (Bash) | Licence | 🔜 Squelette |
| V04 | [V04_Services_Systemd](V04_Services_Systemd/) | Services et daemons (systemd) | Licence | 🔜 Squelette |
| V05 | [V05_Securite_Linux_Base](V05_Securite_Linux_Base/) | Sécurité Linux de base | Licence | 🔜 Squelette |
| V06 | [V06_Stockage_Filesystem](V06_Stockage_Filesystem/) | Stockage et systèmes de fichiers | Licence | 🔜 Squelette |
| V07 | [V07_Intro_Calcul_Parallele](V07_Intro_Calcul_Parallele/) | Introduction au calcul parallèle | Licence | 🔜 Squelette |
| V08 | [V08_Introduction_Slurm](V08_Introduction_Slurm/) | Introduction à Slurm (utilisateur) | Licence | 🔜 Squelette |
| V09 | [V09_Jobs_Files_Attente](V09_Jobs_Files_Attente/) | Gestion des jobs et files d’attente | Licence | 🔜 Squelette |
| V10 | [V10_Stockage_Partage](V10_Stockage_Partage/) | Stockage partagé et données | Licence | 🔜 Squelette |
| V11 | [V11_Logs_Diagnostic](V11_Logs_Diagnostic/) | Logs et diagnostic de base | Licence | 🔜 Squelette |
| V12 | [V12_Monitoring_Utilisateur](V12_Monitoring_Utilisateur/) | Notions de monitoring (utilisateur) | Licence | 🔜 Squelette |
| V13 | [V13_Modules_Lmod](V13_Modules_Lmod/) | Environnements et modules (Lmod) | Licence | 🔜 Squelette |
| V14 | [V14_Projet_Integre_Licence](V14_Projet_Integre_Licence/) | Projet intégré Licence | Licence | 🔜 Squelette |
| V15 | [V15_Slurm_Avance](V15_Slurm_Avance/) | Slurm avancé (administration) | Master | 🔜 Squelette |
| V16 | [V16_Ordonnancement_Politiques](V16_Ordonnancement_Politiques/) | Ordonnancement et politiques | Master | 🔜 Squelette |
| V17 | [V17_Reseaux_Datacenter](V17_Reseaux_Datacenter/) | Réseaux datacenter (HPC) | Master | 🔜 Squelette |
| V18 | [V18_Stockage_Parallele](V18_Stockage_Parallele/) | Stockage parallèle (Lustre/BeeGFS) | Master | 🔜 Squelette |
| V19 | [V19_Conteneurs_HPC](V19_Conteneurs_HPC/) | Conteneurs et HPC (Docker, Apptainer) | Master | 🔜 Squelette |
| V20 | [V20_MPI](V20_MPI/) | MPI (concepts et pratique) | Master | 🔜 Squelette |
| V21 | [V21_GPU_Acceleration](V21_GPU_Acceleration/) | GPU et accélération (CUDA/ROCm) | Master | 🔜 Squelette |
| V22 | [V22_Observabilite](V22_Observabilite/) | Observabilité (Prometheus, Grafana) | Master | 🔜 Squelette |
| V23 | [V23_Logs_Centralises](V23_Logs_Centralises/) | Logs centralisés (Loki, Promtail) | Master | 🔜 Squelette |
| V24 | [V24_IaC_Ansible](V24_IaC_Ansible/) | Infrastructure as Code (Ansible) | Master | 🔜 Squelette |
| V25 | [V25_HA_Resilience](V25_HA_Resilience/) | Haute disponibilité et résilience | Master | 🔜 Squelette |
| V26 | [V26_Backup_DR](V26_Backup_DR/) | Sauvegarde et reprise (backup/DR) | Master | 🔜 Squelette |
| V27 | [V27_Capacity_Planning](V27_Capacity_Planning/) | Capacity planning et coûts | Master | 🔜 Squelette |
| V28 | [V28_Securite_Avancee](V28_Securite_Avancee/) | Sécurité avancée (auth, hardening) | Master | 🔜 Squelette |
| V29 | [V29_CI_CD_Qualite](V29_CI_CD_Qualite/) | CI/CD et qualité (lint, tests) | Master | 🔜 Squelette |
| V30 | [V30_Projet_Integre_Master](V30_Projet_Integre_Master/) | Projet intégré Master | Master | 🔜 Squelette |
| V31 | [V31_Theorie_Ordonnancement](V31_Theorie_Ordonnancement/) | Théorie de l’ordonnancement | Doctorat | 🔜 Squelette |
| V32 | [V32_Ordonnancement_Energie](V32_Ordonnancement_Energie/) | Ordonnancement énergie-aware | Doctorat | 🔜 Squelette |
| V33 | [V33_Filesystems_Grande_Echelle](V33_Filesystems_Grande_Echelle/) | Filesystems à grande échelle | Doctorat | 🔜 Squelette |
| V34 | [V34_Chaos_Engineering](V34_Chaos_Engineering/) | Chaos engineering et résilience | Doctorat | 🔜 Squelette |
| V35 | [V35_Science_Incidents](V35_Science_Incidents/) | Science des incidents (post-mortem) | Doctorat | 🔜 Squelette |
| V36 | [V36_Benchmarking](V36_Benchmarking/) | Benchmarking rigoureux (HPL, IOR, etc.) | Doctorat | 🔜 Squelette |
| V37 | [V37_Reproductibilite](V37_Reproductibilite/) | Reproductibilité et open science | Doctorat | 🔜 Squelette |
| V38 | [V38_Zero_Trust_Gouvernance](V38_Zero_Trust_Gouvernance/) | Sécurité avancée (Zero Trust, gouvernance) | Doctorat | 🔜 Squelette |
| V39 | [V39_SRE_Operations_HPC](V39_SRE_Operations_HPC/) | SRE et opérations HPC | Doctorat | 🔜 Squelette |
| V40 | [V40_Synthese_Doctorat](V40_Synthese_Doctorat/) | Thème libre / synthèse Doctorat | Doctorat | 🔜 Squelette |

---

## Objectif 400–800 pages par volume

Chaque volume vise **400 à 800 pages** (1 page ≈ 300–400 mots). Convention, gabarits et checklist : [CIBLE_400_800_PAGES.md](../editorial/CIBLE_400_800_PAGES.md).

**État actuel** : **structure + contenu partiel**. Aucun volume n’atteint encore 400–800 pp. La rédaction se fait **chapitre par chapitre** à pleine longueur (~20–35 pp/chapitre, labs 10–30 pp) selon la convention.

## Méthode de progression

- **V01** : 20 chapitres (ch01–ch09 en version courte à étendre ; ch10–ch20 en **squelette complet** : objectifs, prérequis, plan détaillé, TODOs, exercices 3 niveaux, validation, références). Rédaction incrémentale : étendre ch1–9 puis rédiger ch10–20 (voir [ROADMAP](../editorial/ROADMAP.md) — prochaines étapes V01).
- **V02–V40** : squelette (book.md). Contenu à rédiger **volume par volume**, chapitre par chapitre, selon [ROADMAP](../editorial/ROADMAP.md) et [CIBLE_400_800_PAGES](../editorial/CIBLE_400_800_PAGES.md).

## Références

- [SOURCE_INDEX](../editorial/SOURCE_INDEX.md) — sources du dépôt
- [STYLE_GUIDE](../editorial/STYLE_GUIDE.md) — conventions de rédaction
- [ROADMAP](../editorial/ROADMAP.md) — jalons et lots
