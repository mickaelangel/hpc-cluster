# 💡 Astuces et Optimisations

> **Astuces avancées pour DevOps Senior**

---

## 🚀 Performance

### Optimiser Prometheus

**Réduire la rétention** :
```yaml
# /etc/prometheus/prometheus.yml
global:
  retention: 15d  # Au lieu de 30d
```

**Utiliser des règles d'enregistrement** :
```yaml
# /etc/prometheus/rules.yml
groups:
  - name: aggregated
    interval: 30s
    rules:
      - record: job:node_cpu_usage:avg
        expr: avg(rate(node_cpu_seconds_total[5m])) by (job)
```

**Compression des données** :
```yaml
# Activer la compression
storage:
  tsdb:
    path: /var/lib/prometheus
    retention.time: 15d
    retention.size: 50GB
```

---

### Optimiser Grafana

**Augmenter les limites** :
```ini
# /etc/grafana/grafana.ini
[server]
max_concurrent_connections = 100

[dataproxy]
timeout = 300
```

**Cache des requêtes** :
```ini
[dataproxy]
keep_alive_seconds = 30
```

**Optimiser les dashboards** :
- Utiliser des requêtes plus courtes
- Réduire la plage de temps par défaut
- Utiliser des variables de template
- Désactiver les requêtes inutilisées

---

### Optimiser InfluxDB

**Configuration mémoire** :
```toml
# /etc/influxdb/influxdb.conf
[data]
cache-max-memory-size = "1g"
cache-snapshot-memory-size = "25m"
```

**Rétention optimisée** :
```bash
# Créer des buckets avec rétention différente
influx bucket create \
  --name metrics-1h \
  --retention 1h \
  --org hpc-cluster

influx bucket create \
  --name metrics-1d \
  --retention 1d \
  --org hpc-cluster
```

---

## 🔒 Sécurité

### Authentification Multi-Facteurs

**Grafana avec MFA** :
```ini
# /etc/grafana/grafana.ini
[auth]
disable_login_form = false

[auth.google]
enabled = true
client_id = YOUR_CLIENT_ID
client_secret = YOUR_CLIENT_SECRET
scopes = openid email profile
```

**LDAP avec 2FA** :
```toml
# /etc/grafana/ldap.toml
[[servers]]
host = "ldap.example.com"
port = 636
use_ssl = true
ssl_skip_verify = false
```

---

### Chiffrement des Données

**Chiffrer les backups** :
```bash
# Backup avec chiffrement
tar czf - /var/lib/prometheus | \
  gpg --symmetric --cipher-algo AES256 \
  --output backup-$(date +%Y%m%d).tar.gz.gpg
```

**Chiffrer les communications** :
```nginx
# Nginx avec SSL
server {
    listen 443 ssl http2;
    ssl_certificate /etc/ssl/certs/grafana.crt;
    ssl_certificate_key /etc/ssl/private/grafana.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}
```

---

## 📊 Monitoring Avancé

### Métriques Personnalisées

**Script Python pour métriques custom** :
```python
#!/usr/bin/env python3
from prometheus_client import Gauge, start_http_server
import time

# Créer une métrique
custom_metric = Gauge('custom_metric', 'Description')

# Mettre à jour la métrique
def update_metric():
    while True:
        custom_metric.set(42)
        time.sleep(10)

if __name__ == '__main__':
    start_http_server(8000)
    update_metric()
```

**Exporter personnalisé** :
```go
package main

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
    "net/http"
)

var (
    customCounter = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "custom_requests_total",
            Help: "Total custom requests",
        },
        []string{"method"},
    )
)

func init() {
    prometheus.MustRegister(customCounter)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

---

### Alertes Intelligentes

**Alertes basées sur l'anomalie** :
```yaml
# /etc/prometheus/alerts.yml
groups:
  - name: anomaly_detection
    rules:
      - alert: AnomalousCPUUsage
        expr: |
          (
            rate(node_cpu_seconds_total[5m]) -
            avg_over_time(rate(node_cpu_seconds_total[5m])[1h:5m])
          ) > 2 * stddev_over_time(rate(node_cpu_seconds_total[5m])[1h:5m])
        for: 5m
```

**Alertes avec seuils dynamiques** :
```yaml
- alert: HighTraffic
  expr: |
    sum(rate(http_requests_total[5m])) >
    quantile(0.95, sum(rate(http_requests_total[1h])) by (job))
  for: 10m
```

---

## 🔄 Automatisation

### Scripts de Maintenance

**Nettoyage automatique** :
```bash
#!/bin/bash
# cleanup-old-data.sh

# Nettoyer Prometheus (> 30 jours)
find /var/lib/prometheus/data -type f -mtime +30 -delete

# Nettoyer InfluxDB
influx delete \
  --bucket metrics \
  --start $(date -d '30 days ago' -u +%Y-%m-%dT%H:%M:%SZ) \
  --stop $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Nettoyer les logs
find /var/log -name "*.log" -mtime +7 -delete
```

**Sauvegarde automatique** :
```bash
#!/bin/bash
# auto-backup.sh

BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup Prometheus
tar czf "$BACKUP_DIR/prometheus.tar.gz" /var/lib/prometheus

# Backup Grafana
tar czf "$BACKUP_DIR/grafana.tar.gz" /var/lib/grafana

# Backup InfluxDB
influx backup "$BACKUP_DIR/influxdb"

# Compression
tar czf "/backup/backup-$(date +%Y%m%d).tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

# Nettoyer les vieux backups (> 30 jours)
find /backup -name "backup-*.tar.gz" -mtime +30 -delete
```

**Crontab** :
```bash
# Ajouter au crontab
0 2 * * * /path/to/cleanup-old-data.sh
0 3 * * * /path/to/auto-backup.sh
```

---

### CI/CD pour Configuration

**GitHub Actions** :
```yaml
# .github/workflows/deploy-config.yml
name: Deploy Configuration

on:
  push:
    branches: [main]
    paths:
      - 'configs/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Prometheus Config
        run: |
          scp configs/prometheus/prometheus.yml user@server:/etc/prometheus/
          ssh user@server 'sudo systemctl reload prometheus'
```

**Ansible Playbook** :
```yaml
# deploy-config.yml
- hosts: monitoring
  tasks:
    - name: Deploy Prometheus config
      copy:
        src: configs/prometheus/prometheus.yml
        dest: /etc/prometheus/prometheus.yml
      notify: reload prometheus

  handlers:
    - name: reload prometheus
      systemd:
        name: prometheus
        state: reloaded
```

---

## 📈 Scaling

### Prometheus Fédération

**Configuration fédération** :
```yaml
# Prometheus principal
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="node"}'
        - '{job="slurm"}'
    static_configs:
      - targets:
          - 'prometheus-slave1:9090'
          - 'prometheus-slave2:9090'
```

### Grafana Multi-Tenant

**Configuration multi-tenant** :
```ini
# /etc/grafana/grafana.ini
[users]
allow_org_create = true
auto_assign_org = true
auto_assign_org_role = Viewer

[auth.proxy]
enabled = true
header_name = X-WEBAUTH-USER
header_property = username
auto_sign_up = true
```

---

## 🎯 Optimisations Spécifiques

### Requêtes PromQL Optimisées

**Éviter les requêtes coûteuses** :
```promql
# ❌ Mauvais : Scanne toutes les métriques
rate(http_requests_total[5m])

# ✅ Bon : Utilise un label pour filtrer
rate(http_requests_total{job="api"}[5m])

# ❌ Mauvais : Agrégation sur trop de séries
sum(rate(http_requests_total[5m]))

# ✅ Bon : Agrégation avec by
sum(rate(http_requests_total[5m])) by (job)
```

**Utiliser les règles d'enregistrement** :
```yaml
# Pré-calculer les métriques coûteuses
- record: job:http_requests:rate5m
  expr: rate(http_requests_total[5m])
```

---

### Dashboards Grafana Optimisés

**Variables de template** :
```json
{
  "templating": {
    "list": [
      {
        "name": "job",
        "type": "query",
        "query": "label_values(http_requests_total, job)"
      }
    ]
  }
}
```

**Refresh optimisé** :
- Utiliser `$__interval` pour l'intervalle automatique
- Désactiver le refresh automatique si non nécessaire
- Utiliser des requêtes avec `topk()` pour limiter les résultats

---

## 🔍 Debugging

### Logs Détaillés

**Prometheus** :
```yaml
# /etc/prometheus/prometheus.yml
global:
  log_level: debug
```

**Grafana** :
```ini
# /etc/grafana/grafana.ini
[log]
level = debug
filters = grafana:debug
```

**InfluxDB** :
```toml
# /etc/influxdb/influxdb.conf
[logging]
level = "debug"
```

---

### Profiling

**Prometheus** :
```bash
# Profiler Prometheus
curl http://localhost:9090/debug/pprof/profile?seconds=30 > profile.out
go tool pprof profile.out
```

**Grafana** :
```bash
# Profiler Grafana
curl http://localhost:3000/debug/pprof/profile?seconds=30 > grafana-profile.out
```

---

## 📚 Ressources

- **📖 [Configuration de Base](Configuration-de-Base)**
- **🐛 [Dépannage](Depannage)**
- **❓ [FAQ](FAQ)**

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
