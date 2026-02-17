# ⚙️ Configuration de Base

> **Configuration minimale fonctionnelle - Niveau DevOps Senior**

---

## 🎯 Vue d'Ensemble

Cette page décrit la configuration minimale nécessaire pour faire fonctionner le cluster HPC avec tous ses composants.

---

## 📋 Prérequis

- ✅ Installation complète effectuée
- ✅ Services démarrés
- ✅ Accès root/sudo

---

## 🔧 Configuration Prometheus

### Fichier Principal

**Fichier** : `/etc/prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'hpc-cluster'
    environment: 'production'

# Configuration Alertmanager
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']

# Règles d'alerte
rule_files:
  - '/etc/prometheus/alerts.yml'

# Configuration de scraping
scrape_configs:
  # Prometheus lui-même
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node Exporter (métriques système)
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  # Slurm Exporter (métriques Slurm)
  - job_name: 'slurm'
    static_configs:
      - targets: ['localhost:8080']

  # cAdvisor (métriques conteneurs)
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['localhost:8080']
```

### Vérification

```bash
# Vérifier la configuration
sudo prometheus --config.file=/etc/prometheus/prometheus.yml --check-config

# Redémarrer
sudo systemctl restart prometheus

# Vérifier les targets
curl http://localhost:9090/api/v1/targets
```

---

## 📊 Configuration Grafana

### Fichier Principal

**Fichier** : `/etc/grafana/grafana.ini`

```ini
[server]
http_addr = 0.0.0.0
http_port = 3000
domain = localhost
root_url = http://localhost:3000

[database]
type = sqlite3
path = /var/lib/grafana/grafana.db

[session]
provider = file
provider_config = sessions

[security]
admin_user = admin
admin_password = admin123  # ⚠️ À changer en production
secret_key = YOUR_SECRET_KEY_HERE

[users]
allow_sign_up = false
allow_org_create = false

[log]
mode = file
level = info

[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning
```

### Data Source Prometheus

**Fichier** : `/etc/grafana/provisioning/datasources/prometheus.yml`

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
```

### Vérification

```bash
# Redémarrer Grafana
sudo systemctl restart grafana

# Vérifier l'accès
curl http://localhost:3000/api/health
```

---

## 💾 Configuration InfluxDB

### Initialisation

```bash
# Initialiser InfluxDB
influx setup \
  --username admin \
  --password VotreMotDePasseSecurise \
  --org hpc-cluster \
  --bucket metrics \
  --retention 30d \
  --force
```

### Configuration Telegraf

**Fichier** : `/etc/telegraf/telegraf.conf`

```toml
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = ""
  omit_hostname = false

[[outputs.influxdb_v2]]
  urls = ["http://localhost:8086"]
  token = "YOUR_TOKEN_HERE"
  organization = "hpc-cluster"
  bucket = "metrics"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false

[[inputs.mem]]

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

[[inputs.diskio]]

[[inputs.net]]

[[inputs.processes]]

[[inputs.system]]
```

### Vérification

```bash
# Redémarrer Telegraf
sudo systemctl restart telegraf

# Vérifier les métriques
influx query 'from(bucket:"metrics") |> range(start: -1h) |> limit(n:10)'
```

---

## 🎯 Configuration Slurm

### Fichier Principal

**Fichier** : `/etc/slurm/slurm.conf`

```conf
ClusterName=hpc-cluster
ControlMachine=frontend01
ControlAddr=172.20.0.101
SlurmUser=slurm
SlurmdUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/spool/slurm/ctld
SlurmdSpoolDir=/var/spool/slurm/d
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
ProctrackType=proctrack/cgroup
ReturnToService=1
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0
SchedulerType=sched/backfill
SchedulerPort=7321
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
JobCompType=jobcomp/none
JobCompLoc=/var/log/slurm/jobcomp.log

# Nodes
NodeName=compute[01-06] CPUs=8 RealMemory=16000 State=UNKNOWN
PartitionName=normal Nodes=compute[01-06] Default=YES MaxTime=INFINITE State=UP
```

### Vérification

```bash
# Vérifier la configuration
sudo slurmctld -C

# Redémarrer Slurm
sudo systemctl restart slurmctld
sudo systemctl restart slurmd

# Vérifier l'état
sinfo
scontrol show nodes
```

---

## 🔐 Configuration Sécurité de Base

### Changer les Mots de Passe

```bash
# Script automatique
./scripts/change-default-passwords.sh

# Ou manuellement
# Grafana : Via l'interface web
# InfluxDB : Via CLI
influx user password -n admin -p NouveauMotDePasse
```

### Configuration Firewall

```bash
# openSUSE/Firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=8086/tcp
sudo firewall-cmd --reload

# Ubuntu/UFW
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 9090/tcp
sudo ufw allow 8086/tcp
sudo ufw enable
```

---

## 📈 Configuration Monitoring Avancé

### Alertes Prometheus

**Fichier** : `/etc/prometheus/alerts.yml`

```yaml
groups:
  - name: system_alerts
    interval: 30s
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU usage is high on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Memory usage is high on {{ $labels.instance }}"
          description: "Memory usage is above 85% for 5 minutes"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 15
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space is low on {{ $labels.instance }}"
          description: "Disk space is below 15% on {{ $labels.mountpoint }}"
```

### Configuration Alertmanager

**Fichier** : `/etc/alertmanager/alertmanager.yml`

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical'

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://localhost:5001/webhook'

  - name: 'critical'
    webhook_configs:
      - url: 'http://localhost:5001/webhook'
    email_configs:
      - to: 'admin@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.example.com:587'
        auth_username: 'alertmanager@example.com'
        auth_password: 'password'
```

---

## ✅ Vérification Complète

### Script de Vérification

```bash
#!/bin/bash
# verify-config.sh

echo "=== Vérification de la Configuration ==="

echo "1. Prometheus"
curl -s http://localhost:9090/api/v1/status/config | jq '.status' || echo "❌ Prometheus non accessible"

echo "2. Grafana"
curl -s http://localhost:3000/api/health | jq '.' || echo "❌ Grafana non accessible"

echo "3. InfluxDB"
influx ping || echo "❌ InfluxDB non accessible"

echo "4. Slurm"
sinfo || echo "❌ Slurm non accessible"

echo "5. Targets Prometheus"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .job, health: .health}'

echo "=== Vérification Terminée ==="
```

---

## 🚀 Prochaines Étapes

1. **🔒 [Sécurité](Securite)** : Sécuriser l'installation
2. **📊 [Monitoring](Monitoring)** : Configurer le monitoring avancé
3. **👥 [Guide Utilisateur](Guide-Utilisateur)** : Utilisation du cluster

---

## 📚 Ressources

- **📖 [Installation Rapide](Installation-Rapide)**
- **❓ [FAQ](FAQ)**
- **🐛 [Dépannage](Depannage)**

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
