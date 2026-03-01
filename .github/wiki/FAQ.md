# ❓ FAQ - Questions Fréquentes

> **FAQ complète - Niveau DevOps Senior**

---

## 🚀 Installation

### Q : Combien de temps prend l'installation complète ?

**R :** L'installation automatique prend généralement **15-30 minutes** selon :
- La vitesse de connexion Internet
- Les performances du serveur
- Les composants sélectionnés

**Installation minimale** : ~10 minutes  
**Installation complète** : ~30 minutes

---

### Q : Quels sont les prérequis système ?

**R :** Prérequis minimaux :

- **OS** : openSUSE 15.6, Ubuntu 22.04+, CentOS/RHEL 8+, Debian 11+
- **CPU** : 4 cores minimum (8+ recommandé)
- **RAM** : 8 GB minimum (16+ GB recommandé)
- **Disque** : 50 GB minimum (100+ GB SSD recommandé)
- **Réseau** : 1 Gbps minimum (10 Gbps recommandé)

---

### Q : Puis-je installer sur un système existant ?

**R :** Oui, mais attention aux conflits :

- ✅ Vérifier que les ports ne sont pas utilisés (3000, 9090, 8086, 8000)
- ✅ Vérifier les versions des dépendances
- ✅ Faire une sauvegarde avant installation
- ⚠️ Certains packages peuvent être mis à jour

**Recommandation** : Utiliser une VM ou conteneur pour tester d'abord.

---

### Q : Installation rootless possible ?

**R :** Oui, avec Podman :

```bash
cd podman
./install-podman.sh  # Installation rootless
./start-tig-services.sh
```

**Avantages** :
- Pas besoin de privilèges root
- Isolation complète
- Compatible systemd

---

## 🔧 Configuration

### Q : Comment changer les ports par défaut ?

**R :** Modifier les fichiers de configuration :

**Grafana** (`/etc/grafana/grafana.ini`) :
```ini
[server]
http_port = 3000  # Changer ici
```

**Prometheus** (`/etc/prometheus/prometheus.yml`) :
```yaml
global:
  scrape_interval: 15s
```

**InfluxDB** (`/etc/influxdb/influxdb.conf`) :
```toml
[http]
bind-address = ":8086"  # Changer ici
```

Puis redémarrer les services :
```bash
sudo systemctl restart grafana prometheus influxdb
```

---

### Q : Comment configurer SSL/TLS ?

**R :** Utiliser un reverse proxy (Nginx/Traefik) :

**Exemple avec Nginx** :
```nginx
server {
    listen 443 ssl;
    server_name grafana.example.com;
    
    ssl_certificate /etc/ssl/certs/grafana.crt;
    ssl_certificate_key /etc/ssl/private/grafana.key;
    
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

**Ou utiliser Let's Encrypt** :
```bash
sudo certbot --nginx -d grafana.example.com
```

---

### Q : Comment ajouter un nouveau nœud de calcul ?

**R :** Processus en 3 étapes :

1. **Préparer le nœud** :
```bash
# Sur le nouveau nœud
sudo ./scripts/prepare-compute-node.sh
```

2. **Configurer Slurm** :
```bash
# Sur le nœud master
sudo scontrol update NodeName=compute07 State=IDLE
```

3. **Vérifier** :
```bash
sinfo -N -l
```

---

## 📊 Monitoring

### Q : Les métriques ne s'affichent pas dans Grafana

**R :** Vérifier dans l'ordre :

1. **Prometheus collecte-t-il les métriques ?**
```bash
curl http://localhost:9090/api/v1/targets
```

2. **Grafana peut-il accéder à Prometheus ?**
   - Configuration > Data Sources > Prometheus
   - Tester la connexion

3. **Les dashboards sont-ils importés ?**
   - Configuration > Dashboards > Import

4. **Vérifier les logs** :
```bash
sudo journalctl -u prometheus -f
sudo journalctl -u grafana -f
```

---

### Q : Comment ajouter une nouvelle métrique ?

**R :** Deux approches :

**1. Via Node Exporter (métriques système)** :
```bash
# Ajouter un exporter personnalisé
./scripts/add-custom-exporter.sh
```

**2. Via Prometheus Pushgateway** :
```bash
# Pousser une métrique
echo "my_metric 42" | curl --data-binary @- http://localhost:9091/metrics/job/my_job
```

**3. Via InfluxDB (métriques applicatives)** :
```python
from influxdb_client import InfluxDBClient

client = InfluxDBClient(url="http://localhost:8086", token="your-token")
write_api = client.write_api()
write_api.write(bucket="metrics", record="cpu_usage,host=server1 value=75.5")
```

---

### Q : Comment configurer des alertes ?

**R :** Utiliser Alertmanager :

1. **Configurer les alertes** (`/etc/prometheus/alerts.yml`) :
```yaml
groups:
  - name: cpu_alerts
    rules:
      - alert: HighCPUUsage
        expr: cpu_usage > 80
        for: 5m
        annotations:
          summary: "CPU usage is high"
```

2. **Configurer Prometheus** :
```yaml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']
```

3. **Redémarrer** :
```bash
sudo systemctl restart prometheus
```

---

## 🔒 Sécurité

### Q : Comment sécuriser l'accès à Grafana ?

**R :** Plusieurs options :

**1. Authentification LDAP** :
```ini
[auth.ldap]
enabled = true
config_file = /etc/grafana/ldap.toml
```

**2. OAuth (Google, GitHub, etc.)** :
```ini
[auth.google]
enabled = true
client_id = YOUR_CLIENT_ID
client_secret = YOUR_CLIENT_SECRET
```

**3. Reverse Proxy avec authentification** :
```nginx
location / {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:3000;
}
```

---

### Q : Les mots de passe par défaut sont-ils sécurisés ?

**R :** ⚠️ **NON** - À changer immédiatement :

**Grafana** : `admin/admin123` → Changer via l'interface web  
**InfluxDB** : Configurer lors de l'installation  
**Prometheus** : Pas d'authentification par défaut (ajouter via reverse proxy)

**Script de changement automatique** :
```bash
./scripts/change-default-passwords.sh
```

---

### Q : Comment auditer les accès ?

**R :** Utiliser les logs :

**Grafana** :
```bash
sudo tail -f /var/log/grafana/grafana.log | grep "login"
```

**Prometheus** :
```bash
sudo journalctl -u prometheus | grep "query"
```

**Nginx (si reverse proxy)** :
```bash
sudo tail -f /var/log/nginx/access.log
```

---

## 🐛 Dépannage

### Q : Service ne démarre pas

**R :** Procédure de diagnostic :

1. **Vérifier les logs** :
```bash
sudo journalctl -u SERVICE_NAME -n 50 --no-pager
```

2. **Vérifier les permissions** :
```bash
ls -la /var/lib/SERVICE_NAME
sudo chown -R USER:GROUP /var/lib/SERVICE_NAME
```

3. **Vérifier la configuration** :
```bash
sudo SERVICE_NAME --config.file=/etc/SERVICE_NAME/config.yml --check-config
```

4. **Tester manuellement** :
```bash
sudo -u SERVICE_USER SERVICE_NAME --config.file=/etc/SERVICE_NAME/config.yml
```

---

### Q : Métriques manquantes

**R :** Vérifier :

1. **Targets Prometheus** :
```bash
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health!="up")'
```

2. **Firewall** :
```bash
sudo firewall-cmd --list-all
sudo ufw status
```

3. **Connectivité réseau** :
```bash
telnet TARGET_HOST PORT
```

4. **Logs Node Exporter** :
```bash
sudo journalctl -u node_exporter -f
```

---

### Q : Performance dégradée

**R :** Optimisations possibles :

1. **Réduire la rétention** :
```yaml
# Prometheus
retention: 15d  # Au lieu de 30d
```

2. **Augmenter les ressources** :
```bash
# Grafana
sudo systemctl edit grafana
# Ajouter :
[Service]
LimitNOFILE=65536
```

3. **Optimiser les requêtes** :
- Utiliser des requêtes plus courtes
- Réduire la fréquence de scraping
- Utiliser des règles d'enregistrement

---

## 💾 Sauvegarde

### Q : Comment sauvegarder les données ?

**R :** Scripts de sauvegarde inclus :

```bash
# Sauvegarde complète
./scripts/backup-all.sh

# Sauvegarde sélective
./scripts/backup-grafana.sh
./scripts/backup-prometheus.sh
./scripts/backup-influxdb.sh
```

**Configuration automatique** :
```bash
# Ajouter au crontab
0 2 * * * /path/to/backup-all.sh
```

---

### Q : Comment restaurer une sauvegarde ?

**R :** Scripts de restauration :

```bash
# Restauration complète
./scripts/restore-all.sh BACKUP_DIR

# Restauration sélective
./scripts/restore-grafana.sh BACKUP_DIR
./scripts/restore-prometheus.sh BACKUP_DIR
```

---

## 🔄 Mise à Jour

### Q : Comment mettre à jour les composants ?

**R :** Processus recommandé :

1. **Sauvegarder** :
```bash
./scripts/backup-all.sh
```

2. **Mettre à jour** :
```bash
# Via package manager
sudo apt update && sudo apt upgrade  # Ubuntu/Debian
sudo zypper update                  # openSUSE

# Ou via scripts
./scripts/update-components.sh
```

3. **Vérifier** :
```bash
./scripts/verify-installation.sh
```

---

## 📚 Ressources

- **📖 [Guide Installation](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Installation-Rapide.md)**
- **🐛 [Dépannage](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Depannage.md)** : Solutions détaillées
- **💡 [Astuces](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Astuces.md)** : Optimisations

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
