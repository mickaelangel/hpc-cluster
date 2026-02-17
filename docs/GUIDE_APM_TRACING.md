# Guide APM (Application Performance Monitoring) - Cluster HPC
## Jaeger et OpenTelemetry

**Classification**: Documentation Monitoring  
**Public**: Administrateurs / Développeurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Jaeger (Distributed Tracing)](#jaeger-distributed-tracing)
3. [OpenTelemetry (Standard Observabilité)](#opentelemetry-standard-observabilité)
4. [Configuration](#configuration)
5. [Utilisation](#utilisation)
6. [Intégration Applications](#intégration-applications)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**APM (Application Performance Monitoring)** : Surveillance des performances des applications pour identifier les goulots d'étranglement et optimiser les performances.

### Composants

1. **Jaeger** : Distributed tracing
   - Traçage des requêtes
   - Visualisation des traces
   - Analyse des performances

2. **OpenTelemetry** : Standard observabilité
   - Collecte métriques, logs, traces
   - Intégration avec Prometheus, Jaeger
   - Instrumentation automatique

---

## 🔍 Jaeger (Distributed Tracing)

### Qu'est-ce que Jaeger ?

**Jaeger** est un système de traçage distribué open-source qui suit les requêtes à travers plusieurs services.

### Installation

```bash
./scripts/monitoring/install-jaeger.sh
```

### Architecture

```
Application
    │
    ├─► OpenTelemetry Collector
    │       │
    │       └─► Jaeger Backend
    │               │
    │               └─► Jaeger UI (http://localhost:16686)
```

### Configuration

**Docker Compose** :
```yaml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"  # UI
      - "14268:14268"  # HTTP
      - "6831:6831/udp"  # UDP
```

### Utilisation

**Interface Web** : http://localhost:16686

**Fonctionnalités** :
- Recherche de traces
- Visualisation des spans
- Analyse des performances
- Détection des erreurs

---

## 📊 OpenTelemetry (Standard Observabilité)

### Qu'est-ce qu'OpenTelemetry ?

**OpenTelemetry** est un standard open-source pour l'observabilité qui collecte métriques, logs et traces.

### Installation

```bash
./scripts/monitoring/install-opentelemetry.sh
```

### Architecture

```
Applications
    │
    ├─► OpenTelemetry Collector
    │       │
    │       ├─► Prometheus (métriques)
    │       ├─► Jaeger (traces)
    │       └─► Loki (logs)
```

### Configuration

**Fichier** : `/opt/otelcol/config.yaml`

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  jaeger:
    endpoint: localhost:14250

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [jaeger]
    metrics:
      receivers: [otlp]
      exporters: [prometheus]
```

### Utilisation

**Endpoints** :
- OTLP gRPC : `localhost:4317`
- OTLP HTTP : `localhost:4318`
- Prometheus : `localhost:8889`

---

## ⚙️ Configuration

### Intégration avec Applications

**Python** :
```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider

trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)
```

**Slurm Jobs** :
```bash
#SBATCH --job-name=trace-job
#SBATCH --time=01:00:00

# Instrumentation automatique
export OTEL_SERVICE_NAME=slurm-job
export OTEL_EXPORTER_JAEGER_ENDPOINT=http://localhost:14268/api/traces

# Exécuter job
./mon_application
```

---

## 📊 Utilisation

### Visualisation Traces

**Jaeger UI** :
1. Ouvrir http://localhost:16686
2. Sélectionner service
3. Rechercher traces
4. Analyser spans

### Métriques OpenTelemetry

**Prometheus** :
```promql
# Latence moyenne
rate(otel_trace_duration_seconds_sum[5m])

# Taux d'erreur
rate(otel_trace_errors_total[5m])
```

### Dashboards Grafana

Dashboards disponibles :
- Traces par service
- Latence par opération
- Taux d'erreur
- Throughput

---

## 🔗 Intégration Applications

### GROMACS

```bash
# Instrumentation GROMACS
export OTEL_SERVICE_NAME=gromacs
export OTEL_EXPORTER_JAEGER_ENDPOINT=http://localhost:14268/api/traces

gmx mdrun -s topol.tpr
```

### OpenFOAM

```bash
# Instrumentation OpenFOAM
export OTEL_SERVICE_NAME=openfoam
export OTEL_EXPORTER_JAEGER_ENDPOINT=http://localhost:14268/api/traces

simpleFoam
```

---

## 🔧 Dépannage

### Problèmes Courants

**Jaeger ne reçoit pas de traces** :
```bash
# Vérifier connexion
curl http://localhost:14268/api/traces

# Vérifier logs
docker logs jaeger
```

**OpenTelemetry Collector ne démarre pas** :
```bash
# Vérifier configuration
/opt/otelcol/otelcol-contrib --config=/opt/otelcol/config.yaml --dry-run

# Vérifier logs
journalctl -u otelcol -f
```

**Traces manquantes** :
```bash
# Vérifier instrumentation
export OTEL_LOG_LEVEL=debug

# Vérifier export
curl http://localhost:8889/metrics
```

---

## 📚 Documentation Complémentaire

- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé
- `GUIDE_DASHBOARDS_GRAFANA.md` - Dashboards Grafana
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
