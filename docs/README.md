# Infrastructure HPC Monitoring - Documentation Complète

## Classification: Architecture Technique - Niveau Sénior

Infrastructure de monitoring complète pour cluster HPC simulé via Docker, composée de :
- **2 nœuds frontaux** (master/backup)
- **6 nœuds de calcul** (workers)
- **Stack monitoring**: Prometheus + Grafana + Telegraf
- **Environnement**: SUSE Linux Enterprise Server 15 SP7 / openSUSE Leap 15.4

**Contrainte critique**: Déploiement air-gapped (hors ligne) - Package autonome exportable via clé USB.

---

## 📋 Table des Matières

1. [Architecture](#architecture)
2. [Prérequis](#prérequis)
3. [Installation Rapide](#installation-rapide)
4. [Déploiement Offline (Air-Gapped)](#déploiement-offline-air-gapped)
5. [Configuration](#configuration)
6. [Utilisation](#utilisation)
7. [Réseaux et IPs](#réseaux-et-ips)
8. [Sécurité](#sécurité)
9. [Dépannage](#dépannage)
10. [Structure du Projet](#structure-du-projet)

---

## 🏗️ Architecture

### Topologie Réseau

- **VLAN Management**: `172.20.0.0/24` (monitoring)
  - Prometheus: `172.20.0.10`
  - Grafana: `172.20.0.20`
  - Frontaux: `172.20.0.101-102`
  - Slaves: `172.20.0.201-206`

- **VLAN Cluster**: `10.0.0.0/24` (communication inter-nœuds)
  - Frontaux: `10.0.0.101-102`
  - Slaves: `10.0.0.201-206`

### Composants

| Service | Image | Ports | Description |
|---------|-------|-------|-------------|
| Prometheus | prom/prometheus:v2.48.0 | 9090 | Collecte et stockage des métriques |
| Grafana | grafana/grafana:10.2.0 | 3000 | Visualisation et dashboards |
| Frontal-01 | Custom (openSUSE) | 2222, 9100, 9273 | Nœud frontal principal |
| Frontal-02 | Custom (openSUSE) | 2223, 9101, 9274 | Nœud frontal secondaire |
| Slave-01 à 06 | Custom (openSUSE) | 9102-9107, 9275-9280 | Nœuds de calcul |

### Services par Nœud

**Frontaux:**
- SSH (port 22)
- Node Exporter (port 9100)
- Telegraf (port 9273)
- SlurmCTLD (optionnel)

**Slaves:**
- SSH (port 22)
- Node Exporter (port 9100)
- Telegraf (port 9273)
- SlurmD (optionnel)

---

## 📦 Prérequis

### Sur Machine de Build (Online)

- **OS**: openSUSE Leap 15.4 ou SUSE SLES 15 SP7
- **Docker**: 20.10+ (API 1.41+)
- **Docker Compose**: 1.29+ ou Docker Compose V2
- **Espace disque**: 15GB minimum (pour images + export)
- **RAM**: 4GB minimum recommandé
- **Accès Internet**: Pour télécharger les images de base

### Sur Serveur Cible (Offline)

- **OS**: SUSE SLES 15 SP7 ou openSUSE Leap 15.4
- **Docker**: 20.10+
- **Docker Compose**: 1.29+ ou Docker Compose V2
- **Espace disque**: 10GB minimum
- **RAM**: 4GB minimum recommandé
- **Clé USB**: Pour transfert du package d'export

---

## 🚀 Installation Rapide

### Option 1: Script d'Installation Automatique

```bash
chmod +x INSTALL.sh
./INSTALL.sh
```

### Option 2: Makefile

```bash
make install
```

### Option 3: Commandes Manuelles

```bash
# Build des images
docker-compose build

# Démarrage
docker-compose up -d

# Vérification
docker-compose ps
```

### Accès aux Services

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
  - Login: `admin`
  - Password: `demo-hpc-2024`
- **SSH Frontal-01**: `ssh root@localhost -p 2222` (password: `hpc-demo-2024`)
- **SSH Frontal-02**: `ssh root@localhost -p 2223` (password: `hpc-demo-2024`)

---

## 💾 Déploiement Offline (Air-Gapped)

### Étape 1: Build et Export sur Machine Online

```bash
# Méthode 1: Script dédié
./scripts/build-and-export.sh

# Méthode 2: Makefile
make export

# Méthode 3: Manuel
docker-compose build
docker save <images> | gzip > images.tar.gz
```

Le script génère un répertoire `hpc-export/TIMESTAMP/` contenant:
- `images/`: Archives tar.gz de toutes les images Docker
- `configs/`: Toutes les configurations
- `scripts/`: Scripts d'entrypoint et utilitaires
- `docker-compose.yml`: Fichier d'orchestration
- `import-images.sh`: Script d'import automatique

### Étape 2: Création de l'Archive pour USB

```bash
cd hpc-export
tar -czf hpc-monitoring-$(date +%Y%m%d).tar.gz TIMESTAMP/
# Copier sur clé USB
```

### Étape 3: Installation sur Serveur Offline

```bash
# 1. Extraire l'archive
tar -xzf hpc-monitoring-YYYYMMDD.tar.gz
cd TIMESTAMP/

# 2. Importer les images Docker
chmod +x import-images.sh
./import-images.sh

# 3. Vérifier les images importées
docker images

# 4. Démarrer l'infrastructure
docker-compose up -d

# 5. Vérifier le statut
docker-compose ps
```

---

## ⚙️ Configuration

### Prometheus

**Fichier**: `configs/prometheus/prometheus.yml`

- **Retention**: 15 jours
- **Scrape interval**: 15 secondes
- **Targets**: 16 targets (8 Node Exporters + 8 Telegraf)

**Modification**:
```bash
vim configs/prometheus/prometheus.yml
docker-compose restart prometheus
```

### Grafana

**Datasource**: Auto-provisionné via `configs/grafana/provisioning/datasources/prometheus.yml`

**Dashboards**: Auto-chargés depuis `grafana-dashboards/`

**Dashboards inclus**:
- HPC Cluster Overview (statuts nœuds, CPU, Memory, Disk, Network)
- CPU & Memory by Node
- Network I/O

**Ajout de dashboard**:
1. Créer un dashboard dans Grafana UI
2. Exporter en JSON
3. Placer dans `grafana-dashboards/`
4. Redémarrer Grafana

### Telegraf

**Frontaux**: `configs/telegraf/telegraf-frontal.conf`
**Slaves**: `configs/telegraf/telegraf-slave.conf`

**Métriques collectées**:
- CPU, Memory, Disk, Disk I/O
- Network, Processes, Kernel
- System Load
- Slurm (optionnel, décommenter si installé)

**Modification**:
```bash
vim configs/telegraf/telegraf-frontal.conf
docker-compose restart frontal-01 frontal-02
```

### Alertes Prometheus

**Fichier**: `configs/prometheus/alerts.yml`

**Alertes configurées**:
- High/Critical CPU Usage (80%/95%)
- High/Critical Memory Usage (85%/95%)
- High/Critical Disk Usage (80%/90%)
- High Network Traffic
- Node Exporter/Telegraf Down

---

## 🎯 Utilisation

### Commandes Makefile

```bash
make help          # Aide complète
make build         # Build des images
make start         # Démarrage
make stop          # Arrêt
make restart       # Redémarrage
make logs          # Logs de tous les services
make status        # Statut des services
make health        # Vérification de santé
make clean         # Nettoyage complet (ATTENTION: supprime les données)
make export        # Export pour déploiement offline
```

### Commandes Docker Compose

```bash
# Démarrage
docker-compose up -d

# Arrêt
docker-compose down

# Logs
docker-compose logs -f [service-name]

# Statut
docker-compose ps

# Rebuild d'un service
docker-compose build [service-name]
docker-compose up -d [service-name]

# Accès shell dans un conteneur
docker-compose exec [service-name] /bin/bash
```

### Vérification des Métriques

**Prometheus Targets**:
```bash
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**Métriques Node Exporter**:
```bash
curl http://localhost:9100/metrics
```

**Métriques Telegraf**:
```bash
curl http://localhost:9273/metrics
```

### Dashboards Grafana

1. Accéder à http://localhost:3000
2. Login: `admin` / `demo-hpc-2024`
3. Naviguer vers **Dashboards** → **HPC Monitoring**
4. Dashboards disponibles:
   - **HPC Cluster Overview**: Vue d'ensemble du cluster
   - **CPU & Memory by Node**: Détails CPU/Memory par nœud
   - **Network I/O**: Statistiques réseau

---

## 🌐 Réseaux et IPs

### Réseau Management (172.20.0.0/24)

| Service | IP | Ports |
|---------|----|----|
| Prometheus | 172.20.0.10 | 9090 |
| Grafana | 172.20.0.20 | 3000 |
| Frontal-01 | 172.20.0.101 | 2222, 9100, 9273 |
| Frontal-02 | 172.20.0.102 | 2223, 9101, 9274 |
| Slave-01 | 172.20.0.201 | 9102, 9275 |
| Slave-02 | 172.20.0.202 | 9103, 9276 |
| Slave-03 | 172.20.0.203 | 9104, 9277 |
| Slave-04 | 172.20.0.204 | 9105, 9278 |
| Slave-05 | 172.20.0.205 | 9106, 9279 |
| Slave-06 | 172.20.0.206 | 9107, 9280 |

### Réseau Cluster (10.0.0.0/24)

| Service | IP |
|---------|----|
| Frontal-01 | 10.0.0.101 |
| Frontal-02 | 10.0.0.102 |
| Slave-01 | 10.0.0.201 |
| Slave-02 | 10.0.0.202 |
| Slave-03 | 10.0.0.203 |
| Slave-04 | 10.0.0.204 |
| Slave-05 | 10.0.0.205 |
| Slave-06 | 10.0.0.206 |

---

## 🔒 Sécurité

### Hardening Appliqué

**Sysctl**:
- `kernel.randomize_va_space = 2` (ASLR activé)
- `net.ipv4.tcp_syncookies = 1` (Protection SYN flood)

**SSH**:
- Protocol 2 uniquement
- X11Forwarding désactivé
- PermitRootLogin yes (pour démo uniquement)

**Conteneurs**:
- Mode privilégié uniquement si nécessaire (systemd)
- Volumes de config en lecture seule (`:ro`)
- Healthchecks sur tous les services critiques

### Recommandations Production

⚠️ **IMPORTANT**: Cette configuration est pour démonstration. Pour production:

1. **Changer les mots de passe par défaut**:
   - Grafana: `demo-hpc-2024` → mot de passe fort
   - SSH root: `hpc-demo-2024` → désactiver root, utiliser clés SSH

2. **Sécuriser les réseaux**:
   - Isoler les réseaux Docker du réseau hôte
   - Utiliser des firewall rules

3. **Mettre à jour régulièrement**:
   - Images Docker (Prometheus, Grafana)
   - Packages système dans les conteneurs

4. **Audit et logging**:
   - Activer les logs d'audit système
   - Centraliser les logs (ELK, Loki)

---

## 🔧 Dépannage

### Services ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs [service-name]

# Vérifier les ports
netstat -tulpn | grep -E "(9090|3000|2222)"

# Vérifier les réseaux Docker
docker network ls
docker network inspect hpc-docker_management
```

### Prometheus ne scrape pas les targets

```bash
# Vérifier la configuration
docker-compose exec prometheus cat /etc/prometheus/prometheus.yml

# Vérifier la connectivité réseau
docker-compose exec prometheus ping 172.20.0.101

# Vérifier les targets
curl http://localhost:9090/api/v1/targets
```

### Grafana ne se connecte pas à Prometheus

1. Vérifier que Prometheus est UP: `curl http://localhost:9090/-/healthy`
2. Vérifier la config datasource: `configs/grafana/provisioning/datasources/prometheus.yml`
3. Redémarrer Grafana: `docker-compose restart grafana`

### Node Exporter ou Telegraf non accessibles

```bash
# Vérifier les processus dans le conteneur
docker-compose exec frontal-01 ps aux | grep -E "(node_exporter|telegraf)"

# Vérifier les ports
docker-compose exec frontal-01 netstat -tulpn | grep -E "(9100|9273)"

# Vérifier les logs
docker-compose logs frontal-01
```

### Problèmes de build

```bash
# Nettoyer le cache Docker
docker system prune -a

# Rebuild sans cache
docker-compose build --no-cache

# Vérifier l'espace disque
df -h
```

### Problèmes d'export/import

```bash
# Vérifier la taille des images
docker images

# Vérifier l'espace disque disponible
df -h

# Import manuel si le script échoue
gunzip -c images/image-name.tar.gz | docker load
```

---

## 📁 Structure du Projet

```
hpc-docker/
├── docker-compose.yml          # Orchestration complète
├── Dockerfile.frontal          # Image pour nœuds frontaux
├── Dockerfile.slave           # Image pour nœuds de calcul
├── Makefile                    # Commandes automatisées
├── INSTALL.sh                  # Script d'installation one-click
├── README.md                   # Cette documentation
│
├── configs/
│   ├── prometheus/
│   │   ├── prometheus.yml      # Configuration scraping
│   │   └── alerts.yml          # Règles d'alerte
│   ├── telegraf/
│   │   ├── telegraf-frontal.conf
│   │   └── telegraf-slave.conf
│   └── grafana/
│       └── provisioning/
│           ├── datasources/
│           │   └── prometheus.yml
│           └── dashboards/
│               └── default.yml
│
├── grafana-dashboards/
│   ├── hpc-cluster-overview.json
│   ├── cpu-memory-by-node.json
│   └── network-io.json
│
└── scripts/
    ├── entrypoint-frontal.sh   # Script d'initialisation frontaux
    ├── entrypoint-slave.sh     # Script d'initialisation slaves
    └── build-and-export.sh     # Script d'export pour offline
```

---

## 📊 Métriques Disponibles

### Node Exporter (port 9100)

- `node_cpu_seconds_total`: Utilisation CPU par mode
- `node_memory_*`: Métriques mémoire (total, available, cached, etc.)
- `node_filesystem_*`: Utilisation disque par filesystem
- `node_disk_*`: I/O disque (read/write bytes, iops)
- `node_network_*`: Statistiques réseau (bytes, packets, errors)
- `node_load*`: Charge système (1m, 5m, 15m)

### Telegraf (port 9273)

- `cpu_usage_*`: Métriques CPU détaillées
- `mem_*`: Métriques mémoire
- `disk_*`: Métriques disque
- `diskio_*`: I/O disque
- `net_*`: Statistiques réseau
- `processes_*`: Statistiques processus
- `kernel_*`: Métriques kernel

### Prometheus (port 9090)

- Métriques internes Prometheus
- Métriques des targets scraped
- État des alertes

---

## 🆘 Support

Pour toute question ou problème:

1. Consulter la section [Dépannage](#dépannage)
2. Vérifier les logs: `docker-compose logs`
3. Vérifier le statut: `docker-compose ps`
4. Vérifier la santé: `make health`

---

## 📝 Notes Importantes

- **Mots de passe par défaut**: À changer en production
- **Réseaux**: IPs fixes pour simulation cluster réel
- **Volumes**: Données Prometheus et Grafana persistantes
- **Compatibilité**: Docker 20.10+ requis (API 1.41)
- **Air-gapped**: Package exportable pour déploiement offline

---

## 📄 Licence

Projet interne - Usage défense/aérospatial.

---

**Version**: 1.0  
**Dernière mise à jour**: 2024  
**Maintenu par**: HPC Team
