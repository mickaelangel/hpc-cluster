# Status / Scope — Alignement doc ↔ implémenté

> Tableau d’état des fonctionnalités **réellement** présentes dans le dépôt (configs, scripts, Docker).  
> **Légende** : ✅ Implémenté et documenté · 🟡 Partiel / optionnel · 🔜 Prévu / en cours · ❌ Non implémenté

---

## Sommaire

1. [Stack principale](#stack-principale)
2. [Nœuds et Slurm](#nœuds-et-slurm)
3. [Monitoring et observabilité](#monitoring-et-observabilité)
4. [Authentification et sécurité](#authentification-et-sécurité)
5. [Applications et outils](#applications-et-outils)
6. [Documentation et formation](#documentation-et-formation)

---

## Stack principale

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| Déploiement Docker (compose) | ✅ | `docker-compose-opensource.yml` : 2 frontaux + 6 compute + monitoring + JupyterHub |
| Override “prod” (compose) | ✅ | `docker-compose.prod.yml` (healthchecks, logging ; `deploy.resources` effectif en Swarm uniquement) |
| Mode démo (identifiants documentés) | ✅ | `.env.example`, défauts dans compose, README |
| Mode prod (secrets obligatoires) | ✅ | `scripts/check-env-prod.sh`, doc Checklist-PROD |
| openSUSE Leap 15.6 (images de base) | ✅ | Dockerfiles frontal/client basés sur Leap 15.6 |
| Makefile (up-demo, up-prod, health, down) | ✅ | Racine du projet |

---

## Nœuds et Slurm

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| Nœuds frontaux (frontal-01, frontal-02) | ✅ | Hostnames et IP dans compose et slurm.conf |
| Nœuds de calcul (compute-01 … compute-06) | ✅ | Hostnames alignés entre Docker et `configs/slurm/slurm.conf` |
| Partitions Slurm (normal, gpu) | ✅ | `compute-[01-06]`, `compute-[01-02]` pour gpu |
| Slurm dans les conteneurs | 🟡 | Config montée ; slurmctld/slurmd à configurer dans les images/entrypoints selon besoin |
| Munge / auth Slurm | 🟡 | Référencé dans slurm.conf ; setup manuel ou script dédié |

---

## Monitoring et observabilité

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| Prometheus | ✅ | Image officielle, config dans `configs/prometheus` |
| Grafana | ✅ | Image officielle, dashboards dans `grafana-dashboards`, provisioning |
| InfluxDB 2 | ✅ | Image officielle, init via variables d’env |
| Loki | ✅ | Image officielle, config dans `configs/loki` |
| Promtail | ✅ | Image officielle, config dans `configs/promtail` |
| Node Exporter / Telegraf (dans frontaux/compute) | ✅ | Dockerfiles frontal/client |
| Slurm exporter | 🟡 | Référencé en config ; service dédié à vérifier dans le repo |
| Alertmanager | 🔜 | Mentionné en config ; déploiement à confirmer |

---

## Authentification et sécurité

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| SSH (root + mot de passe) en démo | ✅ | Dockerfiles : documenté pour LAB uniquement |
| Secrets via .env (pas en clair dans le repo) | ✅ | .env.example, compose utilise variables |
| FreeIPA (script) | ✅ | `scripts/install-freeipa.sh` |
| LDAP + Kerberos (scripts) | ✅ | `scripts/install-ldap-kerberos.sh` |
| Désactivation root SSH / clés en prod | 🟡 | Documenté ; à appliquer manuellement (hardening) |

---

## Applications et outils

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| JupyterHub | ✅ | Service dans compose, config dans `configs/jupyterhub` |
| Scripts d’installation (Slurm, apps, monitoring, etc.) | ✅ | Nombreux sous `scripts/` ; à utiliser selon besoin |
| install-all.sh (orchestration) | ✅ | Lance INSTALL.sh + auth + apps + monitoring + sécurité |
| BeeGFS / Lustre / Ceph (stockage) | 🟡 | Scripts ou docs ; pas de stack complète dans le compose par défaut |

---

## Documentation et formation

| Composant | Status | Commentaire |
|-----------|--------|-------------|
| Wiki (.github/wiki) | ✅ | Home, FAQ, Installation-Rapide, Manuels, Cours, Glossaire, Dictionnaire, Annexes |
| Quickstart DEMO (30 min) | ✅ | Page [Quickstart-DEMO](Quickstart-DEMO) |
| Checklist PROD | ✅ | Page [Checklist-PROD](Checklist-PROD) |
| Status / Scope (cette page) | ✅ | Alignement doc ↔ repo |
| Guides docs/ (installation, sécurité, monitoring, etc.) | ✅ | Nombreux guides ; cohérence openSUSE 15.6 et noms de nœuds à maintenir |
| Manuels 9 volumes + Cours HPC | ✅ | Contenu formation ; certains sujets génériques (non limités au repo) |

---

**Mise à jour** : 2025. En cas de doute sur une fonctionnalité, vérifier dans le dépôt (configs, scripts, compose) avant de marquer ✅.
