# Plan d’actions priorisé — Hardening LAB / PROD

## P0 — Bloquant / sécurité / cohérence

| # | Action | Détail |
|---|--------|--------|
| P0.1 | **Secrets** | Remplacer mots de passe en clair dans compose par variables d’environnement ; ajouter `.env.example` (valeurs DEMO) et garder `.env` dans `.gitignore`. |
| P0.2 | **Modes demo vs prod** | Deux profils ou deux fichiers compose (demo = root/password OK, documenté ; prod = pas de root SSH, secrets obligatoires). Documenter dans README. |
| P0.3 | **Cohérence Slurm** | Aligner `slurm.conf` sur les hostnames Docker : `compute-01`…`compute-06` (au lieu de `slave-01`…`slave-06`). |
| P0.4 | **Compose prod non trompeur** | Documenter que `deploy.resources` dans `docker-compose.prod.yml` est pris en compte uniquement avec Docker Swarm ; ajouter commentaire en tête du fichier + ligne dans README. |

## P1 — Qualité / DX / fiabilité

| # | Action | Détail |
|---|--------|--------|
| P1.1 | **Hygiène repo** | Supprimer `FETCH_HEAD` du suivi si présent ; confirmer `.gitignore` (déjà fait). |
| P1.2 | **Docs installation** | Dans `INSTALLATION_OPENSUSE15.md`, ajouter une note « Mode LAB (démo) vs PROD » et référence à `.env.example`. |
| P1.3 | **CHANGELOG** | Vérifier/ajuster les liens de comparaison et de tags ; si pas de releases publiées, ajouter une section « Comment couper une release » dans la doc. |
| P1.4 | **Validation démarrage** | Script ou procédure : en mode prod, vérifier que les variables requises sont définies (pas de défaut démo) ; erreur claire sinon. |

## P2 — Bonus

| # | Action | Détail |
|---|--------|--------|
| P2.1 | **Makefile** | Cibles `up-demo`, `up-prod`, `down`, `lint`, `health`. |
| P2.2 | **CI lint** | Workflow GitHub Actions : shellcheck, yamllint, hadolint (optionnel sur cette PR). |
| P2.3 | **README** | Section « Quickstart démo » + « Prod hardening checklist ». |

---

## Ordre d’exécution (commits suggérés)

1. **Commit 1 (P0.1)** : `.env.example`, compose utilise variables, `.env` ignoré.
2. **Commit 2 (P0.2)** : Fichier compose dédié prod (ou profil) + doc demo/prod dans README.
3. **Commit 3 (P0.3)** : `slurm.conf` : slave-XX → compute-XX + section vérification Slurm en doc.
4. **Commit 4 (P0.4)** : Commentaire + doc sur `deploy.resources` (Swarm only).
5. **Commit 5 (P1.1)** : Retrait `FETCH_HEAD` du suivi si présent.
6. **Commit 6 (P1.2–P1.4)** : Notes INSTALLATION_OPENSUSE15, validation prod, CHANGELOG si besoin.
7. **Commit 7 (P2)** : Makefile + README quickstart/checklist (optionnel dans la même branche).
