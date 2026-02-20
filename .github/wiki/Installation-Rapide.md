# 🚀 Installation Rapide - Cluster HPC Enterprise

> **Guide d'installation en 5 minutes - Niveau DevOps Senior**

---

## ⚡ Prérequis

### Système d'Exploitation

- **openSUSE 15** (équivalent SUSE 15 SP7)
- **Ubuntu 22.04 LTS** ou supérieur
- **CentOS/RHEL 8+** ou **Rocky Linux 8+**
- **Debian 11+**

### Ressources Minimales

| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| **CPU** | 4 cores | 8+ cores |
| **RAM** | 8 GB | 16+ GB |
| **Disque** | 50 GB | 100+ GB SSD |
| **Réseau** | 1 Gbps | 10 Gbps |

### Accès Requis

- ✅ Accès **root** ou **sudo**
- ✅ Connexion Internet (pour téléchargements)
- ✅ Ports disponibles : 3000, 9090, 8086, 8000

---

## 🎯 Installation en 3 Étapes

### Étape 1 : Cloner le Repository

```bash
# Cloner le repository
git clone https://github.com/mickaelangel/hpc-cluster.git
cd hpc-cluster

# Vérifier la structure
ls -la
```

### Étape 2 : Exécuter l'Installation Automatique

```bash
# Rendre le script exécutable
chmod +x install-all.sh

# Lancer l'installation complète
sudo ./install-all.sh
```

**Durée estimée** : 15-30 minutes selon la connexion

### Étape 3 : Vérifier l'Installation

```bash
# Vérifier les services
sudo systemctl status prometheus
sudo systemctl status grafana
sudo systemctl status influxdb

# Vérifier les ports
sudo netstat -tlnp | grep -E '3000|9090|8086'
```

---

## 🔧 Installation Manuelle (Avancée)

### Option 1 : Installation par Composant

```bash
# Installer uniquement le monitoring
sudo ./scripts/install-monitoring.sh

# Installer uniquement Slurm
sudo ./scripts/install-slurm.sh

# Installer uniquement les applications
sudo ./scripts/install-applications.sh
```

### Option 2 : Installation avec Docker

```bash
# Utiliser Docker Compose
cd docker
docker-compose up -d

# Vérifier les conteneurs
docker ps
```

### Option 3 : Installation avec Podman (Rootless)

```bash
# Utiliser Podman
cd podman
./install-podman.sh
./start-tig-services.sh
```

---

## ⚙️ Configuration Initiale

### 1. Configuration de Base

```bash
# Copier les fichiers de configuration
cp configs/grafana/grafana.ini.example /etc/grafana/grafana.ini
cp configs/prometheus/prometheus.yml.example /etc/prometheus/prometheus.yml

# Éditer selon vos besoins
sudo nano /etc/grafana/grafana.ini
sudo nano /etc/prometheus/prometheus.yml
```

### 2. Configuration des Mots de Passe

```bash
# Changer le mot de passe Grafana (admin/admin123 par défaut)
# Via l'interface web : http://localhost:3000

# Configurer InfluxDB
influx setup \
  --username admin \
  --password VotreMotDePasseSecurise \
  --org hpc-cluster \
  --bucket metrics \
  --retention 30d \
  --force
```

### 3. Import des Dashboards Grafana

```bash
# Importer les dashboards
./scripts/import-grafana-dashboards.sh

# Ou manuellement via l'interface web
# Configuration > Dashboards > Import
```

---

## 🧪 Tests de Validation

### Test 1 : Services Actifs

```bash
# Script de vérification automatique
./scripts/verify-installation.sh

# Vérification manuelle
curl http://localhost:3000/api/health  # Grafana
curl http://localhost:9090/-/healthy   # Prometheus
curl http://localhost:8086/health     # InfluxDB
```

### Test 2 : Collecte de Métriques

```bash
# Vérifier que Prometheus collecte des métriques
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="up")'

# Vérifier les métriques système
curl http://localhost:9090/api/v1/query?query=up
```

### Test 3 : Dashboards Grafana

1. Accéder à http://localhost:3000
2. Se connecter avec `admin/admin123`
3. Vérifier que les dashboards sont présents
4. Vérifier que les données s'affichent

---

## 🐛 Résolution de Problèmes Courants

### Problème : Services ne démarrent pas

```bash
# Vérifier les logs
sudo journalctl -u prometheus -n 50
sudo journalctl -u grafana -n 50
sudo journalctl -u influxdb -n 50

# Vérifier les permissions
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R grafana:grafana /var/lib/grafana
```

### Problème : Ports déjà utilisés

```bash
# Identifier le processus utilisant le port
sudo lsof -i :3000
sudo lsof -i :9090

# Arrêter le processus ou changer le port dans la config
```

### Problème : Permissions insuffisantes

```bash
# Vérifier les permissions
ls -la /var/lib/prometheus
ls -la /var/lib/grafana

# Corriger si nécessaire
sudo chmod -R 755 /var/lib/prometheus
sudo chmod -R 755 /var/lib/grafana
```

---

## 📋 Checklist Post-Installation

- [ ] Tous les services sont actifs
- [ ] Les ports sont accessibles
- [ ] Les dashboards Grafana sont importés
- [ ] Les métriques sont collectées
- [ ] Les mots de passe par défaut sont changés
- [ ] Les certificats SSL sont configurés (production)
- [ ] Les sauvegardes sont configurées
- [ ] Le monitoring est fonctionnel

---

## 🚀 Prochaines Étapes

1. **📖 [Configuration de Base](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Configuration-de-Base.md)** : Configuration minimale
2. **🔒 [Sécurité](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Securite.md)** : Sécuriser l'installation
3. **📊 [Monitoring](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Monitoring.md)** : Configurer le monitoring avancé
4. **👥 [Guide Utilisateur](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Guide-Utilisateur.md)** : Utilisation du cluster

---

## 📚 Ressources

- **📖 [Guide Installation Complet](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_INSTALLATION_COMPLETE.md)**
- **🐛 [Dépannage](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Depannage.md)** : Solutions aux problèmes
- **💬 [FAQ](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/FAQ.md)** : Questions fréquentes

---

**Dernière mise à jour** : 2024  
**Niveau** : DevOps Senior
