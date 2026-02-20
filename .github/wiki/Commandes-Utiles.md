# 📋 Commandes Utiles - Référence Rapide

> **Référence rapide des commandes essentielles - Niveau DevOps Senior**

---

## 🔍 Prometheus

### Vérification

```bash
# État du service
sudo systemctl status prometheus

# Vérifier la configuration
sudo prometheus --config.file=/etc/prometheus/prometheus.yml --check-config

# Targets actifs
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .job, health: .health}'

# Métriques disponibles
curl http://localhost:9090/api/v1/label/__name__/values | jq '.data[]' | head -20
```

### Requêtes

```bash
# Requête simple
curl 'http://localhost:9090/api/v1/query?query=up'

# Requête avec timestamp
curl 'http://localhost:9090/api/v1/query?query=up&time=2024-01-01T00:00:00Z'

# Requête de plage
curl 'http://localhost:9090/api/v1/query_range?query=up&start=2024-01-01T00:00:00Z&end=2024-01-01T23:59:59Z&step=15s'
```

### Administration

```bash
# Redémarrer
sudo systemctl restart prometheus

# Recharger la configuration
sudo systemctl reload prometheus

# Logs en temps réel
sudo journalctl -u prometheus -f

# Logs des 50 dernières lignes
sudo journalctl -u prometheus -n 50
```

---

## 📊 Grafana

### Vérification

```bash
# État du service
sudo systemctl status grafana

# Santé de l'API
curl http://localhost:3000/api/health

# Version
curl -u admin:admin http://localhost:3000/api/health

# Dashboards
curl -u admin:admin http://localhost:3000/api/search?query=
```

### Administration

```bash
# Redémarrer
sudo systemctl restart grafana

# Logs en temps réel
sudo tail -f /var/log/grafana/grafana.log

# Vérifier les plugins
grafana-cli plugins list-remote
grafana-cli plugins install plugin-name
```

### CLI

```bash
# Créer un utilisateur
grafana-cli admin reset-admin-password newpassword

# Backup de la base de données
sqlite3 /var/lib/grafana/grafana.db .dump > backup.sql

# Restauration
sqlite3 /var/lib/grafana/grafana.db < backup.sql
```

---

## 💾 InfluxDB

### Vérification

```bash
# Ping
influx ping

# Version
influx version

# État
influx server-config
```

### Administration

```bash
# Créer un bucket
influx bucket create --name metrics --org hpc-cluster

# Lister les buckets
influx bucket list

# Créer un utilisateur
influx user create --name admin --password password

# Créer un token
influx auth create \
  --org hpc-cluster \
  --all-access \
  --description "Admin token"
```

### Requêtes

```bash
# Requête simple
influx query 'from(bucket:"metrics") |> range(start: -1h) |> limit(n:10)'

# Requête avec filtre
influx query 'from(bucket:"metrics") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "cpu")'

# Export des données
influx query 'from(bucket:"metrics") |> range(start: -30d)' --raw > export.csv
```

### Backup/Restauration

```bash
# Backup
influx backup /backup/influxdb

# Restauration
influx restore /backup/influxdb
```

---

## 🎯 Slurm

### État du Cluster

```bash
# État général
sinfo

# État détaillé
sinfo -N -l

# État des partitions
sinfo -p normal,high

# État des nœuds
scontrol show nodes
```

### Jobs

```bash
# Lister les jobs
squeue

# Jobs d'un utilisateur
squeue -u username

# Détails d'un job
scontrol show job JOBID

# Historique
sacct

# Historique avec détails
sacct -l
```

### Administration

```bash
# Redémarrer le contrôleur
sudo systemctl restart slurmctld

# Redémarrer le démon
sudo systemctl restart slurmd

# Recharger la configuration
sudo scontrol reconfigure

# Mettre un nœud en maintenance
sudo scontrol update NodeName=compute01 State=DRAIN Reason="Maintenance"

# Remettre un nœud en service
sudo scontrol update NodeName=compute01 State=RESUME
```

---

## 🔧 Système

### Services

```bash
# État de tous les services
systemctl list-units --type=service --state=running

# Services échoués
systemctl list-units --type=service --state=failed

# Redémarrer un service
sudo systemctl restart SERVICE_NAME

# Activer au démarrage
sudo systemctl enable SERVICE_NAME

# Désactiver au démarrage
sudo systemctl disable SERVICE_NAME
```

### Réseau

```bash
# Ports ouverts
sudo netstat -tlnp
sudo ss -tlnp

# Processus utilisant un port
sudo lsof -i :3000
sudo fuser 3000/tcp

# Test de connectivité
telnet HOST PORT
curl http://HOST:PORT
```

### Ressources

```bash
# CPU
top
htop
vmstat 1

# Mémoire
free -h
cat /proc/meminfo

# Disque
df -h
du -sh /path
iostat -x 1

# Réseau
iftop
nethogs
```

---

## 📦 Docker

### Conteneurs

```bash
# Lister les conteneurs
docker ps
docker ps -a

# Logs
docker logs CONTAINER_ID
docker logs -f CONTAINER_ID

# Exécuter une commande
docker exec -it CONTAINER_ID /bin/bash

# Redémarrer
docker restart CONTAINER_ID

# Arrêter/Démarrer
docker stop CONTAINER_ID
docker start CONTAINER_ID
```

### Images

```bash
# Lister les images
docker images

# Construire une image
docker build -t image-name .

# Supprimer une image
docker rmi IMAGE_ID

# Nettoyer
docker system prune -a
```

---

## 🐧 Podman

### Conteneurs

```bash
# Lister les conteneurs
podman ps
podman ps -a

# Logs
podman logs CONTAINER_ID
podman logs -f CONTAINER_ID

# Exécuter une commande
podman exec -it CONTAINER_ID /bin/bash

# Redémarrer
podman restart CONTAINER_ID
```

### Pods

```bash
# Lister les pods
podman pod ls

# Créer un pod
podman pod create --name pod-name

# Démarrer un pod
podman pod start pod-name

# Arrêter un pod
podman pod stop pod-name
```

---

## 🔍 Logs

### Journalctl

```bash
# Logs d'un service
sudo journalctl -u SERVICE_NAME

# Logs en temps réel
sudo journalctl -u SERVICE_NAME -f

# Logs depuis aujourd'hui
sudo journalctl -u SERVICE_NAME --since today

# Logs avec filtre
sudo journalctl -u SERVICE_NAME | grep ERROR
```

### Fichiers de Log

```bash
# Grafana
sudo tail -f /var/log/grafana/grafana.log

# Prometheus
sudo tail -f /var/log/prometheus/prometheus.log

# Slurm
sudo tail -f /var/log/slurm/slurmctld.log
sudo tail -f /var/log/slurm/slurmd.log

# Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 🔒 Sécurité

### Firewall

```bash
# Firewalld (openSUSE/CentOS)
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload

# UFW (Ubuntu/Debian)
sudo ufw status
sudo ufw allow 3000/tcp
sudo ufw enable
```

### SSL/TLS

```bash
# Générer un certificat auto-signé
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Vérifier un certificat
openssl x509 -in cert.pem -text -noout
```

---

## 📊 Monitoring

### Métriques Système

```bash
# CPU
top -bn1 | grep "Cpu(s)" | awk '{print $2}'

# Mémoire
free -m | awk 'NR==2{printf "%.2f%%\n", $3*100/$2}'

# Disque
df -h | awk '$NF=="/"{printf "%s\n", $5}'
```

### Health Checks

```bash
# Prometheus
curl http://localhost:9090/-/healthy

# Grafana
curl http://localhost:3000/api/health

# InfluxDB
influx ping
```

---

## 🛠️ Utilitaires

### Recherche

```bash
# Rechercher dans les fichiers
grep -r "pattern" /path

# Rechercher des fichiers
find /path -name "*.conf"

# Rechercher des processus
ps aux | grep PROCESS_NAME
```

### Compression

```bash
# Créer une archive
tar czf archive.tar.gz /path

# Extraire
tar xzf archive.tar.gz

# Avec compression
tar czf - /path | gzip > archive.tar.gz
```

---

## 📚 Ressources

- **📖 [Installation Rapide](Installation-Rapide.md)**
- **💡 [Astuces](Astuces.md)**
- **🐛 [Dépannage](Depannage.md)**

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
