# ÉTAPE 3 — Livrables audit hardening LAB/PROD

## 1. Fichiers modifiés / ajoutés (par thème)

| Fichier | Action | Thème |
|---------|--------|--------|
| `.env.example` | **Créé** | P0 — Secrets : template avec valeurs DEMO et avertissement PROD |
| `docker/docker-compose-opensource.yml` | Modifié | P0 — Grafana et InfluxDB utilisent des variables d’environnement (défaut démo) |
| `configs/slurm/slurm.conf` | Modifié | P0 — Noms de nœuds `slave-01`…`slave-06` → `compute-01`…`compute-06` (alignement Docker) |
| `docker/docker-compose.prod.yml` | Modifié | P0 — Commentaire en tête : `deploy.resources` pris en compte uniquement avec Swarm |
| `scripts/check-env-prod.sh` | **Créé** | P0 — Vérification des variables requises en mode prod |
| `README.md` | Modifié | P0/P2 — Section « Mode démo vs prod », quickstart démo, checklist prod, vérification Slurm, commande compose prod corrigée |
| `install-all.sh` | Modifié | P0 — Message Grafana pointe vers .env / défaut |
| `scripts/INSTALL.sh` | Modifié | P0 — Idem message Grafana |
| `INSTALLATION_OPENSUSE15.md` | Modifié | P1 — Note « Mode LAB vs PROD » et référence .env.example |
| `Makefile` | **Créé** | P2 — Cibles `up-demo`, `up-prod`, `down`, `build`, `health`, `check-env-prod`, `lint` |
| `docs/AUDIT_ETAPE0_CARTOGRAPHIE.md` | **Créé** | Étape 0 — Cartographie et synthèse risques |
| `docs/PLAN_ACTIONS_HARDENING.md` | **Créé** | Plan P0/P1/P2 |
| `docs/LIVRABLES_AUDIT_HARDENING.md` | **Créé** | Ce fichier |

**Non modifié (déjà en place)** : `.gitignore` contient déjà `.env`, `FETCH_HEAD`, etc. Suppression de `FETCH_HEAD` du suivi Git : à faire manuellement si le fichier est encore suivi (`git rm --cached FETCH_HEAD`).

---

## 2. Checklist de validation (commandes à exécuter)

À lancer depuis la **racine du projet** (répertoire `cluster hpc`).

```bash
# 1. Copier le template d’environnement
cp .env.example .env

# 2. Mode démo — lancer la stack
make up-demo
# ou : docker compose -f docker/docker-compose-opensource.yml up -d

# 3. Vérifier la santé des services
make health
# Prometheus http://localhost:9090/-/healthy
# Grafana http://localhost:3000/api/health
# InfluxDB http://localhost:8086/health

# 4. Connexion Grafana (démo)
# URL : http://localhost:3000 — login: admin / demo-hpc-2024 (ou valeur de .env)

# 5. Mode prod — vérification des variables (doit échouer si .env vide ou démo)
HPC_MODE=prod bash scripts/check-env-prod.sh
# Remplir .env avec des secrets, puis relancer : doit afficher "Variables PROD requises présentes"

# 6. Arrêt
make down
```

**Slurm** (si les conteneurs frontaux ont Slurm configuré) :

```bash
docker exec -it hpc-frontal-01 bash -c 'scontrol show nodes 2>/dev/null || true'
# Doit lister compute-01…06 si Slurm est opérationnel.
```

---

## 3. Texte de PR (titre + description)

**Titre** : `Audit hardening : secrets via .env, Slurm aligné, mode demo vs prod`

**Description** :

- **Corrections**
  - Suppression des mots de passe en clair dans le compose : Grafana et InfluxDB passent par des variables d’environnement (défaut démo documenté).
  - Ajout de `.env.example` (valeurs DEMO) et rappel que `.env` ne doit pas être committé.
  - Alignement Slurm / Docker : `slurm.conf` utilise `compute-01`…`compute-06` comme les hostnames des conteneurs.
  - Clarification sur `docker-compose.prod.yml` : les blocs `deploy.resources` ne s’appliquent qu’avec Docker Swarm.
  - Script `scripts/check-env-prod.sh` pour exiger les variables en mode prod.
  - README : section « Mode démo vs prod », quickstart démo, checklist prod, vérification Slurm.
  - Makefile : `up-demo`, `up-prod`, `down`, `health`, `check-env-prod`, `lint`.

- **Risques**
  - Aucun secret en clair committé. Les Dockerfiles gardent un mot de passe root pour la démo (documenté) ; en prod, durcir SSH (clés, pas root) en dehors de cette PR.

- **Comment tester**
  - `cp .env.example .env && make up-demo && make health`.
  - Vérifier Grafana avec admin / demo-hpc-2024.
  - Tester `HPC_MODE=prod scripts/check-env-prod.sh` sans variables → erreur ; avec .env rempli → succès.

---

## 4. Issues GitHub suggérées (non traitées dans cette PR)

| Priorité | Titre | Description |
|----------|--------|-------------|
| P1 | Retirer `FETCH_HEAD` du dépôt s’il est encore suivi | Exécuter `git rm --cached FETCH_HEAD` et commiter. Déjà dans `.gitignore`. |
| P1 | CI lint (shellcheck, yamllint, hadolint) | Ajouter un workflow GitHub Actions pour lint des scripts, YAML et Dockerfiles. |
| P2 | Désactiver root SSH en mode prod dans les Dockerfiles | Profil ou build-arg pour ne pas configurer `PermitRootLogin yes` / chpasswd root en prod. |
| P2 | Tags / releases alignés avec CHANGELOG | Créer les tags `v1.0.0` / `v2.0.0` sur le dépôt si les liens du CHANGELOG doivent rester valides. |
| P2 | pre-commit (shellcheck, yamllint) | Fichier `.pre-commit-config.yaml` optionnel pour vérifications avant commit. |
