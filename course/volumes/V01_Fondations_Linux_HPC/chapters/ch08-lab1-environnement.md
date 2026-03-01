# Chapitre 8 — Lab 1 : Environnement de travail

**Objectif** : Mettre en place l’environnement de travail et se repérer dans le projet hpc-cluster.  
**Prérequis** : Chapitres 1–2. **Durée** : 30–45 min.

---

## 8.1 Objectifs du lab

- Ouvrir un terminal et se connecter en SSH (ou utiliser le terminal local si vous clonez le repo en local).
- Cloner le dépôt hpc-cluster (ou utiliser une copie existante).
- Repérer les répertoires clés : `docker/`, `configs/`, `scripts/`, `docs/`, `.github/wiki/`.

---

## 8.2 Étapes

1. **Cloner le dépôt** (si besoin) :
   ```bash
   git clone https://github.com/mickaelangel/hpc-cluster.git
   cd hpc-cluster
   ```

2. **Lister la structure** :
   ```bash
   ls -la
   ls docker configs scripts docs .github/wiki 2>/dev/null || true
   ```

3. **Vérifier les fichiers principaux** :
   - `README.md` — vue d’ensemble
   - `Makefile` — cibles `up-demo`, `down`, `health`
   - `docker/docker-compose-opensource.yml` — stack Docker
   - `configs/slurm/slurm.conf` — noms des nœuds (compute-01 … compute-06, frontal-01, frontal-02)

4. **Optionnel** : Lancer le cluster en mode démo (`make up-demo` ou `docker compose -f docker/docker-compose-opensource.yml up -d`) et vérifier avec `docker ps`.

---

## 8.3 Critères de validation

- Vous avez accès au répertoire du projet.
- Vous pouvez citer le rôle d’au moins 3 répertoires (docker, configs, scripts).
- Vous savez où se trouve la configuration Slurm et les noms des nœuds.
