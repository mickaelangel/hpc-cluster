# Wiki - Cluster HPC Enterprise

> **Documentation collaborative professionnelle - Niveau DevOps Senior**

---

## 🎯 Bienvenue

Ce Wiki contient la documentation collaborative pour le **Cluster HPC Enterprise**, une infrastructure HPC complète, 100% open-source, prête pour la production.

**Niveau** : DevOps Senior / Architecte  
**Public** : Administrateurs système, DevOps, Architectes HPC

---

## 📋 Navigation Rapide

### 🚀 Pour Démarrer

- **[Installation Rapide](Installation-Rapide)** : Installation en 5 minutes
- **[Configuration de Base](Configuration-de-Base)** : Configuration minimale fonctionnelle
- **[Premiers Pas](Premiers-Pas)** : Guide pour commencer

### 📚 Documentation par Rôle

#### 👨‍💼 Administrateur Système
- **[Guide Administrateur](Guide-Administrateur)** : Administration complète
- **[Maintenance](Maintenance)** : Maintenance et opérations
- **[Sécurité](Securite)** : Sécurité avancée

#### 🔧 DevOps
- **[CI/CD](CI-CD)** : Pipelines et automatisation
- **[Infrastructure as Code](Infrastructure-as-Code)** : Terraform, Ansible
- **[Monitoring](Monitoring)** : Observabilité complète

#### 👥 Utilisateur
- **[Guide Utilisateur](Guide-Utilisateur)** : Utilisation du cluster
- **[Lancement de Jobs](Lancement-de-Jobs)** : Comment lancer des jobs
- **[Applications Scientifiques](Applications-Scientifiques)** : Utilisation des applications

### 🔍 Référence

- **[FAQ](FAQ)** : Questions fréquentes
- **[Dépannage](Depannage)** : Solutions aux problèmes courants
- **[Astuces](Astuces)** : Trucs et optimisations
- **[Commandes Utiles](Commandes-Utiles)** : Référence rapide

### 📊 Cas d'Usage

- **[Cas d'Usage](Cas-d-Usage)** : Exemples d'utilisation
- **[Configurations Recommandées](Configurations-Recommandees)** : Configurations par scénario
- **[Retours d'Expérience](Retours-d-Experience)** : Partage d'expériences

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

### Installation en 3 Commandes

```bash
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster
sudo ./install-all.sh
```

### Accès aux Services

- **Grafana** : http://localhost:3000 (admin/admin123 - ⚠️ À changer)
- **Prometheus** : http://localhost:9090
- **InfluxDB** : http://localhost:8086
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
- ✅ Partager des guides rapides
- ✅ Documenter des cas d'usage spécifiques
- ✅ Maintenir une FAQ à jour
- ✅ Partager des astuces et optimisations
- ✅ Faciliter l'onboarding

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
