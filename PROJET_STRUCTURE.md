# Structure du Projet HPC - Organisation par Dossiers

## 📋 Vue d'ensemble

Ce projet a été organisé en dossiers séparés selon les instructions du fichier `instruction.txt`. Chaque module est indépendant et peut être utilisé séparément.

## 📂 Détails des Dossiers

### 1. `docker/` - Simulation Docker du Cluster

**Contenu**:
- `frontal/Dockerfile` - Image Docker pour nœuds frontaux GPFS
- `client/Dockerfile` - Image Docker pour nœuds de calcul
- `docker-compose.yml` - Orchestration complète (2 frontaux + 6 clients + monitoring)
- `scripts/` - Scripts d'initialisation des conteneurs
- `configs/` - Configurations réseau, Slurm, Munge
- `packages/` - Emplacement pour les RPMs (GPFS, Telegraf)

**Usage**:
```bash
cd docker/
docker-compose build
docker-compose up -d
```

### 2. `monitoring/` - Stack de Monitoring

**Contenu**:
- `prometheus/` - Configuration Prometheus (scraping, alertes)
- `grafana/` - Configuration Grafana + Dashboards JSON
- `influxdb/` - Configuration InfluxDB (optionnel)
- `telegraf/` - Configurations Telegraf pour frontaux et clients

**Composants**:
- Prometheus (port 9090) - Collecte métriques
- Grafana (port 3000) - Visualisation
- InfluxDB (port 8086) - Base de données séries temporelles
- Telegraf - Agents de collecte sur chaque nœud

### 3. `gpfs/` - Configuration GPFS (IBM Spectrum Scale)

**Contenu**:
- `configs/` - Fichiers de configuration GPFS
- `scripts/` - Scripts d'administration GPFS

**Fonctionnalités**:
- Configuration cluster GPFS
- Gestion des NSD (Network Shared Disks)
- Configuration des filesystems
- Gestion des quotas

### 4. `trinityx/` - TrinityX + Warewulf

**Contenu**:
- `GUIDE_INSTALLATION_TRINITYX.md` - Guide complet d'installation
- `install-trinityx-warewulf.sh` - Script d'installation automatisé
- `interfaces/` - Interfaces web HTML pour TrinityX

**Fonctionnalités**:
- Provisioning des nœuds via Warewulf
- Interface web de gestion
- Gestion des images système
- Configuration des overlays

### 5. `software/` - Logiciels HPC

**Contenu**:
- `matlab/` - Configuration MATLAB R2023b + DCS
- `openm/` - Configuration OpenM++ 1.15.2
- `spack/` - Configuration Spack (gestionnaire de paquets HPC)

### 6. `scripts/` - Scripts Utilitaires

**Contenu**:
- `INSTALL.sh` - Script d'installation principal
- `docker/` - Scripts spécifiques Docker
- `gpfs/` - Scripts d'administration GPFS
- `monitoring/` - Scripts de configuration monitoring
- `trinityx/` - Scripts TrinityX/Warewulf

### 7. `docs/` - Documentation

**Contenu**:
- `README.md` - Documentation principale
- Autres fichiers de documentation

## 🔄 Migration depuis l'Ancienne Structure

Les fichiers ont été déplacés depuis la racine vers les dossiers appropriés :

| Ancien Emplacement | Nouveau Emplacement |
|-------------------|---------------------|
| `docker-compose.yml` | `docker/docker-compose.yml` |
| `Dockerfile.frontal` | `docker/frontal/Dockerfile` |
| `Dockerfile.slave` | `docker/client/Dockerfile` |
| `configs/prometheus/` | `monitoring/prometheus/` |
| `configs/grafana/` | `monitoring/grafana/` |
| `configs/telegraf/` | `monitoring/telegraf/` |
| `grafana-dashboards/` | `monitoring/grafana/dashboards/` |
| `scripts/entrypoint-*.sh` | `docker/scripts/` |
| `GUIDE_INSTALLATION_TRINITYX.md` | `trinityx/` |
| `trinityx-interfaces/` | `trinityx/interfaces/` |

## 🎯 Utilisation par Scénario

### Scénario 1: Démo Docker Rapide
```bash
cd docker/
make start
```

### Scénario 2: Installation Production Complète
```bash
./scripts/INSTALL.sh
```

### Scénario 3: Configuration Monitoring Seulement
```bash
cd monitoring/
# Configurer Prometheus, Grafana, Telegraf
```

### Scénario 4: Installation TrinityX/Warewulf
```bash
cd trinityx/
./install-trinityx-warewulf.sh
```

## 📝 Notes Importantes

1. **Packages GPFS**: Les RPMs GPFS doivent être copiés manuellement dans `docker/packages/gpfs/` avant le build
2. **Mots de passe**: Tous les mots de passe par défaut doivent être changés en production
3. **Réseaux**: Les IPs sont configurées pour simulation, adapter selon votre infrastructure
4. **Air-gapped**: Le projet supporte le déploiement offline via scripts d'export

## 🔗 Liens Utiles

- Documentation Docker: `docker/README.md`
- Documentation Monitoring: `monitoring/README.md`
- Guide TrinityX: `trinityx/GUIDE_INSTALLATION_TRINITYX.md`
- Instructions originales: `instruction.txt`

---

**Version**: 1.0  
**Date**: 2024
