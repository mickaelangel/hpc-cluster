# ÉTAPE 0 — Cartographie et synthèse (audit hardening LAB/PROD)

**Date** : 2025  
**Objectif** : Auditer le dépôt hpc-cluster pour mode LAB (démo) + PROD (durci).

---

## 1. Composants clés identifiés

| Composant | Emplacement | Rôle |
|-----------|-------------|------|
| **README** | `README.md` | Vue d’ensemble, prérequis, installation, doc |
| **Install master** | `install-all.sh` | Orchestration complète (Docker, auth, apps, monitoring, sécurité) |
| **Install base** | `scripts/INSTALL.sh` | Build + up du compose opensource uniquement |
| **Compose démo** | `docker/docker-compose-opensource.yml` | 2 frontaux + 6 compute + Prometheus, Grafana, InfluxDB, Loki, JupyterHub, Promtail |
| **Compose prod** | `docker/docker-compose.prod.yml` | Override : deploy/resources, logging, healthchecks, labels (Swarm) |
| **Slurm** | `configs/slurm/slurm.conf` | ControlMachine=frontal-01, nodes slave-01..06 |
| **Dockerfiles** | `docker/frontal/Dockerfile`, `docker/client/Dockerfile` | openSUSE 15.6, SSH root + chpasswd, Node Exporter, Telegraf |
| **Docs** | `docs/INDEX_DOCUMENTATION_COMPLETE.md`, `INSTALLATION_OPENSUSE15.md` | Index doc, installation openSUSE 15.6 |
| **CHANGELOG** | `CHANGELOG.md` | [Unreleased], v2.0.0, v1.0.0 (liens compare/tag) |

---

## 2. Synthèse : risques / incohérences / quick wins (15 points)

### Risques / sécurité (P0)

1. **Secrets en clair dans le compose**  
   `docker-compose-opensource.yml` : `GF_SECURITY_ADMIN_PASSWORD=$Password!2026`, `DOCKER_INFLUXDB_INIT_PASSWORD=admin1234`. À remplacer par variables d’environnement + `.env.example`.

2. **Mot de passe root SSH dans les Dockerfiles**  
   `echo "root:hpc-demo-2024" | chpasswd` en dur dans frontal et client. En prod, pas de root SSH ; en démo, garder explicite et documenté.

3. **Docs et scripts avec mots de passe par défaut**  
   Nombreux exemples (DSPassword123!, AdminPassword123!, etc.) dans docs et scripts. Les scripts utilisent déjà des variables d’env avec défaut ; le compose et les Dockerfiles doivent suivre la même logique (env + .env.example).

4. **Incohérence Slurm vs Docker**  
   `slurm.conf` : `NodeName=slave-01` … `slave-06` ; Docker : `hostname: compute-01` … `compute-06`. Slurm ne verra pas les nœuds. **Quick win** : aligner Slurm sur `compute-01`…`compute-06`.

### Incohérences / qualité (P1)

5. **Compose prod : `deploy.resources` ignoré hors Swarm**  
   En `docker compose` (sans Swarm), les blocs `deploy.resources` sont ignorés. Fausse impression de limites. À documenter clairement ou à compléter avec des limites compatibles standalone si besoin.

6. **Référence Grafana incohérente**  
   `install-all.sh` affiche « admin / demo-hpc-2024 » ; compose utilise `$Password!2026`. À unifier via .env (démo = valeur d’exemple dans .env.example).

7. **Fichier artefact `FETCH_HEAD`**  
   Présent sur GitHub (fichier interne Git). Déjà dans `.gitignore` ; à retirer du dépôt si encore suivi (`git rm --cached`).

8. **INSTALL.sh depuis install-all.sh**  
   `scripts/INSTALL.sh` attend d’être lancé depuis la racine du projet (chemins `docker/...`). install-all.sh fait `cd "$SCRIPT_DIR"` (racine) puis `bash scripts/INSTALL.sh` → OK. Pas de changement requis.

### Documentation / hygiène (P1)

9. **INSTALLATION_OPENSUSE15.md**  
   Déjà aligné sur openSUSE Leap 15.6. Ajouter une note « LAB vs PROD » et référence vers .env.example.

10. **CHANGELOG / releases**  
    Liens `compare/v2.0.0`, `releases/tag/v1.0.0`. Si les tags n’existent pas sur le dépôt, les liens sont cassés. Vérifier et soit créer les tags, soit adapter le CHANGELOG.

11. **Pas de .env.example**  
    Aucun fichier committé listant les variables attendues (Grafana, InfluxDB, mode demo/prod). À créer.

### Quick wins

12. **Profils ou fichiers compose demo/prod**  
    Soit Docker Compose profiles (`demo` / `prod`), soit deux fichiers (ex. `docker-compose.demo.yml` + override prod). Permet de distinguer clairement LAB et PROD.

13. **Validation au démarrage**  
    Script ou section dans README : en mode prod, exiger les variables (pas de défaut démo) et refuser de lancer si absentes.

14. **Section vérification Slurm**  
    Dans README ou `docs/` : commandes `scontrol show nodes`, `sinfo`, `squeue` et résultat attendu après correction des noms de nœuds.

15. **Makefile ou scripts up/down/lint/health**  
    `make up-demo`, `make up-prod`, `make down`, `make lint`, `make health` pour améliorer la DX (P2).

---

## 3. Artefacts / fichiers à ne pas versionner

- **FETCH_HEAD** : déjà dans `.gitignore`. À supprimer du suivi Git si présent dans l’arbre.
- **.env** : déjà ignoré. Ne doit contenir que des secrets locaux ; template dans `.env.example`.

---

## 4. Prochaines étapes

- **ÉTAPE 1** : Plan d’actions P0 / P1 / P2.
- **ÉTAPE 2** : Branche `hardening-lab-prod-split` et commits par thème (secrets, Slurm, compose prod, hygiène, docs).
- **ÉTAPE 3** : Checklist de validation, texte de PR, issues restantes.
