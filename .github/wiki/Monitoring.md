# 📊 Monitoring - Guide Complet

> **Guide complet du monitoring - Niveau DevOps Senior**

---

## 🎯 Vue d'Ensemble

Le cluster HPC utilise une stack de monitoring complète :
- **Prometheus** : Collecte et stockage des métriques
- **Grafana** : Visualisation et dashboards
- **InfluxDB** : Base de données temporelle
- **Loki** : Logs agrégés
- **Alertmanager** : Gestion des alertes

---

## 📈 Prometheus

### Architecture

```
┌─────────────┐
│ Prometheus  │
│  (Collecte) │
└──────┬──────┘
       │
       ├──► Node Exporter (Métriques système)
       ├──► Slurm Exporter (Métriques Slurm)
       ├──► cAdvisor (Métriques conteneurs)
       └──► Exporters personnalisés
```

### Configuration

**Fichier** : `/etc/prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'hpc-cluster'

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
        labels:
          instance: 'frontend01'
          role: 'frontend'
```

### Métriques Clés

**Système** :
- `node_cpu_seconds_total` : Utilisation CPU
- `node_memory_MemTotal_bytes` : Mémoire totale
- `node_filesystem_size_bytes` : Taille du système de fichiers
- `node_network_receive_bytes_total` : Réseau entrant

**Slurm** :
- `slurm_jobs_total` : Nombre total de jobs
- `slurm_jobs_running` : Jobs en cours
- `slurm_nodes_total` : Nombre de nœuds
- `slurm_nodes_idle` : Nœuds inactifs

---

## 📊 Grafana

### Dashboards Disponibles

1. **System Overview** : Vue d'ensemble système
2. **Slurm Cluster** : État du cluster Slurm
3. **Node Metrics** : Métriques par nœud
4. **Network** : Statistiques réseau
5. **Storage** : Utilisation du stockage

### Créer un Dashboard

**Via l'interface web** :
1. Aller dans **Dashboards** > **New Dashboard**
2. Ajouter un **Panel**
3. Configurer la requête PromQL
4. Personnaliser la visualisation

**Exemple de requête** :
```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Variables de Template

```json
{
  "templating": {
    "list": [
      {
        "name": "instance",
        "type": "query",
        "query": "label_values(node_cpu_seconds_total, instance)"
      }
    ]
  }
}
```

---

## 💾 InfluxDB

### Architecture

```
┌──────────┐
│ Telegraf │──► Collecte des métriques
└────┬─────┘
     │
     ▼
┌──────────┐
│ InfluxDB │──► Stockage temporel
└────┬─────┘
     │
     ▼
┌──────────┐
│ Grafana  │──► Visualisation
└──────────┘
```

### Configuration Telegraf

**Fichier** : `/etc/telegraf/telegraf.conf`

```toml
[[outputs.influxdb_v2]]
  urls = ["http://localhost:8086"]
  token = "YOUR_TOKEN"
  organization = "hpc-cluster"
  bucket = "metrics"

[[inputs.cpu]]
  percpu = true
  totalcpu = true

[[inputs.mem]]
[[inputs.disk]]
[[inputs.net]]
```

### Requêtes Flux

```flux
from(bucket: "metrics")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu")
  |> aggregateWindow(every: 1m, fn: mean)
```

---

## 🚨 Alertes

### Configuration Alertmanager

**Fichier** : `/etc/alertmanager/alertmanager.yml`

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'

receivers:
  - name: 'default'
    webhook_configs:
      - url: 'http://localhost:5001/webhook'
```

### Règles d'Alerte

**Fichier** : `/etc/prometheus/alerts.yml`

```yaml
groups:
  - name: system_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU usage is high on {{ $labels.instance }}"
```

---

## 📝 Logs avec Loki

### Architecture

```
┌──────────┐
│ Promtail │──► Collecte des logs
└────┬─────┘
     │
     ▼
┌──────────┐
│   Loki   │──► Stockage des logs
└────┬─────┘
     │
     ▼
┌──────────┐
│ Grafana  │──► Visualisation
└──────────┘
```

### Configuration Promtail

**Fichier** : `/etc/promtail/config.yml`

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*.log
```

---

## 🔍 Métriques Personnalisées

### Exporter Personnalisé

**Exemple Python** :
```python
from prometheus_client import start_http_server, Gauge
import time

custom_metric = Gauge('custom_metric', 'Description')

def update_metric():
    while True:
        custom_metric.set(42)
        time.sleep(10)

if __name__ == '__main__':
    start_http_server(8000)
    update_metric()
```

**Configuration Prometheus** :
```yaml
scrape_configs:
  - job_name: 'custom'
    static_configs:
      - targets: ['localhost:8000']
```

---

## 📊 Dashboards Recommandés

### 1. System Overview

**Métriques** :
- CPU usage par nœud
- Mémoire utilisée
- Disque utilisé
- Réseau entrant/sortant

**Requêtes** :
```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### 2. Slurm Cluster

**Métriques** :
- Jobs en cours
- Jobs en attente
- Nœuds actifs/inactifs
- Utilisation des partitions

**Requêtes** :
```promql
slurm_jobs_running
slurm_jobs_pending
slurm_nodes_idle
```

### 3. Storage

**Métriques** :
- Espace disque utilisé
- IOPS
- Latence

**Requêtes** :
```promql
(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100
```

---

## 🎯 Bonnes Pratiques

### 1. Rétention Optimale

```yaml
# Prometheus
retention: 15d  # Pour les métriques détaillées

# InfluxDB
retention: 30d  # Pour les métriques agrégées
```

### 2. Agrégation

```yaml
# Règles d'enregistrement
- record: job:node_cpu_usage:avg
  expr: avg(rate(node_cpu_seconds_total[5m])) by (job)
```

### 3. Labels Efficaces

```yaml
# ✅ Bon : Labels spécifiques
node_cpu_seconds_total{instance="compute01", mode="idle"}

# ❌ Mauvais : Trop de labels
node_cpu_seconds_total{instance="compute01", mode="idle", job="node", cluster="hpc"}
```

---

## 📚 Ressources

- **📖 [Configuration de Base](Configuration-de-Base)**
- **💡 [Astuces](Astuces)**
- **🐛 [Dépannage](Depannage)**

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
