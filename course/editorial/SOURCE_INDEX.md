# SOURCE_INDEX — Inventaire des sources du dépôt

**Objectif** : Indexer la documentation et les artefacts du dépôt pour alimenter la collection de cours (40 volumes). Toute affirmation factuelle doit être traçable à un fichier listé ici ou marquée « source externe / hypothèse ».

---

## 1. Racine et scripts principaux

| Fichier | Couverture | Remarques |
|---------|------------|-----------|
| `README.md` | Vue d’ensemble, prérequis, mode démo/prod, openSUSE 15.6, Makefile | Référence principale |
| `GUIDE_DEMARRAGE_RAPIDE.md` | LDAP/Kerberos vs FreeIPA, installation rapide | Scripts auth |
| `INSTALLATION_OPENSUSE15.md` | Installation openSUSE, mode LAB/PROD | Aligné 15.6 |
| `CHANGELOG.md` | Historique des versions | À aligner avec releases/tags |
| `install-all.sh` | Orchestration installation (INSTALL.sh, auth, apps, monitoring, sécurité) | Point d’entrée bare-metal |
| `Makefile` | up-demo, up-prod, down, health, build, check-env-prod, lint | Déploiement Docker |
| `.env.example` | Variables d’environnement (HPC_MODE, Grafana, InfluxDB) | Pas de secrets en clair |
| `scripts/INSTALL.sh` | Installation détaillée par composant | |
| `scripts/check-env-prod.sh` | Validation variables prod (HPC_MODE=prod) | |

---

## 2. Docker et configuration

| Fichier | Couverture | Remarques |
|---------|------------|-----------|
| `docker/docker-compose-opensource.yml` | Stack complète : frontaux, compute, Prometheus, Grafana, InfluxDB, Loki, Promtail, JupyterHub | Déploiement principal |
| `docker/docker-compose.prod.yml` | Override prod, healthchecks, logging ; deploy.resources (Swarm) | Documenté |
| `docker/frontal/Dockerfile` | Image frontal openSUSE Leap 15.6, systemd, SSH, Node Exporter, Telegraf | |
| `docker/client/Dockerfile` | Image compute (slave) openSUSE Leap 15.6, SlurmD, exporters | |
| `configs/slurm/slurm.conf` | Partitions normal/gpu, nœuds compute-01…06, frontal-01/02 | Noms alignés Docker |
| `configs/prometheus/`, `configs/grafana/`, `configs/loki/`, `configs/promtail/`, `configs/jupyterhub/` | Configurations monitoring et JupyterHub | |

---

## 3. Wiki (.github/wiki)

| Fichier | Couverture | Remarques |
|---------|------------|-----------|
| `Home.md` | Accueil, quick start, architecture, liens | |
| `Quickstart-DEMO.md` | Démo 30 min, Docker, .env, vérifications | Nouveau |
| `Checklist-PROD.md` | Secrets, hardening, sauvegardes, upgrade/rollback | Nouveau |
| `Status-Scope.md` | Tableau ✅/🟡/🔜/❌ implémenté | Nouveau |
| `Installation-Rapide.md` | Prérequis, 3 étapes, Docker vs bare-metal | |
| `Depannage.md` | Diagnostic, services, métriques, sécurité | |
| `Troubleshooting.md` | 10 cas réels + commandes Docker | Nouveau |
| `FAQ.md`, `Configuration-de-Base.md`, `Commandes-Utiles.md` | Référence | |
| `Guide-SLURM-Complet.md` | Partitions, QoS, sbatch, srun | |
| `Manuel-Architecture-HPC-Volume1.md` … `Volume9.md` | Cours 9 volumes (~620–720 p.) | Formation |
| `Cours-HPC-Complet.md`, `Manuel-HPC-Sommaire-Complet.md` | Plan formation | |
| `Dictionnaire-Encyclopedique-HPC.md`, `Glossaire-et-Acronymes.md`, `hpc_annexes.md` | Lexique, annexes SRE | |

---

## 4. Documentation (docs/)

| Thème | Fichiers clés | Couverture |
|-------|----------------|------------|
| Installation | GUIDE_INSTALLATION_COMPLETE, INSTALLATION_HORS_LIGNE, GUIDE_DEPLOIEMENT_PRODUCTION | Procédures |
| Architecture | ARCHITECTURE, ARCHITECTURE_ET_CHOIX_CONCEPTION, ARCHITECTURE_DIAGRAMS | Conception |
| Sécurité | GUIDE_SECURITE_AVANCEE, SECURITE_NIVEAU_MAXIMUM, THREAT_MODEL | Hardening |
| Monitoring | GUIDE_MONITORING_COMPLET, GUIDE_MONITORING_DASHBOARDS_COMPLET, GUIDE_APM_MONITORING | Prometheus, Grafana |
| Auth | GUIDE_INSTALLATION_LDAP_KERBEROS, GUIDE_AUTHENTIFICATION_FREEIPA, TECHNOLOGIES_CLUSTER_FREEIPA | LDAP, Kerberos, FreeIPA |
| Maintenance | GUIDE_MAINTENANCE, GUIDE_MAINTENANCE_TOUS_LOGICIELS, GUIDE_MISE_A_JOUR_REPARATION | Opérations |
| Troubleshooting | GUIDE_TROUBLESHOOTING_*, RUNBOOK, DISASTER_RECOVERY | Incidents |
| Index | INDEX_DOCUMENTATION.md, INDEX_DOCUMENTATION_COMPLETE.md | Navigation |
| Audit | AUDIT_ETAPE0_CARTOGRAPHIE, PLAN_ACTIONS_HARDENING, LIVRABLES_AUDIT_HARDENING | Hardening lab/prod |

---

## 5. Scripts (scripts/)

| Catégorie | Exemples | Couverture |
|-----------|----------|------------|
| Auth | install-ldap-kerberos.sh, install-freeipa.sh | LDAP, Kerberos, FreeIPA |
| Monitoring / apps | install-monitoring.sh, install-applications.sh, install-slurm.sh | Composants |
| Vérification | check-env-prod.sh, verify-installation.sh (si présent), diagnostic.sh (si présent) | Validation |

---

## 6. Manques et incohérences identifiés

- **Scripts** : `diagnostic.sh`, `verify-installation.sh` cités dans le wiki ; à confirmer présence dans `scripts/`.
- **Podman** : FAQ mentionne `podman/install-podman.sh` ; à vérifier dans le dépôt.
- **Promesses** : Certains guides docs/ peuvent décrire des fonctionnalités non implémentées (ex. stockage Lustre/BeeGFS complet) ; à marquer « Planned » ou « Out of scope » dans le cours.
- **Cohérence** : Noms de nœuds = `frontal-01`, `frontal-02`, `compute-01` … `compute-06` (slurm.conf et Docker). À respecter dans tout le contenu généré.

---

## 7. Utilisation pour les volumes

- **V01–V14 (Licence)** : S’appuyer sur README, INSTALLATION_OPENSUSE15, scripts d’installation, Dockerfiles, slurm.conf pour les exemples « réels ».
- **V15–V30 (Master)** : docs/ (architecture, monitoring, sécurité), wiki (Manuels 1–9, Guide SLURM), configs/.
- **V31–V40 (Doctorat)** : docs avancés (SLA_SLO, RUNBOOK, DISASTER_RECOVERY), Dictionnaire encyclopédique, annexes SRE ; le reste en théorie / références externes sans inventer de features non présentes.

**Règle** : Si une feature n’est pas prouvée par un fichier du repo, la marquer « Planned » ou « Out-of-scope » dans le cours.
