# 📊 GUIDE MONITORING ET DASHBOARDS COMPLET
## Comment Utiliser le Monitoring, Modifier et Ajouter des Agents

**Classification**: Guide Monitoring Complet  
**Public**: Administrateurs / Utilisateurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'Ensemble du Monitoring](#1-vue-densemble)
2. [Accès aux Dashboards](#2-accès-aux-dashboards)
3. [Dashboards Disponibles](#3-dashboards-disponibles)
4. [Ajouter un Agent de Monitoring](#4-ajouter-un-agent)
5. [Modifier les Dashboards](#5-modifier-les-dashboards)
6. [Monitoring Hardware](#6-monitoring-hardware)
7. [Monitoring Réseau](#7-monitoring-réseau)
8. [Alertes](#8-alertes)

---

## 1. Vue d'Ensemble du Monitoring

### 1.1 Architecture

```
┌─────────────┐
│  Telegraf   │  ← Collecte métriques (chaque nœud)
│  (port 9273)│
└──────┬──────┘
       │
       │ Expose /metrics (format Prometheus)
       ▼
┌─────────────┐
│ Prometheus  │  ← Scrape (toutes les 15s)
│ (port 9090) │
└──────┬──────┘
       │
       │ Requête PromQL
       ▼
┌─────────────┐
│   Grafana   │  ← Visualisation
│ (port 3000) │
└─────────────┘
```

### 1.2 Composants

- **Telegraf** : Agent de collecte (sur chaque nœud)
- **Node Exporter** : Métriques système (sur chaque nœud)
- **Prometheus** : Collecte et stockage
- **Grafana** : Visualisation

---

## 2. Accès aux Dashboards

### 2.1 Grafana

**URL** : `http://localhost:3000`

**Identifiants** :
- Utilisateur : `admin`
- Mot de passe : `admin` (à changer en production)

**Première connexion** :
1. Aller sur http://localhost:3000
2. Login : admin / admin
3. Changer le mot de passe (recommandé)

---

## 3. Dashboards Disponibles

### 3.1 Dashboards Principaux

**54+ dashboards** disponibles dans `grafana-dashboards/` :

#### HPC Cluster
- **HPC Cluster Overview** : Vue d'ensemble complète
- **CPU/Memory by Node** : CPU et mémoire par nœud
- **Network I/O** : Trafic réseau
- **Slurm Jobs** : Jobs Slurm en cours
- **Slurm Partitions** : Partitions Slurm

#### Applications
- **Redis** : Métriques Redis
- **RabbitMQ** : Métriques RabbitMQ
- **Kafka** : Métriques Kafka
- **PostgreSQL** : Métriques PostgreSQL
- **MongoDB** : Métriques MongoDB
- **Nginx** : Métriques Nginx
- Et 20+ autres...

#### Sécurité
- **Security Advanced** : Sécurité avancée
- **Compliance** : Conformité
- **Vulnerabilities** : Vulnérabilités
- **Network Security** : Sécurité réseau
- **Container Security** : Sécurité containers
- **Audit Trail** : Piste d'audit

#### Monitoring
- **Monitoring Applications** : Monitoring applications
- **Monitoring Big Data** : Monitoring Big Data
- **Monitoring ML** : Monitoring Machine Learning

---

## 4. Ajouter un Agent de Monitoring

### 4.1 Sur un Nouveau Nœud

**Étape 1 : Installer Telegraf**

```bash
# Sur le nouveau nœud
./scripts/monitoring/install-telegraf.sh
```

**Étape 2 : Configurer Telegraf**

```bash
# Copier configuration
cp configs/telegraf/telegraf-slave.conf /etc/telegraf/telegraf.conf

# Ou pour frontal
cp configs/telegraf/telegraf-frontal.conf /etc/telegraf/telegraf.conf
```

**Étape 3 : Démarrer Telegraf**

```bash
systemctl enable telegraf
systemctl start telegraf
```

**Étape 4 : Ajouter à Prometheus**

Éditer `configs/prometheus/prometheus.yml` :

```yaml
scrape_configs:
  # Nouveau nœud
  - job_name: 'new-node-telegraf'
    static_configs:
      - targets: ['172.20.0.XXX:9273']
        labels:
          role: 'compute'
          node: 'new-node'
          instance: 'new-node-telegraf'
    scrape_interval: 15s
    metrics_path: '/metrics'
```

**Étape 5 : Redémarrer Prometheus**

```bash
# Si Docker
docker-compose -f docker/docker-compose-opensource.yml restart prometheus

# Ou reload
curl -X POST http://localhost:9090/-/reload
```

**Étape 6 : Vérifier**

```bash
# Vérifier métriques
curl http://172.20.0.XXX:9273/metrics

# Vérifier dans Prometheus
http://localhost:9090
# Requête : up{job="new-node-telegraf"}
```

---

### 4.2 Ajouter Node Exporter

**Étape 1 : Installer Node Exporter**

```bash
# Sur le nouveau nœud
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xzf node_exporter-1.7.0.linux-amd64.tar.gz
cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
```

**Étape 2 : Créer service systemd**

```bash
cat > /etc/systemd/system/node-exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=node_exporter
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable node-exporter
systemctl start node-exporter
```

**Étape 3 : Ajouter à Prometheus**

Éditer `configs/prometheus/prometheus.yml` :

```yaml
scrape_configs:
  - job_name: 'new-node-node'
    static_configs:
      - targets: ['172.20.0.XXX:9100']
        labels:
          role: 'compute'
          node: 'new-node'
          instance: 'new-node-node'
```

**Étape 4 : Redémarrer Prometheus**

```bash
curl -X POST http://localhost:9090/-/reload
```

---

## 5. Modifier les Dashboards

### 5.1 Via Interface Grafana

**Étape 1 : Accéder au Dashboard**

1. Aller sur http://localhost:3000
2. Dashboards → Sélectionner un dashboard
3. Cliquer sur "Edit" (icône crayon)

**Étape 2 : Modifier un Panel**

1. Cliquer sur le titre du panel
2. Edit
3. Modifier la requête PromQL
4. Sauvegarder

**Étape 3 : Ajouter un Panel**

1. Add → Panel
2. Choisir visualisation (Graph, Stat, Table, etc.)
3. Requête PromQL
4. Sauvegarder

**Étape 4 : Sauvegarder le Dashboard**

1. Save dashboard
2. Nom, tags, etc.

---

### 5.2 Via Fichiers JSON

**Étape 1 : Exporter Dashboard**

1. Dashboard → Settings → JSON Model
2. Copier le JSON
3. Sauvegarder dans `grafana-dashboards/my-dashboard.json`

**Étape 2 : Modifier le JSON**

Éditer `grafana-dashboards/my-dashboard.json` :

```json
{
  "dashboard": {
    "title": "My Dashboard",
    "panels": [
      {
        "title": "CPU Usage",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
          }
        ]
      }
    ]
  }
}
```

**Étape 3 : Importer**

1. Grafana → Dashboards → Import
2. Upload JSON file
3. Sélectionner `grafana-dashboards/my-dashboard.json`
4. Import

---

## 6. Monitoring Hardware

### 6.1 Métriques Collectées

**Node Exporter** collecte automatiquement :
- **CPU** : Utilisation, température (si disponible)
- **Mémoire** : RAM totale, disponible, utilisée, swap
- **Disque** : Espace, I/O (read/write)
- **Réseau** : Trafic (bytes in/out), paquets, erreurs
- **Système** : Load average, uptime, processus

**Accès** :
```bash
# Métriques brutes
curl http://172.20.0.101:9100/metrics

# Dans Prometheus
node_cpu_seconds_total
node_memory_MemTotal_bytes
node_filesystem_size_bytes
node_network_receive_bytes_total
```

**Dashboard** : "CPU/Memory by Node" dans Grafana

---

### 6.2 Ajouter Monitoring Hardware Spécifique

**Exemple : Monitoring GPU**

```bash
# Installer nvidia-smi exporter
./scripts/monitoring/install-nvidia-exporter.sh

# Ajouter à Prometheus
# configs/prometheus/prometheus.yml
- job_name: 'gpu'
  static_configs:
    - targets: ['172.20.0.101:9400']
```

---

## 7. Monitoring Réseau

### 7.1 Métriques Collectées

**Telegraf** collecte automatiquement :
- **Trafic** : Bytes reçus/envoyés
- **Paquets** : Paquets reçus/envoyés
- **Erreurs** : Erreurs réseau
- **Connexions** : TCP, UDP

**Accès** :
```bash
# Métriques brutes
curl http://172.20.0.101:9273/metrics | grep network

# Dans Prometheus
node_network_receive_bytes_total
node_network_transmit_bytes_total
node_network_receive_packets_total
```

**Dashboard** : "Network I/O" dans Grafana

---

### 7.2 Monitoring Réseau Avancé

**Exemple : Monitoring InfiniBand**

```bash
# Installer InfiniBand exporter
./scripts/monitoring/install-ib-exporter.sh

# Ajouter à Prometheus
# configs/prometheus/prometheus.yml
- job_name: 'infiniband'
  static_configs:
    - targets: ['172.20.0.101:9415']
```

---

## 8. Alertes

### 8.1 Configuration des Alertes

**Fichier** : `configs/prometheus/alerts.yml`

**Exemple d'alerte** :
```yaml
groups:
  - name: hpc_cluster_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU élevée sur {{ $labels.instance }}"
          description: "CPU: {{ $value }}%"
```

**Ajouter une alerte** :
1. Éditer `configs/prometheus/alerts.yml`
2. Ajouter la règle
3. Reload Prometheus : `curl -X POST http://localhost:9090/-/reload`

---

### 8.2 Alertes dans Grafana

**Créer une alerte** :
1. Dashboard → Panel → Edit
2. Alert tab
3. Créer condition
4. Notifications (email, webhook, etc.)

---

## 📚 Documentation Complémentaire

- `docs/GUIDE_MONITORING_COMPLET.md` - Monitoring complet
- `docs/GUIDE_DASHBOARDS_GRAFANA.md` - Dashboards Grafana
- `docs/GUIDE_MONITORING_APPLICATIONS.md` - Monitoring applications

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
