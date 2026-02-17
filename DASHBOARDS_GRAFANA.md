# Dashboards Grafana - Cluster HPC
## Liste Complète des 54 Dashboards Disponibles

**Date** : 2025-02-15  
**Statut** : ✅ Tous les dashboards sont chargés et disponibles

---

## 📊 Vue d'Ensemble

**54 dashboards** sont automatiquement chargés dans Grafana via le provisioning automatique.

### Accès aux Dashboards

1. **URL** : http://localhost:3000
2. **Login** : `admin`
3. **Mot de passe** : `$Password!2026`
4. **Menu** : Dashboards → Browse

---

## 🎯 Dashboards Principaux HPC

### 1. **HPC Cluster Overview** ⭐
- Vue d'ensemble complète du cluster
- Statut des nœuds
- Utilisation CPU/Mémoire globale
- Métriques réseau

### 2. **Performance**
- Performances système détaillées
- CPU, mémoire, disque, réseau
- Comparaison entre nœuds

### 3. **Security**
- Métriques de sécurité
- Authentification
- Audit trail

### 4. **Security Advanced**
- Sécurité avancée
- Vulnérabilités
- Container security

### 5. **Network IO**
- Trafic réseau
- Bande passante
- Erreurs réseau

### 6. **Network Advanced**
- Réseau avancé
- Latence
- Connexions

### 7. **Network Security**
- Sécurité réseau
- Firewall
- Intrusions

---

## 🔬 Applications Scientifiques

### 8. **Applications Scientific**
- Métriques applications scientifiques
- GROMACS, OpenFOAM, etc.

### 9. **JupyterHub**
- Utilisation JupyterHub
- Notebooks actifs
- Ressources utilisées

### 10. **TensorFlow**
- Métriques TensorFlow
- Entraînement ML

### 11. **PyTorch**
- Métriques PyTorch
- Modèles ML

### 12. **Spark**
- Apache Spark
- Jobs Spark
- Ressources Spark

### 13. **Hadoop**
- Métriques Hadoop
- HDFS
- MapReduce

---

## 📦 Stockage

### 14. **Storage Advanced**
- Stockage avancé
- I/O disque
- Espace disponible

### 15. **Ceph**
- Métriques Ceph
- OSDs, Pools

### 16. **GlusterFS**
- Métriques GlusterFS
- Volumes
- Bricks

### 17. **MinIO**
- Métriques MinIO
- Buckets
- Objets

---

## 🗄️ Bases de Données

### 18. **PostgreSQL**
- Métriques PostgreSQL
- Connexions
- Requêtes

### 19. **MongoDB**
- Métriques MongoDB
- Collections
- Opérations

### 20. **MongoDB Dashboard**
- Vue MongoDB alternative

### 21. **InfluxDB**
- Métriques InfluxDB
- Séries temporelles
- Écritures/Lectures

### 22. **Redis**
- Métriques Redis
- Cache
- Clés

### 23. **ClickHouse**
- Métriques ClickHouse
- Tables
- Requêtes

### 24. **Elasticsearch**
- Métriques Elasticsearch
- Indices
- Recherches

---

## 🔄 Messaging & Streaming

### 25. **Kafka**
- Métriques Kafka
- Topics
- Consumers/Producers

### 26. **Kafka Dashboard**
- Vue Kafka alternative

### 27. **RabbitMQ**
- Métriques RabbitMQ
- Queues
- Messages

---

## 🛠️ Outils DevOps

### 28. **GitLab**
- Métriques GitLab
- Projets
- CI/CD

### 29. **Nexus**
- Métriques Nexus
- Repositories
- Artifacts

### 30. **Artifactory**
- Métriques Artifactory
- Builds
- Déploiements

### 31. **SonarQube**
- Métriques SonarQube
- Qualité code
- Bugs/Vulnérabilités

### 32. **Harbor**
- Métriques Harbor
- Images Docker
- Registries

---

## 🔐 Sécurité & Compliance

### 33. **Compliance**
- Conformité
- Standards
- Audits

### 34. **Compliance Realtime**
- Conformité temps réel
- Monitoring continu

### 35. **Vulnerabilities**
- Vulnérabilités
- CVE
- Scans

### 36. **Container Security**
- Sécurité conteneurs
- Images
- Runtime

### 37. **Audit Trail**
- Piste d'audit
- Événements
- Logs

### 38. **Authentication**
- Authentification
- LDAP/Kerberos
- Sessions

---

## ☸️ Orchestration

### 39. **Kubernetes**
- Métriques Kubernetes
- Pods
- Services

### 40. **Istio**
- Métriques Istio
- Service Mesh
- Traffic

---

## 🌐 Web & Proxy

### 41. **Nginx**
- Métriques Nginx
- Requêtes
- Erreurs

### 42. **Traefik**
- Métriques Traefik
- Routes
- Services

---

## 📊 Monitoring & Logs

### 43. **Logstash**
- Métriques Logstash
- Pipelines
- Événements

### 44. **Kibana**
- Métriques Kibana
- Visualisations
- Recherches

---

## 🔧 Outils HPC

### 45. **Slurm Jobs**
- Jobs Slurm
- État des jobs
- Utilisation ressources

### 46. **Slurm Partitions**
- Partitions Slurm
- Nœuds par partition
- Disponibilité

### 47. **Apptainer**
- Métriques Apptainer
- Containers
- Images

### 48. **Spack**
- Métriques Spack
- Packages
- Builds

---

## 💰 Coûts & Ressources

### 49. **Costs**
- Coûts infrastructure
- Utilisation ressources
- Budget

### 50. **Resource Utilization**
- Utilisation ressources
- CPU/Mémoire/Disque
- Tendances

### 51. **Energy**
- Consommation énergétique
- Efficacité
- Coûts

---

## 🔄 Backups

### 52. **Backups**
- État des backups
- Taille
- Fréquence

---

## 📋 Configuration

### Fichiers de Configuration

- **Provisioning** : `configs/grafana/provisioning/dashboards/default.yml`
- **Dashboards** : `grafana-dashboards/*.json` (54 fichiers)
- **Volume Docker** : Monté en lecture seule dans `/var/lib/grafana/dashboards`

### Chargement Automatique

Les dashboards sont automatiquement chargés au démarrage de Grafana grâce à :
1. Configuration de provisioning dans `configs/grafana/provisioning/dashboards/default.yml`
2. Volume monté dans `docker-compose-opensource.yml`
3. Dossier `grafana-dashboards/` avec tous les fichiers JSON

---

## 🚀 Utilisation

### Accéder aux Dashboards

1. Ouvrez http://localhost:3000
2. Connectez-vous avec `admin` / `$Password!2026`
3. Cliquez sur **Dashboards** dans le menu de gauche
4. Parcourez les dashboards ou utilisez la recherche

### Rechercher un Dashboard

- Utilisez la barre de recherche en haut
- Filtrez par tags (hpc, cluster, security, etc.)
- Triez par nom, popularité, ou date

### Personnaliser un Dashboard

- Cliquez sur un dashboard
- Cliquez sur l'icône ⚙️ (Settings) en haut à droite
- Modifiez les panneaux selon vos besoins
- Sauvegardez (les modifications sont autorisées)

---

## ✅ Vérification

Pour vérifier que tous les dashboards sont chargés :

```powershell
cd "C:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
.\scripts\charger-dashboards-grafana.ps1
```

---

## 📝 Notes

- Les dashboards sont en **lecture seule** par défaut (volume monté en `ro`)
- Pour modifier un dashboard, utilisez l'interface Grafana (les modifications sont sauvegardées dans la base de données Grafana)
- Les dashboards pointent vers la source de données **Prometheus** (configurée automatiquement)
- Tous les dashboards sont dans le dossier **HPC** par défaut

---

**Version** : 1.0  
**Total Dashboards** : 54
