# Guide des Dashboards Grafana - Cluster HPC
## Tous les Dashboards Disponibles

**Classification**: Documentation Monitoring  
**Public**: Tous les Utilisateurs  
**Version**: 1.0  
**Date**: 2024

---

## ✅ Dashboards Disponibles

Le cluster HPC dispose de **4 dashboards Grafana** pré-configurés :

1. **HPC Cluster Overview** - Vue d'ensemble du cluster
2. **Network I/O** - Performance réseau
3. **Performance** - Performance générale
4. **Security** - Monitoring sécurité

---

## 📊 Dashboard 1 : HPC Cluster Overview

**Fichier** : `grafana-dashboards/hpc-cluster-overview.json`

**Contenu** :
- ✅ **État des nœuds** : Statut UP/DOWN de tous les nœuds
- ✅ **Utilisation CPU** : Par nœud
- ✅ **Utilisation mémoire** : Par nœud
- ✅ **Jobs Slurm** : Jobs en cours, en attente, terminés
- ✅ **Utilisation disque** : Par nœud
- ✅ **Réseau** : Trafic réseau par nœud

**Métriques** :
- `up{job=~'.*-node'}` - État des nœuds
- `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` - CPU
- `node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes` - Mémoire
- `slurm_jobs_running` - Jobs en cours
- `slurm_jobs_pending` - Jobs en attente

**Accès** :
- URL : http://frontal-01:3000
- Dashboard : "HPC Cluster Overview"
- Refresh : 10 secondes

---

## 📊 Dashboard 2 : Network I/O

**Fichier** : `grafana-dashboards/network-io.json`

**Contenu** :
- ✅ **Trafic réseau entrant** : Par interface et nœud
- ✅ **Trafic réseau sortant** : Par interface et nœud
- ✅ **Erreurs réseau** : Par interface
- ✅ **Paquets** : Par interface
- ✅ **Bande passante** : Utilisation par nœud

**Métriques** :
- `rate(node_network_receive_bytes_total[5m])` - Trafic entrant
- `rate(node_network_transmit_bytes_total[5m])` - Trafic sortant
- `rate(node_network_receive_errs_total[5m])` - Erreurs entrantes
- `rate(node_network_transmit_errs_total[5m])` - Erreurs sortantes

**Accès** :
- URL : http://frontal-01:3000
- Dashboard : "Network I/O"
- Refresh : 10 secondes

---

## 📊 Dashboard 3 : Performance

**Fichier** : `grafana-dashboards/performance.json`

**Contenu** :
- ✅ **Performance CPU** : Par nœud et global
- ✅ **Performance mémoire** : Par nœud et global
- ✅ **Performance I/O** : Disque par nœud
- ✅ **Performance réseau** : Par nœud
- ✅ **Latence** : Par service
- ✅ **Throughput** : Par service

**Métriques** :
- CPU : Utilisation, load average
- Mémoire : Utilisation, swap
- I/O : Read/write, IOPS
- Réseau : Bande passante, latence

**Accès** :
- URL : http://frontal-01:3000
- Dashboard : "Performance"
- Refresh : 10 secondes

---

## 📊 Dashboard 4 : Security

**Fichier** : `grafana-dashboards/security.json`

**Contenu** :
- ✅ **Tentatives de connexion** : SSH, authentification
- ✅ **Échecs d'authentification** : Par utilisateur
- ✅ **IPs bannies** : Fail2ban
- ✅ **Audit** : Événements auditd
- ✅ **Intégrité** : AIDE alerts
- ✅ **Connexions actives** : Par utilisateur

**Métriques** :
- `fail2ban_banned_total` - IPs bannies
- `auditd_events_total` - Événements audit
- `ssh_login_attempts_total` - Tentatives SSH
- `aide_integrity_checks_total` - Vérifications AIDE

**Accès** :
- URL : http://frontal-01:3000
- Dashboard : "Security"
- Refresh : 30 secondes

---

## 🚀 Installation et Configuration

### Configuration Automatique

Les dashboards sont **automatiquement chargés** via le provisioning Grafana :

**Fichier** : `monitoring/grafana/provisioning/dashboards/default.yml`

```yaml
apiVersion: 1
providers:
  - name: 'HPC Dashboards'
    orgId: 1
    folder: 'HPC Monitoring'
    type: file
    options:
      path: /var/lib/grafana/dashboards
```

### Installation Manuelle

Si nécessaire, importer manuellement :

1. **Accéder à Grafana** : http://frontal-01:3000
2. **Login** : admin / admin (changer au premier accès)
3. **Importer** :
   - Menu : Dashboards → Import
   - Upload JSON : Sélectionner fichier depuis `grafana-dashboards/`
   - Cliquer "Import"

---

## 📋 Utilisation

### Accès aux Dashboards

**Via Interface Web** :
```
http://frontal-01:3000
```

**Login** :
- Utilisateur : `admin`
- Mot de passe : `admin` (changer au premier accès)

**Navigation** :
- Menu : Dashboards → HPC Monitoring
- Sélectionner le dashboard souhaité

### Personnalisation

**Modifier un Dashboard** :
1. Ouvrir le dashboard
2. Cliquer sur l'icône ⚙️ (Settings)
3. Modifier les panels
4. Sauvegarder

**Créer un Nouveau Dashboard** :
1. Menu : Dashboards → New Dashboard
2. Ajouter panels
3. Configurer métriques Prometheus
4. Sauvegarder

---

## 📊 Métriques Disponibles

### Prometheus

**Système** :
- `node_cpu_seconds_total` - CPU
- `node_memory_*` - Mémoire
- `node_disk_*` - Disque
- `node_network_*` - Réseau

**Slurm** :
- `slurm_jobs_running` - Jobs en cours
- `slurm_jobs_pending` - Jobs en attente
- `slurm_jobs_completed` - Jobs terminés
- `slurm_nodes_up` - Nœuds UP

**Services** :
- `up{job="prometheus"}` - État Prometheus
- `up{job="grafana"}` - État Grafana
- `up{job="influxdb"}` - État InfluxDB

### InfluxDB (via Telegraf)

**Système** :
- `cpu` - CPU
- `mem` - Mémoire
- `disk` - Disque
- `net` - Réseau

**Slurm** :
- `slurm_jobs` - Jobs
- `slurm_nodes` - Nœuds

---

## 🔧 Configuration

### Datasources

**Prometheus** :
- URL : http://prometheus:9090
- Type : Prometheus

**InfluxDB** :
- URL : http://influxdb:8086
- Type : InfluxDB
- Database : hpc-metrics

**Configuration** : `monitoring/grafana/provisioning/datasources/prometheus.yml`

---

## 📚 Exemples de Requêtes PromQL

### CPU Utilisation
```promql
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Mémoire Utilisation
```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

### Jobs Slurm
```promql
slurm_jobs_running
slurm_jobs_pending
```

### Réseau
```promql
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

---

## ✅ Checklist

### Vérification

- [ ] Grafana accessible : http://frontal-01:3000
- [ ] Dashboards visibles dans menu
- [ ] Métriques affichées correctement
- [ ] Datasources configurées (Prometheus, InfluxDB)
- [ ] Refresh automatique activé

### Personnalisation

- [ ] Dashboards personnalisés créés
- [ ] Alertes configurées
- [ ] Notifications configurées
- [ ] Utilisateurs créés

---

## 🎯 Résumé

**4 Dashboards Disponibles** :
1. ✅ HPC Cluster Overview - Vue d'ensemble
2. ✅ Network I/O - Performance réseau
3. ✅ Performance - Performance générale
4. ✅ Security - Monitoring sécurité

**Tous les dashboards sont** :
- ✅ Pré-configurés
- ✅ Automatiquement chargés
- ✅ Prêts à l'emploi
- ✅ Personnalisables

**Accès** : http://frontal-01:3000

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
