# Wiki - Cluster HPC Enterprise

> **Documentation collaborative professionnelle - Niveau DevOps Senior**

---

## 🎯 Bienvenue

Ce Wiki contient la documentation collaborative pour le **Cluster HPC Enterprise**, une infrastructure HPC complète, 100% open-source, prête pour la production.

**Niveau** : DevOps Senior / Architecte  
**Public** : Administrateurs système, DevOps, Architectes HPC, **étudiants Master Data Science / Doctorat**

---

## 📚 Formation HPC — Cours complet & Glossaire

### 🎓 Parcours formation (niveau Master / Doctorat)

- **[Cours HPC Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Cours-HPC-Complet.md)** — Formation exhaustive : concepts HPC, architecture des clusters, parallélisme (MPI, OpenMP), stockage (Lustre, BeeGFS, Ceph), GPU, conteneurs, sécurité et monitoring. Idéal pour tout savoir sur les technologies et le fonctionnement des clusters.
- **[Sommaire complet du Manuel HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md)** — Plan des 9 volumes (~620–720 p.), tous les chapitres, labs, études de cas, annexes.
- **[Manuel Architecture & Ingénierie HPC — Vol. 1](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume1.md)** — Fondations, co-design, 3 architectures types (CPU-only, GPU, Data-Intensive), OOB (BMC, IPMI, Redfish), provisioning bare-metal (PXE, Warewulf v4), Ansible, lab et examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 2](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume2.md)** — Réseaux datacenter (Spine-Leaf, MLAG, Jumbo Frames), InfiniBand & RoCE v2 (RDMA, OpenSM), sécurité (IAM/FreeIPA, Bastion, hardening), lab SSSD/NFS et examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 3](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume3.md)** — Stockage parallèle : POSIX, tiering (scratch/project/archive), Lustre (MGS, MDS/MDT, OSS/OST, LNet, DNE), striping, BeeGFS/GPFS/CephFS, lab mini-Lustre et examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 4](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume4.md)** — Ordonnancement : Backfill, Fairshare, architecture Slurm (slurmctld, slurmd, slurmdbd), MUNGE, cgroups, GRES GPU, troubleshooting, labs Slurm/Fairshare/cgroups et examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 5](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume5.md)** — Toolchains : Lmod, Spack, Apptainer ; MPI (Eager/Rendezvous, binding NUMA, UCX) ; GPU et IA (NCCL, GPUDirect RDMA, Slurm) ; labs Spack/OMB et Apptainer/PyTorch, examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 6](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume6.md)** — Performances : NUMA, numactl, Hugepages/TLB, modèle Roofline, perf, HPL/HPCG, IOR/mdtest, labs STREAM et profiling cache, examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 7](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume7.md)** — Observabilité & SRE : Pull vs Push, exporters (Slurm/Lustre/GPU), capacity planning, SLO/SLA, runbooks, post-mortems blameless, MTTR, lab Prometheus+Slurm, examen.
- **[Manuel Architecture & Ingénierie HPC — Vol. 8](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume8.md)** — Fil rouge : 5 phases (design → bare-metal → stockage → Slurm → observabilité), Go-Live, Exascale/DLC, convergence IA-HPC, Cloud Bursting, Data Gravity, lab architecture WRF, examen final.
- **[Manuel Architecture & Ingénierie HPC — Vol. 9](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-Architecture-HPC-Volume9.md)** — Data Science & ML sur cluster : data locality, I/O/formats, PyTorch DDP multi-nœuds (NCCL), job arrays/Submitit/Optuna, reproductibilité et MLOps on-prem, labs 12 & 13.
- **[Guide SLURM Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-SLURM-Complet.md)** — Scheduler en détail : partitions, QoS, soumission (sbatch, srun), file d’attente, bonnes pratiques, intégration MPI/GPU.
- **[Glossaire et Acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** — Dictionnaire des acronymes (HPC, MPI, SLURM, PBS, Lustre, etc.) et définitions des termes (cluster, allocation, fair-share, walltime, etc.). Référence pour étudiants et professionnels.
- **[Dictionnaire encyclopédique HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Dictionnaire-Encyclopedique-HPC.md)** — Entrées encyclopédiques (Backfill, GPUDirect RDMA, NUMA, Fairshare, RDMA, Striping, DLM, Hugepages, OOM-Killer) : définition rigoureuse, internals, bonnes pratiques, tuning, troubleshooting, références. Niveau Doctorat/Architecte.
- **[Annexes SRE & Cheatsheets HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/hpc_annexes.md)** — Annexe A : Slurm (scontrol, sacct, sdiag) ; B : Lustre (lfs, lctl, OST) ; C : perf, numactl, htop, iostat ; D : Post-Mortem Blameless (RCA).

---

## 📋 Navigation Rapide

### 🚀 Pour Démarrer

- **[Quickstart DEMO (30 min)](Quickstart-DEMO)** : Lancer le cluster en mode démo (Docker)
- **[Installation Rapide](Installation-Rapide)** : Installation en 5 minutes (Docker ou scripts)
- **[Configuration de Base](Configuration-de-Base)** : Configuration minimale fonctionnelle
- **[Premiers Pas](Premiers-Pas)** : Guide pour commencer
- **[Checklist PROD](Checklist-PROD)** : Hardening, secrets, sauvegardes, upgrade/rollback
- **[Status / Scope](Status-Scope)** : Tableau ✅/🟡/🔜/❌ — ce qui est implémenté dans le repo
- **[Troubleshooting (10 cas)](Troubleshooting)** : Cas réels + commandes + correctifs

### 📚 Documentation par Rôle

#### 👨‍💼 Administrateur Système
- **[Guide Administrateur](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-Administrateur.md)** : Administration complète
- **[Maintenance](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Maintenance.md)** : Maintenance et opérations
- **[Sécurité](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Securite.md)** : Sécurité avancée

#### 🔧 DevOps
- **[CI/CD](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/CI-CD.md)** : Pipelines et automatisation
- **[Infrastructure as Code](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Infrastructure-as-Code.md)** : Terraform, Ansible
- **[Monitoring](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Monitoring.md)** : Observabilité complète

#### 👥 Utilisateur
- **[Guide Utilisateur](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-Utilisateur.md)** : Utilisation du cluster
- **[Lancement de Jobs](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Lancement-de-Jobs.md)** : Comment lancer des jobs
- **[Applications Scientifiques](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Applications-Scientifiques.md)** : Utilisation des applications

### 🔍 Référence

- **[Glossaire et Acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** : Dictionnaire HPC et acronymes (SLURM, MPI, Lustre, etc.)
- **[FAQ](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/FAQ.md)** : Questions fréquentes
- **[Dépannage](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Depannage.md)** : Solutions aux problèmes courants
- **[Astuces](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Astuces.md)** : Trucs et optimisations
- **[Commandes Utiles](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Commandes-Utiles.md)** : Référence rapide

### 📊 Cas d'Usage

- **[Cas d'Usage](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Cas-d-Usage.md)** : Exemples d'utilisation
- **[Configurations Recommandées](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Configurations-Recommandees.md)** : Configurations par scénario
- **[Retours d'Expérience](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Retours-d-Experience.md)** : Partage d'expériences

---

## 🏗️ Architecture

### Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    Cluster HPC Enterprise                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │  Frontal-01  │  │  Frontal-02  │  (HA Master/Backup)     │
│  │  172.20.0.101│  │  172.20.0.102│                         │
│  └──────────────┘  └──────────────┘                         │
│                                                               │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  │Comp-01│ │Comp-02│ │Comp-03│ │Comp-04│ │Comp-05│ │Comp-06│ │
│  │.201  │ │.202  │ │.203  │ │.204  │ │.205  │ │.206  │      │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘      │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Stack Monitoring & Observability              │   │
│  │  Prometheus │ Grafana │ InfluxDB │ Loki │ Promtail   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Services Enterprise                            │   │
│  │  Slurm │ FreeIPA │ JupyterHub │ GitLab │ Kubernetes   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Composants Principaux

- **2 Nœuds Frontaux** : Haute disponibilité, authentification, accès utilisateurs
- **6 Nœuds de Calcul** : Exécution des jobs HPC
- **Monitoring** : Prometheus, Grafana, InfluxDB, Loki
- **Scheduler** : Slurm avec partitions, QoS, priorités
- **Stockage** : BeeGFS, Lustre, GlusterFS, Ceph
- **Authentification** : LDAP/Kerberos ou FreeIPA
- **Applications** : 27+ applications scientifiques

---

## 🚀 Quick Start

### Installation (démo Docker, ~30 min)

```bash
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster
cp .env.example .env   # optionnel pour personnaliser les secrets démo
make up-demo           # ou: docker compose -f docker/docker-compose-opensource.yml up -d
```

Pour installation complète (scripts bare-metal) : `sudo ./install-all.sh` (voir [Installation Rapide](Installation-Rapide)).

### Accès aux Services

- **Grafana** : http://localhost:3000 (utilisateur `admin` ; mot de passe : variable `GF_SECURITY_ADMIN_PASSWORD` dans `.env` ou valeur par défaut démo — voir [Quickstart DEMO](Quickstart-DEMO))
- **Prometheus** : http://localhost:9090
- **InfluxDB** : http://localhost:8086 (identifiants via variables d’environnement, voir `.env.example`)
- **JupyterHub** : http://localhost:8000

---

## 📚 Documentation Complète

### Documentation Principale

- **📖 [Index Documentation](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/INDEX_DOCUMENTATION.md)** : 80+ guides
- **📚 [Documentation Complète](https://github.com/mickaelangel/hpc-cluster/tree/main/docs)** : Tous les guides

### Guides par Thème

- **Installation** : [GUIDE_INSTALLATION_COMPLETE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_INSTALLATION_COMPLETE.md)
- **Sécurité** : [GUIDE_SECURITE_AVANCEE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_SECURITE_AVANCEE.md)
- **Monitoring** : [GUIDE_MONITORING_COMPLET.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_MONITORING_COMPLET.md)
- **CI/CD** : [GUIDE_CI_CD_COMPLET.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_CI_CD_COMPLET.md)

---

## 🔗 Liens Utiles

### Support

- **💬 [Discussions GitHub](https://github.com/mickaelangel/hpc-cluster/discussions)** : Poser des questions
- **🐛 [Signaler un Bug](https://github.com/mickaelangel/hpc-cluster/issues/new?template=bug_report.md)** : Créer une issue
- **✨ [Demander une Fonctionnalité](https://github.com/mickaelangel/hpc-cluster/issues/new?template=feature_request.md)** : Proposer une fonctionnalité

### Contribution

- **📝 [Guide Contribution](https://github.com/mickaelangel/hpc-cluster/blob/main/CONTRIBUTING.md)** : Comment contribuer
- **🔒 [Politique de Sécurité](https://github.com/mickaelangel/hpc-cluster/blob/main/SECURITY.md)** : Signaler une vulnérabilité

---

## 📊 Statistiques

- **📦 579 fichiers** de code et configuration
- **📚 93 guides** de documentation
- **🔧 258 scripts** d'installation/configuration
- **📊 54 dashboards** Grafana
- **💻 89,452+ lignes** de code

---

## 🎯 Objectifs du Wiki

Ce Wiki est maintenu par la communauté pour :
- ✅ **Formation** : cours HPC complet (Master/Doctorat), guide SLURM, glossaire et acronymes
- ✅ Partager des guides rapides
- ✅ Documenter des cas d'usage spécifiques
- ✅ Maintenir une FAQ à jour
- ✅ Partager des astuces et optimisations
- ✅ Faciliter l'onboarding (étudiants, chercheurs, DevOps)

---

## 📝 Comment Contribuer au Wiki

1. Cliquer sur **"Edit"** en haut de la page
2. Modifier le contenu en Markdown
3. Sauvegarder avec un message descriptif
4. Respecter le formatage existant

**Guide complet** : [docs/GUIDE_COMMUNAUTE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_COMMUNAUTE.md)

---

**Dernière mise à jour** : 2024  
**Maintenu par** : La communauté HPC
