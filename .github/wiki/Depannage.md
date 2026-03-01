# 🔧 Dépannage - Guide Complet

> **Guide de résolution de problèmes - Niveau DevOps Senior**

---

## Sommaire

- [Diagnostic système](#-diagnostic-système)
- [Problèmes courants](#-problèmes-courants) (services, métriques, Grafana, performances, ports)
- [Problèmes de sécurité](#-problèmes-de-sécurité)
- **Contexte** : En déploiement **Docker**, remplacer `systemctl` par `docker logs <conteneur>` et `docker exec` ; voir aussi [Troubleshooting](Troubleshooting) (10 cas réels avec commandes Docker).

---

## 🔍 Diagnostic Système

### Vérification Rapide

```bash
# Script de diagnostic automatique
./scripts/diagnostic.sh

# Vérification manuelle
./scripts/verify-installation.sh
```

### État des Services

```bash
# Vérifier tous les services
systemctl list-units --type=service --state=failed

# Services spécifiques
sudo systemctl status prometheus grafana influxdb slurmctld slurmd

# Services actifs
systemctl list-units --type=service --state=running | grep -E 'prometheus|grafana|influxdb'
```

---

## 🚨 Problèmes Courants

### 1. Service ne démarre pas

#### Symptômes
```
Failed to start Prometheus
```

#### Diagnostic

```bash
# 1. Vérifier les logs
sudo journalctl -u prometheus -n 50 --no-pager

# 2. Vérifier la configuration
sudo prometheus --config.file=/etc/prometheus/prometheus.yml --check-config

# 3. Vérifier les permissions
ls -la /var/lib/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# 4. Vérifier les ports
sudo lsof -i :9090
sudo netstat -tlnp | grep 9090
```

#### Solutions

**Solution 1 : Permissions incorrectes**
```bash
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chmod -R 755 /var/lib/prometheus
sudo systemctl restart prometheus
```

**Solution 2 : Port déjà utilisé**
```bash
# Identifier le processus
sudo lsof -i :9090

# Arrêter le processus ou changer le port
sudo systemctl stop SERVICE_USING_PORT
# Ou modifier /etc/prometheus/prometheus.yml
```

**Solution 3 : Configuration invalide**
```bash
# Vérifier la syntaxe
sudo prometheus --config.file=/etc/prometheus/prometheus.yml --check-config

# Corriger les erreurs indiquées
sudo nano /etc/prometheus/prometheus.yml
```

---

### 2. Métriques non collectées

#### Symptômes
- Dashboards Grafana vides
- Pas de données dans Prometheus
- Targets "down" dans Prometheus

#### Diagnostic

```bash
# 1. Vérifier les targets Prometheus
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[]'

# 2. Vérifier la connectivité
curl http://localhost:9100/metrics  # Node Exporter
curl http://localhost:9090/api/v1/query?query=up

# 3. Vérifier les logs
sudo journalctl -u node_exporter -f
sudo journalctl -u prometheus -f
```

#### Solutions

**Solution 1 : Node Exporter non démarré**
```bash
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

**Solution 2 : Firewall bloque les connexions**
```bash
# openSUSE/Firewalld
sudo firewall-cmd --add-port=9100/tcp --permanent
sudo firewall-cmd --reload

# Ubuntu/UFW
sudo ufw allow 9100/tcp
```

**Solution 3 : Configuration Prometheus incorrecte**
```yaml
# Vérifier /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

---

### 3. Grafana ne peut pas se connecter à Prometheus

#### Symptômes
- Erreur "Data source not found" dans Grafana
- Timeout lors de la connexion

#### Diagnostic

```bash
# 1. Vérifier que Prometheus est accessible
curl http://localhost:9090/api/v1/status/config

# 2. Vérifier la configuration Grafana
sudo cat /etc/grafana/grafana.ini | grep prometheus

# 3. Tester depuis Grafana
# Configuration > Data Sources > Prometheus > Test
```

#### Solutions

**Solution 1 : URL incorrecte dans Grafana**
```
Configuration > Data Sources > Prometheus
URL: http://localhost:9090
```

**Solution 2 : Prometheus non accessible**
```bash
# Vérifier que Prometheus écoute sur toutes les interfaces
# /etc/prometheus/prometheus.yml
# Ou vérifier le firewall
```

**Solution 3 : Problème de réseau**
```bash
# Tester la connectivité
telnet localhost 9090
curl http://localhost:9090/api/v1/status/config
```

---

### 4. Performance dégradée

#### Symptômes
- Interface Grafana lente
- Requêtes Prometheus lentes
- CPU/RAM élevés

#### Diagnostic

```bash
# 1. Vérifier les ressources
htop
free -h
df -h

# 2. Vérifier les processus
ps aux | grep -E 'prometheus|grafana|influxdb' | sort -k3 -r

# 3. Vérifier les logs d'erreur
sudo journalctl -u prometheus | grep -i error
sudo journalctl -u grafana | grep -i error
```

#### Solutions

**Solution 1 : Réduire la rétention Prometheus**
```yaml
# /etc/prometheus/prometheus.yml
global:
  retention: 15d  # Au lieu de 30d
```

**Solution 2 : Optimiser les requêtes Grafana**
- Utiliser des requêtes plus courtes
- Réduire la plage de temps
- Utiliser des règles d'enregistrement

**Solution 3 : Augmenter les limites système**
```bash
# Grafana
sudo systemctl edit grafana
# Ajouter :
[Service]
LimitNOFILE=65536
MemoryLimit=2G
```

**Solution 4 : Nettoyer les anciennes données**
```bash
# Prometheus
sudo systemctl stop prometheus
sudo rm -rf /var/lib/prometheus/data/*
sudo systemctl start prometheus
```

---

### 5. Ports déjà utilisés

#### Symptômes
```
Error: listen tcp :3000: bind: address already in use
```

#### Diagnostic

```bash
# Identifier le processus
sudo lsof -i :3000
sudo netstat -tlnp | grep 3000
sudo ss -tlnp | grep 3000
```

#### Solutions

**Solution 1 : Arrêter le service conflictuel**
```bash
# Identifier le PID
sudo lsof -i :3000

# Arrêter le processus
sudo kill -9 PID
# Ou
sudo systemctl stop SERVICE_NAME
```

**Solution 2 : Changer le port**
```ini
# Grafana /etc/grafana/grafana.ini
[server]
http_port = 3001  # Changer ici
```

**Solution 3 : Utiliser un autre port au démarrage**
```bash
# Grafana
grafana-server --config=/etc/grafana/grafana.ini --http-port=3001
```

---

## 🔐 Problèmes de Sécurité

### Authentification échoue

#### Diagnostic

```bash
# Vérifier les logs Grafana
sudo tail -f /var/log/grafana/grafana.log | grep -i auth

# Vérifier la configuration LDAP
sudo cat /etc/grafana/ldap.toml
```

#### Solutions

**Solution 1 : Réinitialiser le mot de passe admin**
```bash
# Via l'interface web
# Ou via base de données
sudo sqlite3 /var/lib/grafana/grafana.db
UPDATE user SET password = '...' WHERE login = 'admin';
```

**Solution 2 : Vérifier la configuration LDAP**
```toml
# /etc/grafana/ldap.toml
[[servers]]
host = "ldap.example.com"
port = 389
bind_dn = "cn=admin,dc=example,dc=com"
```

---

## 💾 Problèmes de Stockage

### Disque plein

#### Diagnostic

```bash
# Vérifier l'utilisation
df -h
du -sh /var/lib/prometheus/*
du -sh /var/lib/grafana/*
du -sh /var/lib/influxdb/*
```

#### Solutions

**Solution 1 : Nettoyer Prometheus**
```bash
# Réduire la rétention
# /etc/prometheus/prometheus.yml
retention: 7d  # Au lieu de 30d

# Ou supprimer manuellement
sudo systemctl stop prometheus
sudo rm -rf /var/lib/prometheus/data/old_blocks/*
sudo systemctl start prometheus
```

**Solution 2 : Nettoyer InfluxDB**
```bash
# Via CLI
influx delete \
  --bucket metrics \
  --start 2024-01-01T00:00:00Z \
  --stop 2024-01-31T23:59:59Z
```

**Solution 3 : Augmenter l'espace disque**
```bash
# Ajouter un disque
# Ou utiliser un volume externe
```

---

## 🌐 Problèmes Réseau

### Connexion impossible depuis l'extérieur

#### Diagnostic

```bash
# Vérifier le firewall
sudo firewall-cmd --list-all
sudo ufw status

# Vérifier les bind addresses
sudo netstat -tlnp | grep -E '3000|9090|8086'

# Tester la connectivité
curl http://localhost:3000
curl http://EXTERNAL_IP:3000
```

#### Solutions

**Solution 1 : Configurer le firewall**
```bash
# openSUSE/Firewalld
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload

# Ubuntu/UFW
sudo ufw allow 3000/tcp
sudo ufw allow 9090/tcp
```

**Solution 2 : Configurer l'écoute sur toutes les interfaces**
```ini
# Grafana /etc/grafana/grafana.ini
[server]
http_addr = 0.0.0.0  # Au lieu de 127.0.0.1
```

---

## 📊 Problèmes de Monitoring

### Dashboards ne s'affichent pas

#### Diagnostic

```bash
# Vérifier que les dashboards sont importés
curl -u admin:admin http://localhost:3000/api/dashboards/home

# Vérifier les permissions
ls -la /var/lib/grafana/dashboards/
```

#### Solutions

**Solution 1 : Réimporter les dashboards**
```bash
./scripts/import-grafana-dashboards.sh
```

**Solution 2 : Vérifier les permissions**
```bash
sudo chown -R grafana:grafana /var/lib/grafana/dashboards/
sudo chmod -R 755 /var/lib/grafana/dashboards/
```

---

## 🔄 Scripts de Diagnostic

### Script Complet

```bash
#!/bin/bash
# diagnostic-complete.sh

echo "=== Diagnostic Complet ==="

echo "1. Services"
systemctl list-units --type=service --state=failed

echo "2. Ports"
sudo netstat -tlnp | grep -E '3000|9090|8086|8000'

echo "3. Ressources"
free -h
df -h

echo "4. Prometheus Targets"
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .job, health: .health}'

echo "5. Logs récents"
sudo journalctl -u prometheus -n 10 --no-pager
sudo journalctl -u grafana -n 10 --no-pager
```

---

## 📚 Ressources

- **📖 [Installation Rapide](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Installation-Rapide.md)**
- **❓ [FAQ](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/FAQ.md)**
- **💡 [Astuces](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Astuces.md)**

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
