# Guide Monitoring Complet - Cluster HPC
## Guide Exhaustif du Monitoring

**Classification**: Documentation Monitoring  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Monitoring Applications](#monitoring-applications)
2. [Monitoring Infrastructure](#monitoring-infrastructure)
3. [Monitoring Performance](#monitoring-performance)

---

## 📊 Monitoring Applications

### Bases de Données
- **PostgreSQL**: `scripts/monitoring/monitor-postgresql.sh`
- **MongoDB**: `scripts/monitoring/monitor-mongodb.sh`
- **InfluxDB**: `scripts/monitoring/monitor-influxdb.sh`
- **ClickHouse**: `scripts/monitoring/monitor-clickhouse.sh`
- **Redis**: `scripts/monitoring/monitor-redis.sh`

### Messaging
- **RabbitMQ**: `scripts/monitoring/monitor-rabbitmq.sh`
- **Kafka**: `scripts/monitoring/monitor-kafka.sh`

### Web/Services
- **Nginx**: `scripts/monitoring/monitor-nginx.sh`
- **Traefik**: `scripts/monitoring/monitor-traefik.sh`
- **GitLab**: `scripts/monitoring/monitor-gitlab.sh`

### Sécurité
- **Vault**: `scripts/monitoring/monitor-vault.sh`
- **Consul**: `scripts/monitoring/monitor-consul.sh`

### Stockage
- **MinIO**: `scripts/monitoring/monitor-minio.sh`
- **Ceph**: `scripts/monitoring/monitor-ceph.sh`
- **GlusterFS**: `scripts/monitoring/monitor-glusterfs.sh`

### CI/CD
- **SonarQube**: `scripts/monitoring/monitor-sonarqube.sh`
- **Artifactory**: `scripts/monitoring/monitor-artifactory.sh`
- **Harbor**: `scripts/monitoring/monitor-harbor.sh`

### Orchestration
- **Kubernetes**: `scripts/monitoring/monitor-kubernetes.sh`
- **Istio**: `scripts/monitoring/monitor-istio.sh`

### Big Data & ML
- **Spark**: `scripts/monitoring/monitor-spark.sh`
- **Hadoop**: `scripts/monitoring/monitor-hadoop.sh`
- **TensorFlow**: `scripts/monitoring/monitor-tensorflow.sh`
- **PyTorch**: `scripts/monitoring/monitor-pytorch.sh`

### HPC
- **JupyterHub**: `scripts/monitoring/monitor-jupyterhub.sh`
- **Spack**: `scripts/monitoring/monitor-spack.sh`
- **Nexus**: `scripts/monitoring/monitor-nexus.sh`
- **Apptainer**: `scripts/monitoring/monitor-apptainer.sh`

---

## 🚀 Installation

### Installation Tous les Monitoring

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
