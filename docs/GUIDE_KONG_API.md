# Guide Kong API Gateway - Cluster HPC
## Gestion API Centralisée

**Classification**: Documentation Intégration  
**Public**: Administrateurs / Développeurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation Kong](#installation-kong)
3. [Configuration](#configuration)
4. [Services et Routes](#services-et-routes)
5. [Plugins](#plugins)
6. [Utilisation](#utilisation)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**Kong** : API Gateway open-source qui gère, sécurise et surveille les APIs.

### Bénéfices

- ✅ **Gestion centralisée** : Toutes les APIs au même endroit
- ✅ **Authentification unifiée** : OAuth, JWT, API Keys
- ✅ **Rate limiting** : Protection contre surcharge
- ✅ **Monitoring** : Métriques et logs

---

## 🚀 Installation Kong

### Installation

```bash
./scripts/api/install-kong.sh
```

### Architecture

```
Clients
    │
    └─► Kong API Gateway (localhost:8000)
            │
            ├─► Prometheus (localhost:9090)
            ├─► Grafana (localhost:3000)
            ├─► Jaeger (localhost:16686)
            └─► Autres services
```

### Vérification

```bash
# Vérifier Kong
curl http://localhost:8001/status

# Vérifier Admin API
curl http://localhost:8001/
```

---

## ⚙️ Configuration

### Services

**Créer un service** :
```bash
curl -i -X POST http://localhost:8001/services/ \
  --data "name=prometheus" \
  --data "url=http://prometheus:9090"
```

**Lister services** :
```bash
curl http://localhost:8001/services/
```

### Routes

**Créer une route** :
```bash
curl -i -X POST http://localhost:8001/services/prometheus/routes \
  --data "hosts[]=prometheus.cluster.local" \
  --data "paths[]=/prometheus"
```

**Lister routes** :
```bash
curl http://localhost:8001/routes/
```

---

## 🔗 Services et Routes

### Configuration Complète

**Script exemple** : `/tmp/kong-config-example.sh`

```bash
#!/bin/bash
KONG_ADMIN="http://localhost:8001"

# Service Prometheus
curl -i -X POST "$KONG_ADMIN/services/" \
  --data "name=prometheus" \
  --data "url=http://prometheus:9090"

curl -i -X POST "$KONG_ADMIN/services/prometheus/routes" \
  --data "hosts[]=prometheus.cluster.local" \
  --data "paths[]=/prometheus"

# Service Grafana
curl -i -X POST "$KONG_ADMIN/services/" \
  --data "name=grafana" \
  --data "url=http://grafana:3000"

curl -i -X POST "$KONG_ADMIN/services/grafana/routes" \
  --data "hosts[]=grafana.cluster.local" \
  --data "paths[]=/grafana"
```

---

## 🔌 Plugins

### Rate Limiting

**Activer rate limiting** :
```bash
curl -i -X POST http://localhost:8001/services/prometheus/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.hour=1000"
```

### Authentication

**API Key Authentication** :
```bash
# Activer plugin
curl -i -X POST http://localhost:8001/services/prometheus/plugins \
  --data "name=key-auth"

# Créer consumer
curl -i -X POST http://localhost:8001/consumers/ \
  --data "username=admin"

# Créer API key
curl -i -X POST http://localhost:8001/consumers/admin/key-auth \
  --data "key=secret-key-123"
```

### CORS

**Activer CORS** :
```bash
curl -i -X POST http://localhost:8001/services/prometheus/plugins \
  --data "name=cors" \
  --data "config.origins=*" \
  --data "config.methods=GET,POST,PUT,DELETE"
```

---

## 📊 Utilisation

### Accès via Kong

**Avant Kong** :
```bash
curl http://prometheus:9090/api/v1/query?query=up
```

**Avec Kong** :
```bash
curl http://localhost:8000/prometheus/api/v1/query?query=up \
  -H "Host: prometheus.cluster.local"
```

### Monitoring

**Métriques Kong** :
```bash
# Métriques Prometheus
curl http://localhost:8001/metrics

# Statistiques
curl http://localhost:8001/status
```

---

## 🔧 Dépannage

### Problèmes Courants

**Kong ne démarre pas** :
```bash
# Vérifier logs
docker logs kong

# Vérifier base de données
docker exec -it kong-database psql -U kong -d kong
```

**Routes non accessibles** :
```bash
# Vérifier routes
curl http://localhost:8001/routes/

# Vérifier services
curl http://localhost:8001/services/
```

**Plugins non actifs** :
```bash
# Vérifier plugins
curl http://localhost:8001/plugins/

# Vérifier configuration
curl http://localhost:8001/plugins/<plugin-id>
```

---

## 📚 Documentation Complémentaire

- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé
- `GUIDE_SECURITE.md` - Sécurité
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
