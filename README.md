# 🚀 Cluster HPC Enterprise - Infrastructure Complète

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openSUSE](https://img.shields.io/badge/openSUSE-15.6-green.svg)](https://www.opensuse.org/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Open Source](https://img.shields.io/badge/Open%20Source-100%25-brightgreen.svg)](https://opensource.org/)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)](https://github.com/mickaelangel/hpc-cluster)

> **Infrastructure HPC complète, 100% open-source, prête pour déploiement en production sur openSUSE 15.6**

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation Rapide](#-installation-rapide)
- [Déploiement Production](#-déploiement-production)
- [Documentation](#-documentation) (Wiki, Sommaire, Cours, Dictionnaire)
- [Contribuer](#-contribuer)
- [Sécurité](#-sécurité)
- [Support](#-support)
- [License](#-license)

## 🎯 Vue d'ensemble

Ce projet fournit une **infrastructure HPC complète et professionnelle** pour le calcul haute performance, avec :

- ✅ **2 nœuds frontaux** (haute disponibilité)
- ✅ **6 nœuds de calcul** (scalable)
- ✅ **Stack de monitoring complet** (Prometheus, Grafana, InfluxDB, Loki)
- ✅ **Scheduler Slurm** (gestion de jobs)
- ✅ **Stockage distribué** (GlusterFS, BeeGFS, Ceph)
- ✅ **Authentification enterprise** (LDAP/Kerberos, FreeIPA)
- ✅ **Applications scientifiques** (27+ applications)
- ✅ **Big Data & ML** (Spark, TensorFlow, PyTorch)
- ✅ **CI/CD intégré** (GitLab CI, Jenkins, Tekton)
- ✅ **Sécurité niveau entreprise** (MFA, RBAC, Zero Trust)

### Statistiques

- 📦 **579 fichiers** de code et configuration
- 📚 **93 guides** de documentation
- 🔧 **258 scripts** d'installation/configuration
- 📊 **54 dashboards** Grafana
- 🚀 **300+ améliorations** implémentées
- 💻 **89,452+ lignes** de code

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Cluster HPC Enterprise                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │  Frontal-01  │  │  Frontal-02  │  (HA Master/Backup)     │
│  │  172.20.0.101│  │  172.20.0.102│                         │
│  └──────────────┘  └──────────────┘                         │
│                                                             │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  │Comp-01│ │Comp-02│ │Comp-03│ │Comp-04│ │Comp-05│ │Comp-06││
│  │.201  │ │.202  │ │.203  │ │.204  │ │.205  │ │.206  │      │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘      │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Stack Monitoring & Observability             │   │
│  │  Prometheus │ Grafana │ InfluxDB │ Loki │ Promtail   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Services Enterprise                          │   │
│  │  Slurm │ FreeIPA │ JupyterHub │ GitLab │ Kubernetes  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Réseaux

- **Management Network** (`172.20.0.0/24`) : Administration et monitoring
- **Cluster Network** (`10.0.0.0/24`) : Communication inter-nœuds HPC
- **Storage Network** (`10.10.10.0/24`) : Stockage distribué

## ✨ Fonctionnalités

### 🎯 Core HPC

- **Scheduler Slurm** : Gestion avancée de jobs avec partitions, QoS, priorités
- **Stockage parallèle** : BeeGFS, Lustre, GlusterFS, Ceph
- **MPI** : OpenMPI, Intel MPI, MPICH
- **Applications scientifiques** : GROMACS, OpenFOAM, Quantum ESPRESSO, LAMMPS, NAMD, CP2K, ABINIT, etc.

### 📊 Monitoring & Observability

- **Prometheus** : Collecte de métriques (15+ jours de rétention)
- **Grafana** : 54+ dashboards professionnels
- **InfluxDB** : Base de données temporelles
- **Loki + Promtail** : Centralisation des logs
- **Alerting** : Alertes Prometheus avec règles personnalisables

### 🔒 Sécurité Enterprise

- **Authentification** : LDAP/Kerberos ou FreeIPA
- **MFA** : Multi-Factor Authentication (TOTP, YubiKey)
- **RBAC** : Gestion granulaire des permissions
- **Zero Trust** : Architecture micro-segmentation
- **Compliance** : DISA STIG, CIS Level 2, ANSSI
- **Audit** : Traçabilité complète des actions

### 🤖 Automatisation & CI/CD

- **GitLab CI** : Pipeline CI/CD complet
- **Ansible AWX** : Configuration management
- **Terraform** : Infrastructure as Code
- **Kubernetes** : Orchestration de conteneurs
- **GitOps** : ArgoCD, Flux

### 📈 Big Data & Machine Learning

- **Apache Spark** : Traitement distribué
- **Hadoop** : Big Data stack
- **TensorFlow** : Deep Learning
- **PyTorch** : Deep Learning
- **JupyterHub** : Notebooks collaboratifs

## 📦 Prérequis

### Plateformes supportées

| Plateforme        | Déploiement complet      | Remarques |
|-------------------|--------------------------|------------|
| **openSUSE Leap 15.6** | ✅ Oui (recommandé) | Scripts, Docker, Ansible et docs ciblent openSUSE 15.6. |
| **Rocky Linux / RHEL / CentOS** | ⚠️ Partiel | Certains composants (ex. FreeIPA) et exemples doc ; le déploiement principal (scripts, images Docker, Ansible) est prévu pour openSUSE. |

Pour un déploiement « clé en main », utiliser **openSUSE Leap 15.6** sur l’hôte.

### Système

- **OS** : openSUSE Leap 15.6 (voir tableau ci‑dessus)
- **RAM** : Minimum 16GB (32GB+ recommandé)
- **Disque** : Minimum 50GB (100GB+ recommandé)
- **CPU** : 4+ cores (8+ recommandé)

### Logiciels

- **Docker** : 20.10+ (API 1.41+)
- **Docker Compose** : 1.29+ ou Docker Compose V2
- **Git** : 2.0+
- **Python** : 3.8+ (pour certains scripts)

## 🚀 Installation Rapide

### Option 1 : Installation Automatique (Recommandé)

```bash
# Cloner le dépôt
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster

# Installation complète
chmod +x install-all.sh
sudo ./install-all.sh
```

### Option 2 : Installation par Étapes

```bash
# 1. Base Docker
cd docker
docker-compose -f docker-compose-opensource.yml build
docker-compose -f docker-compose-opensource.yml up -d

# 2. Authentification
cd ..
sudo ./scripts/install-freeipa.sh
# OU
sudo ./scripts/install-ldap-kerberos.sh

# 3. Applications scientifiques
sudo ./scripts/applications/install-all-scientific-apps.sh

# 4. Monitoring
sudo ./scripts/automation/setup-all-monitoring.sh

# 5. Sécurité
sudo ./scripts/security/install-all-security.sh
```

### Option 3 : Déploiement Hors Ligne (Air-Gapped)

```bash
# Voir docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md
sudo ./scripts/deployment/export-hors-ligne-complet.sh
```

## 🏭 Déploiement Production

### Checklist Pré-Production

- [ ] Changer tous les mots de passe par défaut
- [ ] Configurer les certificats SSL/TLS
- [ ] Configurer le firewall
- [ ] Activer les sauvegardes automatiques
- [ ] Configurer le monitoring et alerting
- [ ] Tester la haute disponibilité
- [ ] Documenter les procédures opérationnelles
- [ ] Former l'équipe

### Configuration Production

```bash
# Utiliser la configuration production
docker-compose -f docker/docker-compose.prod.yml up -d

# Voir docs/GUIDE_DEPLOIEMENT_PRODUCTION.md
```

## 📚 Documentation

### Wiki, formation et référence (niveau Master / Doctorat)

Liens directs vers les fichiers du wiki (dossier `.github/wiki/` dans le dépôt) :

- **📘 [Wiki — Accueil](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** : Documentation collaborative du cluster (vue d’ensemble, navigation)
- **📑 [Sommaire du Manuel HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Manuel-HPC-Sommaire-Complet.md)** : Index des 8 volumes (~550–650 pages), chapitres, labs et études de cas
- **📖 [Cours HPC Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Cours-HPC-Complet.md)** : Formation exhaustive (concepts, architecture, parallélisme, stockage, GPU, conteneurs, sécurité, monitoring)
- **📕 [Dictionnaire encyclopédique HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Dictionnaire-Encyclopedique-HPC.md)** : Définitions rigoureuses, internals, bonnes pratiques (niveau Doctorat/Architecte)
- **🔤 [Glossaire et acronymes](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Glossaire-et-Acronymes.md)** : SLURM, MPI, Lustre, cluster, allocation, fair-share, etc.
- **📎 [Annexes SRE & Cheatsheets HPC](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/hpc_annexes.md)** : Annexe A Slurm (scontrol, sacct, sdiag) ; B Lustre (lfs, lctl, OST) ; C perf, numactl, htop, iostat ; D Post-Mortem Blameless (RCA).

*Tous les fichiers du wiki : [.github/wiki/](https://github.com/mickaelangel/hpc-cluster/tree/main/.github/wiki) · [Onglet Wiki du projet](https://github.com/mickaelangel/hpc-cluster/wiki) (si activé).*

### Documentation technique complète

- **📖 [Index Complet](docs/INDEX_DOCUMENTATION_COMPLETE.md)** : Navigation dans tous les guides
- **🚀 [Guide de Démarrage](docs/GUIDE_COMPLET_DEMARRAGE.md)** : Pour commencer
- **🏗️ [Architecture](docs/ARCHITECTURE_ET_CHOIX_CONCEPTION.md)** : Architecture détaillée
- **🔧 [Installation](docs/GUIDE_INSTALLATION_COMPLETE.md)** : Installation complète
- **👥 [Utilisateur](docs/GUIDE_UTILISATEUR.md)** : Guide utilisateur
- **👨‍💼 [Administrateur](docs/GUIDE_ADMINISTRATEUR.md)** : Guide administrateur
- **🔒 [Sécurité](docs/GUIDE_SECURITE_AVANCEE.md)** : Sécurité avancée
- **📊 [Monitoring](docs/GUIDE_MONITORING_COMPLET.md)** : Monitoring complet
- **🐛 [Troubleshooting](docs/GUIDE_TROUBLESHOOTING.md)** : Dépannage

### Documentation par Rôle

| Rôle | Guides |
|------|--------|
| **Débutant** | [Démarrage](docs/GUIDE_COMPLET_DEMARRAGE.md), [Technologies](docs/GUIDE_TECHNOLOGIES_EXPLIQUEES.md) |
| **Utilisateur** | [Utilisateur](docs/GUIDE_UTILISATEUR.md), [Jobs](docs/GUIDE_LANCEMENT_JOBS.md) |
| **Administrateur** | [Admin](docs/GUIDE_ADMINISTRATEUR.md), [Maintenance](docs/GUIDE_MAINTENANCE_COMPLETE.md) |
| **DevOps** | [CI/CD](docs/GUIDE_CI_CD_COMPLET.md), [Terraform](docs/GUIDE_TERRAFORM_IAC.md) |
| **Sécurité** | [Sécurité](docs/GUIDE_SECURITE_AVANCEE.md), [Compliance](docs/GUIDE_SUMA_CONFORMITE.md) |

## 🤝 Contribuer

Nous accueillons les contributions ! Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour les guidelines.

### Processus de Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 🔒 Sécurité

### Signaler une Vulnérabilité

Voir [SECURITY.md](SECURITY.md) pour les instructions de signalement.

**⚠️ Ne pas ouvrir d'issue publique pour les vulnérabilités de sécurité.**

### Bonnes Pratiques

- Changer tous les mots de passe par défaut
- Activer MFA pour tous les comptes administrateurs
- Configurer le firewall
- Mettre à jour régulièrement
- Auditer les logs régulièrement

## 📞 Support

### Documentation

- **📚 [Documentation Complète](docs/)** : 93 guides disponibles
- **🔍 [Troubleshooting](docs/GUIDE_TROUBLESHOOTING.md)** : Solutions aux problèmes courants
- **📖 [Index Documentation](docs/INDEX_DOCUMENTATION.md)** : Navigation dans tous les guides

### Signaler un Problème ou Demander une Fonctionnalité

- **🐛 [Signaler un Bug](https://github.com/mickaelangel/hpc-cluster/issues/new?template=bug_report.md)** : Créer une issue pour un bug
- **✨ [Demander une Fonctionnalité](https://github.com/mickaelangel/hpc-cluster/issues/new?template=feature_request.md)** : Proposer une nouvelle fonctionnalité
- **💬 [Voir toutes les Issues](https://github.com/mickaelangel/hpc-cluster/issues)** : Liste complète des issues

### Communauté et Aide

- **💬 [GitHub Discussions](https://github.com/mickaelangel/hpc-cluster/discussions)** : 
  - Poser des questions techniques
  - Partager des expériences d'utilisation
  - Demander de l'aide pour l'installation
  - Discuter des meilleures pratiques
  - [Créer une nouvelle discussion](https://github.com/mickaelangel/hpc-cluster/discussions/new)
  - [Guide Communauté](docs/GUIDE_COMMUNAUTE.md) : Comment utiliser les Discussions

- **📝 [Wiki du Projet](https://github.com/mickaelangel/hpc-cluster/wiki)** :
  - Documentation collaborative
  - Guides rapides (FAQ, Installation, Dépannage)
  - Astuces et trucs
  - Cas d'usage partagés
  - [Voir le Wiki](https://github.com/mickaelangel/hpc-cluster/wiki) ou [Créer une page](https://github.com/mickaelangel/hpc-cluster/wiki/_new)
  - [Guide Communauté](docs/GUIDE_COMMUNAUTE.md) : Comment contribuer au Wiki

## 📊 Roadmap

- [ ] Support Kubernetes natif
- [ ] Intégration OpenStack
- [ ] Support GPU (NVIDIA, AMD)
- [ ] Interface web d'administration
- [ ] API REST complète
- [ ] Support multi-cloud

## 📄 License

Ce projet est sous licence [Apache 2.0](LICENSE).

## 🙏 Remerciements

- **openSUSE** : Pour openSUSE
- **Communauté Open Source** : Pour tous les outils utilisés
- **Contributeurs** : Pour leurs contributions

## 📈 Statistiques du Projet

![GitHub stars](https://img.shields.io/github/stars/mickaelangel/hpc-cluster?style=social)
![GitHub forks](https://img.shields.io/github/forks/mickaelangel/hpc-cluster?style=social)
![GitHub issues](https://img.shields.io/github/issues/mickaelangel/hpc-cluster)
![GitHub pull requests](https://img.shields.io/github/issues-pr/mickaelangel/hpc-cluster)

---

**⭐ Si ce projet vous est utile, n'hésitez pas à lui donner une étoile !**

**Made with ❤️ by Mickael ANGEL - the HPC Team**
