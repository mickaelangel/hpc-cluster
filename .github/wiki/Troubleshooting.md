# Troubleshooting — 10 cas réels

> **Cas concrets** avec commandes de diagnostic, causes probables et correctifs.  
> Contexte : déploiement **Docker** (docker-compose) sur openSUSE Leap 15.6.

---

## Sommaire

1. [Conteneur ne démarre pas / Exit 1](#1-conteneur-ne-démarre-pas--exit-1)
2. [Grafana 502 / inaccessible](#2-grafana-502--inaccessible)
3. [Prometheus : targets down](#3-prometheus--targets-down)
4. [Slurm : nœuds en état DOWN ou UNKNOWN](#4-slurm--nœuds-en-état-down-ou-unknown)
5. [squeue : jobs bloqués (Reason: ReqNodeNotAvail)](#5-squeue--jobs-bloqués-reason-reqnodnotavail)
6. [InfluxDB : erreur d’authentification](#6-influxdb--erreur-dauthentification)
7. [Port déjà utilisé au démarrage du compose](#7-port-déjà-utilisé-au-démarrage-du-compose)
8. [Grafana : « Data source not found »](#8-grafana--data-source-not-found)
9. [Conteneurs frontaux/compute : pas de réseau entre eux](#9-conteneurs-frontauxcompute--pas-de-réseau-entre-eux)
10. [Mots de passe / .env ignorés](#10-mots-de-passe--env-ignorés)

---

## 1. Conteneur ne démarre pas / Exit 1

**Symptômes** : `docker ps -a` montre un conteneur en `Exited (1)`.

**Diagnostic** :

```bash
docker ps -a --filter "status=exited"
docker logs <nom_conteneur>   # ex: hpc-grafana, hpc-prometheus
docker compose -f docker/docker-compose-opensource.yml config
```

**Causes probables** :  
- Fichier de config monté invalide (YAML, JSON).  
- Variable d’environnement obligatoire manquante.  
- Permissions sur un volume (ex. `/var/lib/grafana`).  
- Image corrompue ou mauvaise version.

**Correctif** :  
Corriger le fichier de config ou les variables (`.env`), puis `docker compose ... up -d` ; si volume : `chown` adapté côté hôte ou recréer le volume.

---

## 2. Grafana 502 / inaccessible

**Symptômes** : http://localhost:3000 renvoie 502 Bad Gateway ou timeout.

**Diagnostic** :

```bash
docker ps | grep grafana
docker logs hpc-grafana 2>&1 | tail -50
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health
```

**Causes probables** :  
- Conteneur Grafana en crash loop (config `grafana.ini` ou plugin).  
- Reverse proxy (si utilisé) mal configuré.  
- Mémoire insuffisante sur l’hôte.

**Correctif** :  
Vérifier les logs pour erreur de config ; simplifier ou réinitialiser les datasources ; redémarrer : `docker restart hpc-grafana`.

---

## 3. Prometheus : targets down

**Symptômes** : Dans Prometheus (Status → Targets), des targets sont en **down**.

**Diagnostic** :

```bash
# Depuis l’hôte
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'

# Node Exporter (souvent sur les conteneurs frontaux/compute)
docker exec hpc-frontal-01 curl -s http://localhost:9100/metrics | head -5
```

**Causes probables** :  
- Scrape vers une IP/hostname non résolvable depuis le conteneur Prometheus (ex. `localhost` d’un autre conteneur).  
- Firewall interne au réseau Docker.  
- Service (ex. node_exporter) non démarré dans le conteneur cible.

**Correctif** :  
Dans `configs/prometheus/prometheus.yml`, utiliser les **noms de service** Docker (ex. `frontal-01:9100`) ou l’IP du réseau overlay ; vérifier que les exporters écoutent bien dans les conteneurs.

---

## 4. Slurm : nœuds en état DOWN ou UNKNOWN

**Symptômes** : `scontrol show nodes` ou `sinfo` affichent des nœuds en DOWN/UNKNOWN.

**Diagnostic** (depuis un conteneur frontal) :

```bash
docker exec -it hpc-frontal-01 bash
scontrol show nodes
sinfo -N -l
# Vérifier que slurmd tourne sur les compute
docker exec hpc-compute-01 systemctl status slurmd 2>/dev/null || true
```

**Causes probables** :  
- Noms dans `slurm.conf` différents des hostnames des conteneurs (doivent être **compute-01 … compute-06**, **frontal-01/02**).  
- `slurmd` non démarré sur les nœuds de calcul.  
- Réseau : slurmctld ne peut pas joindre les slurmd (ports 6818, 6817).  
- Munge : clés différentes entre frontal et compute.

**Correctif** :  
Vérifier `configs/slurm/slurm.conf` (NodeName = hostname des conteneurs) ; démarrer slurmd sur les compute ; vérifier connectivité et Munge (voir [Guide SLURM Complet](Guide-SLURM-Complet), [Depannage](Depannage)).

---

## 5. squeue : jobs bloqués (Reason: ReqNodeNotAvail)

**Symptômes** : Les jobs restent en file avec la raison `ReqNodeNotAvail` (ou `PartitionConfig`).

**Diagnostic** :

```bash
squeue -l
scontrol show job <job_id>
sinfo -s
scontrol show partition normal
```

**Causes probables** :  
- Partition sans nœuds valides (tous DOWN/IDLE+DRAIN).  
- Ressources demandées (GRES, CPU, mem) non disponibles.  
- Noms de nœuds dans la partition (`Nodes=compute-[01-06]`) incohérents avec les nœuds déclarés.

**Correctif** :  
Remettre les nœuds en état IDLE : `scontrol update nodename=compute-01 state=resume` ; vérifier que les nœuds existent et correspondent à la config (voir [Status-Scope](Status-Scope)).

---

## 6. InfluxDB : erreur d’authentification

**Symptômes** : Erreur 401 ou « unauthorized » lors de l’accès à l’API InfluxDB (ex. depuis Grafana ou Telegraf).

**Diagnostic** :

```bash
# Token / mot de passe définis au premier lancement (variables d’env)
docker exec hpc-influxdb env | grep DOCKER_INFLUXDB
# Tester l’API
curl -s -u admin:VOTRE_MOT_DE_PASSE http://localhost:8086/health
```

**Causes probables** :  
- Mot de passe ou token différent de celui configuré dans Grafana/Telegraf.  
- `.env` non chargé (variable `DOCKER_INFLUXDB_INIT_PASSWORD`).

**Correctif** :  
Utiliser le même mot de passe que dans `.env` pour les datasources ; en démo, valeur par défaut documentée dans [Quickstart-DEMO](Quickstart-DEMO). Ne pas mettre de secrets en clair dans la doc.

---

## 7. Port déjà utilisé au démarrage du compose

**Symptômes** : `Error: bind: address already in use` (ex. 3000, 9090, 8086).

**Diagnostic** :

```bash
# Windows (PowerShell)
netstat -ano | findstr :3000

# Linux / WSL
ss -tlnp | grep -E '3000|9090|8086'
lsof -i :3000
```

**Causes probables** :  
- Autre instance de Grafana/Prometheus/InfluxDB déjà en écoute.  
- Ancien conteneur non arrêté.

**Correctif** :  
Arrêter le processus ou l’autre stack : `docker compose down` ; ou modifier le mapping de ports dans `docker-compose-opensource.yml` (ex. `"3001:3000"` pour Grafana).

---

## 8. Grafana : « Data source not found »

**Symptômes** : Les dashboards Grafana n’affichent pas de données ; message « Data source not found » ou erreur de connexion.

**Diagnostic** :

```bash
# Prometheus doit être joignable depuis le conteneur Grafana
docker exec hpc-grafana wget -qO- http://prometheus:9090/-/healthy || true
# Ou nom du service exact dans votre compose
docker exec hpc-grafana wget -qO- http://hpc-prometheus:9090/-/healthy || true
```

**Causes probables** :  
- URL du datasource incorrecte : en Docker il faut utiliser le **nom de service** (ex. `http://hpc-prometheus:9090`), pas `localhost`.  
- Datasource non créé ou supprimé.

**Correctif** :  
Dans Grafana, Configuration → Data Sources → Prometheus : URL = `http://<service_prometheus>:9090` (nom du conteneur/service dans le même réseau Docker).

---

## 9. Conteneurs frontaux/compute : pas de réseau entre eux

**Symptômes** : Les conteneurs ne se pingent pas entre eux ; Slurm ou les exporters inaccessibles.

**Diagnostic** :

```bash
docker network ls
docker network inspect hpc-cluster_default 2>/dev/null || docker network inspect $(docker compose -f docker/docker-compose-opensource.yml ps -q 2>/dev/null | head -1 | xargs docker inspect --format '{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' 2>/dev/null)
docker exec hpc-frontal-01 ping -c 1 compute-01
```

**Causes probables** :  
- Conteneurs pas sur le même réseau Docker.  
- Compose lancé depuis un autre répertoire ou avec un préfixe de projet différent.

**Correctif** :  
Lancer tout avec le même fichier compose depuis la racine du projet ; vérifier `docker compose ... config` que tous les services sont dans le même network.

---

## 10. Mots de passe / .env ignorés

**Symptômes** : Grafana ou InfluxDB utilisent un mot de passe différent de celui dans `.env`.

**Diagnostic** :

```bash
# Vérifier que le fichier est lu
docker compose -f docker/docker-compose-opensource.yml config | grep -A2 GF_SECURITY
# Le fichier .env doit être à côté du fichier compose ou dans le répertoire courant
ls -la .env
```

**Causes probables** :  
- `.env` absent ou pas dans le répertoire depuis lequel `docker compose` est exécuté.  
- Variable mal nommée (typo).  
- Premier lancement d’InfluxDB : le mot de passe est fixé à l’init ; changer ensuite nécessite de recréer le volume ou de reconfigurer InfluxDB.

**Correctif** :  
Copier `.env.example` en `.env`, le placer au bon endroit, et relancer : `docker compose down -v` (attention : -v supprime les volumes) puis `up -d` si besoin de réinitialiser InfluxDB.

---

## Voir aussi

- [Depannage](Depannage) — Guide de dépannage complet (services systemd et généraux)
- [Quickstart DEMO](Quickstart-DEMO) — Commandes de vérification rapide
- [Checklist PROD](Checklist-PROD) — Secrets et bonnes pratiques
- [Status / Scope](Status-Scope) — Ce qui est implémenté dans le repo
