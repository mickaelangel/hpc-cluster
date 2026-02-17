# Guide Monitoring Applications - Cluster HPC
## Monitoring de Toutes les Applications

**Classification**: Documentation Monitoring  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Monitoring Bases de Données](#monitoring-bases-de-données)
2. [Monitoring Messaging](#monitoring-messaging)
3. [Monitoring Web/Services](#monitoring-webservices)
4. [Monitoring Sécurité](#monitoring-sécurité)
5. [Monitoring Stockage](#monitoring-stockage)
6. [Monitoring CI/CD](#monitoring-cicd)
7. [Monitoring Orchestration](#monitoring-orchestration)
8. [Monitoring Big Data & ML](#monitoring-big-data--ml)
9. [Monitoring HPC](#monitoring-hpc)

---

## 💾 Monitoring Bases de Données

### PostgreSQL
```bash
./scripts/monitoring/monitor-postgresql.sh
```
**Dashboard**: `grafana-dashboards/postgresql.json`

### MongoDB
```bash
./scripts/monitoring/monitor-mongodb.sh
```
**Dashboard**: `grafana-dashboards/mongodb.json`

### InfluxDB
```bash
./scripts/monitoring/monitor-influxdb.sh
```
**Dashboard**: `grafana-dashboards/influxdb.json`

### ClickHouse
```bash
./scripts/monitoring/monitor-clickhouse.sh
```
**Dashboard**: `grafana-dashboards/clickhouse.json`

### Redis
```bash
./scripts/monitoring/monitor-redis.sh
```
**Dashboard**: `grafana-dashboards/redis.json`

### Elasticsearch
```bash
./scripts/monitoring/monitor-elasticsearch.sh
```
**Dashboard**: `grafana-dashboards/elasticsearch.json`

---

## 📨 Monitoring Messaging

### RabbitMQ
```bash
./scripts/monitoring/monitor-rabbitmq.sh
```
**Dashboard**: `grafana-dashboards/rabbitmq.json`

### Kafka
```bash
./scripts/monitoring/monitor-kafka.sh
```
**Dashboard**: `grafana-dashboards/kafka.json`

---

## 🌐 Monitoring Web/Services

### Nginx
```bash
./scripts/monitoring/monitor-nginx.sh
```
**Dashboard**: `grafana-dashboards/nginx.json`

### Traefik
```bash
./scripts/monitoring/monitor-traefik.sh
```
**Dashboard**: `grafana-dashboards/traefik.json`

### GitLab
```bash
./scripts/monitoring/monitor-gitlab.sh
```
**Dashboard**: `grafana-dashboards/gitlab.json`

---

## 🔒 Monitoring Sécurité

### Vault
```bash
./scripts/monitoring/monitor-vault.sh
```
**Dashboard**: `grafana-dashboards/vault.json`

### Consul
```bash
./scripts/monitoring/monitor-consul.sh
```
**Dashboard**: `grafana-dashboards/consul.json`

---

## 💿 Monitoring Stockage

### MinIO
```bash
./scripts/monitoring/monitor-minio.sh
```
**Dashboard**: `grafana-dashboards/minio.json`

### Ceph
```bash
./scripts/monitoring/monitor-ceph.sh
```
**Dashboard**: `grafana-dashboards/ceph.json`

### GlusterFS
```bash
./scripts/monitoring/monitor-glusterfs.sh
```
**Dashboard**: `grafana-dashboards/glusterfs.json`

---

## 🔄 Monitoring CI/CD

### SonarQube
```bash
./scripts/monitoring/monitor-sonarqube.sh
```
**Dashboard**: `grafana-dashboards/sonarqube.json`

### Artifactory
```bash
./scripts/monitoring/monitor-artifactory.sh
```
**Dashboard**: `grafana-dashboards/artifactory.json`

### Harbor
```bash
./scripts/monitoring/monitor-harbor.sh
```
**Dashboard**: `grafana-dashboards/harbor.json`

---

## ☸️ Monitoring Orchestration

### Kubernetes
```bash
./scripts/monitoring/monitor-kubernetes.sh
```
**Dashboard**: `grafana-dashboards/kubernetes.json`

### Istio
```bash
./scripts/monitoring/monitor-istio.sh
```
**Dashboard**: `grafana-dashboards/istio.json`

---

## 📊 Monitoring Big Data & ML

### Spark
```bash
./scripts/monitoring/monitor-spark.sh
```
**Dashboard**: `grafana-dashboards/spark.json`

### Hadoop
```bash
./scripts/monitoring/monitor-hadoop.sh
```
**Dashboard**: `grafana-dashboards/hadoop.json`

### TensorFlow
```bash
./scripts/monitoring/monitor-tensorflow.sh
```
**Dashboard**: `grafana-dashboards/tensorflow.json`

### PyTorch
```bash
./scripts/monitoring/monitor-pytorch.sh
```
**Dashboard**: `grafana-dashboards/pytorch.json`

---

## 🖥️ Monitoring HPC

### JupyterHub
```bash
./scripts/monitoring/monitor-jupyterhub.sh
```
**Dashboard**: `grafana-dashboards/jupyterhub.json`

### Spack
```bash
./scripts/monitoring/monitor-spack.sh
```
**Dashboard**: `grafana-dashboards/spack.json`

### Nexus
```bash
./scripts/monitoring/monitor-nexus.sh
```
**Dashboard**: `grafana-dashboards/nexus.json`

### Apptainer
```bash
./scripts/monitoring/monitor-apptainer.sh
```
**Dashboard**: `grafana-dashboards/apptainer.json`

---

## 🚀 Installation Automatique

### Setup Tous les Monitoring

```bash
./scripts/automation/setup-all-monitoring.sh
```

### Configuration Cron

```bash
./scripts/automation/setup-cron-all-monitoring.sh
```

---

## 📊 Dashboards Grafana

**40+ dashboards** disponibles pour toutes les applications.

**Accès**: http://frontal-01:3000

---

**Version**: 1.0
