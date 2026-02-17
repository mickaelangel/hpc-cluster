# Installation depuis clé USB – SUSE 15 SP4 hors ligne

Ce document décrit comment copier le cluster HPC sur une clé USB et l’installer sur un serveur **SUSE 15 SP4** sans accès Internet.

---

## 1. Ce qui est livré (démo prête)

- **Architecture** : 2 frontaux + 6 nœuds de calcul (Docker) + services (Prometheus, Grafana, JupyterHub, etc.)
- **Sur l’hôte** (SUSE) : Slurm (slurmctld + slurmd), GlusterFS (glusterd + volume `gv_hpc`), FreeIPA (conteneur Docker), Munge
- **Dans Docker** : frontal-01, frontal-02, compute-01 à compute-06, Prometheus, Grafana, InfluxDB, Loki, JupyterHub, Promtail
- **Tout est installé et fonctionnel** pour la démo (voir `DEMO.md`).

---

## 2. Créer l’archive (machine source, une fois)

Sur la machine où se trouve le projet :

```bash
cd "/chemin/vers/hpc docker"
tar -czf cluster-hpc-suse15sp4-$(date +%Y%m%d).tar.gz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.env' \
  "cluster hpc"
```

Copier le fichier `cluster-hpc-suse15sp4-YYYYMMDD.tar.gz` sur la clé USB.

---

## 3. Export complet avec images Docker (hors ligne total)

Si le serveur cible n’aura **aucun** accès Internet, il faut embarquer les images Docker (et optionnellement les RPM Docker) dans l’archive. Sur une machine **avec** Internet et Docker :

```bash
cd "cluster hpc"
# (Optionnel) Pour inclure les RPM Docker : télécharger d’abord les RPM (SUSE/Leap 15.4)
sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh
# Puis export complet (images + configs + RPM si présents)
sudo bash scripts/deployment/export-hors-ligne-complet.sh
```

Ce script :
1. Télécharge les images du stack open-source (Prometheus, Grafana, Loki, JupyterHub, etc.).
2. Lance l’export complet (images + configs + scripts + docs).
3. Crée dans `export-demo/` l’archive **`hpc-cluster-demo-YYYYMMDD-HHMMSS.tar.gz`** (plus volumineuse, plusieurs Go si toutes les images sont exportées).

Copier **cette** archive sur la clé USB.

**Alternative** (sans pull des images) : `sudo bash scripts/deployment/export-complete-demo.sh` — crée la même structure mais sans les fichiers d’images (le serveur devra les télécharger ou les avoir déjà).

Sur le serveur SUSE 15 SP4 : extraire, puis `cd hpc-cluster-demo-* && sudo ./install-demo.sh` (voir `docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md`).

---

## 4. Docker en hors ligne (serveur sans Internet)

Le serveur SUSE 15 SP4 n’a pas Docker par défaut. Pour l’installer **sans Internet** :

### 4a. Sur une machine AVEC Internet (SUSE 15 SP4 ou openSUSE Leap 15.4)

Télécharger les RPM Docker et leurs dépendances :

```bash
cd "cluster hpc"
sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh
```

Cela remplit le dossier **`docker-offline-rpms/`** avec les fichiers `.rpm`. Ensuite :

- soit vous lancez l’export complet :  
  `sudo bash scripts/deployment/export-hors-ligne-complet.sh`  
  (le dossier `docker-offline-rpms/` est inclus dans l’export s’il est déjà rempli) ;
- soit vous copiez manuellement **`docker-offline-rpms/`** sur la clé USB avec le reste de l’export.

### 4b. Sur le serveur SUSE 15 SP4 (hors ligne)

Après avoir extrait l’export (ou copié le dossier) depuis la clé USB :

```bash
cd hpc-cluster-demo-*   # ou le dossier où se trouvent install-demo.sh et docker-offline-rpms/

# Installer Docker depuis les RPM locaux
sudo ./install-docker-offline.sh

# Puis installer et démarrer le cluster
sudo ./install-demo.sh
```

Si vous lancez directement **`sudo ./install-demo.sh`** sans Docker installé, le script tentera d’installer Docker depuis **`docker-offline-rpms/`** s’il contient des `.rpm`, sinon il demandera une connexion réseau (zypper).

---

## 5. Installation sur le serveur SUSE 15 SP4 (à partir de l’archive projet)

### 5.1 Copier l’archive depuis la clé USB

```bash
# Monter la clé (ex. /dev/sdb1) ou copier depuis /media/usb
sudo mkdir -p /opt/hpc
sudo cp /chemin/vers/clé/cluster-hpc-suse15sp4-*.tar.gz /opt/hpc/
cd /opt/hpc
sudo tar -xzf cluster-hpc-suse15sp4-*.tar.gz
cd "cluster hpc"
```

### 5.2 Docker sur le serveur

- **Hors ligne** : voir **§ 4** (RPM dans `docker-offline-rpms/` + `./install-docker-offline.sh`).
- **Avec Internet** : `sudo zypper install -y docker docker-compose` puis `sudo systemctl enable --now docker`.

### 5.3 Installation du cluster

```bash
cd /opt/hpc/"cluster hpc"

# Installation complète (Slurm, GlusterFS, scripts, etc.)
sudo bash install-all.sh

# Ou démarrage direct si tout est déjà installé
sudo ./cluster-start.sh
```

### 5.4 Vérification

```bash
sudo bash scripts/tests/test-cluster-health.sh
```

Consulter `DEMO.md` pour les URLs (Grafana, Prometheus, JupyterHub, FreeIPA) et le déroulé de la démo.

---

## 6. Résumé (tout hors ligne)

| Étape | Où | Action |
|-------|-----|--------|
| 1 | Machine avec Internet (SUSE/Leap 15.4) | `sudo bash scripts/deployment/download-docker-rpms-suse15sp4.sh` → remplit `docker-offline-rpms/`. |
| 2 | Même machine | `sudo bash scripts/deployment/export-hors-ligne-complet.sh` → crée l’archive avec images + RPM. |
| 3 | — | Copier l’archive (et le dossier export si besoin) sur la clé USB. |
| 4 | Serveur SUSE 15 SP4 hors ligne | Copier depuis la clé vers `/opt`, extraire l’archive. |
| 5 | Serveur | `cd hpc-cluster-demo-* && sudo ./install-docker-offline.sh` (si Docker absent). |
| 6 | Serveur | `sudo ./install-demo.sh` (charge les images, build, démarre le cluster). |
| 7 | Serveur | `sudo bash scripts/tests/test-cluster-health.sh` ; démo avec `DEMO.md`. |

---

*Cluster HPC 100 % open-source – 2 frontaux, 6 nœuds – compatible SUSE 15 SP4.*
