# Quickstart DEMO — 30 minutes

> **Objectif** : Lancer le cluster en mode **démo** (LAB) en environ 30 minutes.  
> **Public** : Test, formation, POC. **Ne pas utiliser en production.**

---

## Sommaire

1. [Prérequis](#prérequis)
2. [Installation en 3 étapes](#installation-en-3-étapes)
3. [Vérification](#vérification)
4. [Accès aux services](#accès-aux-services)
5. [Arrêt et nettoyage](#arrêt-et-nettoyage)

---

## Prérequis

- **OS** : openSUSE Leap 15.6 (recommandé), ou Ubuntu 22.04+ / Rocky 8+
- **Docker** et **Docker Compose** (v2) installés
- **Ressources** : 4+ CPU, 8 GB RAM, 50 GB disque
- **Réseau** : Ports 3000, 9090, 8086, 8000, 2222, 2223 libres

---

## Installation en 3 étapes

### 1. Cloner et préparer l’environnement

```bash
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster
```

Optionnel (pour personnaliser les identifiants démo) :

```bash
cp .env.example .env
# Éditer .env si besoin (sinon les valeurs par défaut démo sont utilisées)
```

### 2. Lancer la stack (mode démo)

**Option A — Makefile (depuis la racine du projet)** :

```bash
make up-demo
```

**Option B — Docker Compose** :

```bash
docker compose -f docker/docker-compose-opensource.yml up -d
```

La première fois, le build des images peut prendre 10–20 min.

### 3. Vérifier que les conteneurs tournent

```bash
docker ps
# ou
make health
```

Vous devez voir notamment : `hpc-prometheus`, `hpc-grafana`, `hpc-influxdb`, `hpc-frontal-01`, `hpc-frontal-02`, `hpc-compute-01` … `hpc-compute-06`, `hpc-jupyterhub`.

---

## Vérification

| Action | Commande |
|--------|----------|
| Santé Prometheus | `curl -s http://localhost:9090/-/healthy` |
| Santé Grafana | `curl -s http://localhost:3000/api/health` |
| Santé InfluxDB | `curl -s http://localhost:8086/health` |
| Liste des nœuds Slurm (depuis un frontal) | `docker exec -it hpc-frontal-01 scontrol show nodes 2>/dev/null \|\| echo "Slurm non configuré dans le conteneur"` |

---

## Accès aux services

| Service | URL | Identifiants (DÉMO — à ne pas utiliser en prod) |
|---------|-----|--------------------------------------------------|
| **Grafana** | http://localhost:3000 | `admin` / valeur de `GF_SECURITY_ADMIN_PASSWORD` dans `.env` ou défaut `demo-hpc-2024` |
| **Prometheus** | http://localhost:9090 | — |
| **InfluxDB** | http://localhost:8086 | `admin` / valeur de `DOCKER_INFLUXDB_INIT_PASSWORD` (défaut `admin1234`) |
| **JupyterHub** | http://localhost:8000 | Selon config (voir `configs/jupyterhub`) |
| **SSH frontal-01** | `ssh -p 2222 root@localhost` | `root` / `hpc-demo-2024` (voir Dockerfiles) |
| **SSH frontal-02** | `ssh -p 2223 root@localhost` | idem |

Les mots de passe par défaut sont documentés ici uniquement pour le mode **démo**. En production, utiliser [Checklist PROD](Checklist-PROD) et des secrets via `.env`.

---

## Arrêt et nettoyage

```bash
# Arrêt
make down
# ou
docker compose -f docker/docker-compose-opensource.yml down

# Suppression des volumes (optionnel)
docker compose -f docker/docker-compose-opensource.yml down -v
```

---

## Suite

- **Mode production** : [Checklist PROD](Checklist-PROD)
- **État des fonctionnalités** : [Status / Scope](Status-Scope)
- **Dépannage** : [Depannage](Depannage) et [Troubleshooting](Troubleshooting)
