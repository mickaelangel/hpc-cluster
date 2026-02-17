# Guide de Monitoring Avancé - Cluster HPC
## Dashboards et Alertes Avancés

**Classification**: Documentation Technique  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Dashboards Grafana](#dashboards-grafana)
3. [Alertes Prometheus](#alertes-prometheus)
4. [Métriques Personnalisées](#métriques-personnalisées)
5. [Optimisation](#optimisation)

---

## 🎯 Vue d'ensemble

Ce guide explique comment utiliser les dashboards et alertes avancés pour le monitoring du cluster HPC.

### Dashboards Disponibles

- **HPC Cluster Overview** : Vue d'ensemble du cluster
- **Network I/O** : Statistiques réseau
- **Security Dashboard** : Monitoring sécurité
- **Performance Dashboard** : Performance du cluster

---

## 📊 Dashboards Grafana

### Security Dashboard

**Fichier** : `monitoring/grafana/dashboards/security.json`

**Métriques** :
- SSH Failed Login Attempts
- Fail2ban Banned IPs
- Auditd Events
- AIDE Integrity Checks
- Kerberos Failed Authentications
- LDAP Failed Bind Attempts

**Import** :
```bash
# Via interface Grafana
1. Grafana > Dashboards > Import
2. Uploader security.json
3. Configurer la datasource Prometheus
```

### Performance Dashboard

**Fichier** : `monitoring/grafana/dashboards/performance.json`

**Métriques** :
- CPU Usage by Node
- Memory Usage by Node
- Network I/O
- Disk I/O
- Slurm Job Throughput
- GPFS I/O Performance

**Import** :
```bash
# Via interface Grafana
1. Grafana > Dashboards > Import
2. Uploader performance.json
3. Configurer la datasource Prometheus
```

---

## 🚨 Alertes Prometheus

### Configuration

**Fichier** : `monitoring/prometheus/alerts-advanced.yml`

**Alertes Configurées** :

1. **Sécurité** :
   - High SSH Failed Logins
   - Fail2ban Banned IPs

2. **Performance** :
   - High CPU Usage (>90%)
   - High Memory Usage (>90%)
   - Low Disk Space (<10%)

3. **Services** :
   - Slurm Controller Down
   - High Job Failure Rate
   - GPFS Down
   - LDAP Down
   - Kerberos Down

### Activation

```bash
# Ajouter dans prometheus.yml
rule_files:
  - "alerts-advanced.yml"

# Redémarrer Prometheus
systemctl restart prometheus
```

---

## 📈 Métriques Personnalisées

### Exemple : Métrique Slurm

```yaml
# Telegraf configuration
[[inputs.exec]]
  commands = ["/usr/local/bin/slurm-metrics.sh"]
  name_override = "slurm"
  data_format = "influx"
```

### Script de Collecte

```bash
#!/bin/bash
# slurm-metrics.sh
JOBS_RUNNING=$(squeue -h -t R | wc -l)
JOBS_PENDING=$(squeue -h -t PD | wc -l)
echo "slurm,jobs=running value=$JOBS_RUNNING"
echo "slurm,jobs=pending value=$JOBS_PENDING"
```

---

## 🔧 Optimisation

### Réduction de la Charge

1. **Réduire la fréquence de collecte** :
   ```yaml
   scrape_interval: 30s  # Au lieu de 15s
   ```

2. **Filtrer les métriques** :
   ```yaml
   metric_relabel_configs:
     - source_labels: [__name__]
       regex: '.*_total'
       action: drop
   ```

3. **Rétention réduite** :
   ```yaml
   retention: 7d  # Au lieu de 30d
   ```

---

## 📚 Ressources

- **Grafana Documentation** : https://grafana.com/docs/
- **Prometheus Documentation** : https://prometheus.io/docs/
- **Telegraf Documentation** : https://docs.influxdata.com/telegraf/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
