# Interfaces TrinityX - Documentation

## Vue d'ensemble

Ce répertoire contient les interfaces HTML complémentaires pour TrinityX, permettant la visualisation et la gestion de différents aspects du cluster HPC.

## Interfaces disponibles

### 1. `network-ib.html` - Réseau InfiniBand
- **Description**: Visualisation de la topologie réseau InfiniBand
- **Fonctionnalités**:
  - Carte topologique du réseau IB
  - Statistiques de bande passante par nœud
  - Latence et erreurs réseau
  - État des interfaces IB (ib0) sur tous les nœuds
- **Accès**: Ouvrir dans un navigateur web

### 2. `gpfs-quotas.html` - Gestion GPFS et Quotas
- **Description**: Interface de gestion du stockage GPFS et des quotas utilisateurs
- **Fonctionnalités**:
  - Vue d'ensemble de la capacité GPFS
  - Liste des quotas utilisateurs (top 20)
  - État des filesystems GPFS
  - Détails des NSD (Network Shared Disks)
  - Alertes pour quotas dépassés
- **Accès**: Ouvrir dans un navigateur web

### 3. `slurm-monitoring.html` - Monitoring Slurm
- **Description**: Interface de monitoring du scheduler Slurm
- **Fonctionnalités**:
  - Jobs actifs et en attente
  - État des nœuds de calcul
  - Utilisation CPU/Mémoire par nœud
  - File d'attente des jobs
  - Statistiques du cluster
- **Accès**: Ouvrir dans un navigateur web

## Utilisation

### Méthode 1: Fichiers statiques
Ouvrir directement les fichiers HTML dans un navigateur web:
```bash
firefox network-ib.html
# ou
google-chrome gpfs-quotas.html
```

### Méthode 2: Serveur web local
Pour une meilleure expérience, servir via un serveur web:
```bash
# Python 3
python3 -m http.server 8000

# Node.js (si installé)
npx http-server -p 8000

# Accéder via: http://localhost:8000/network-ib.html
```

### Méthode 3: Intégration avec TrinityX
Ces interfaces peuvent être intégrées dans l'interface web TrinityX en les copiant dans le répertoire des templates:
```bash
cp *.html /opt/trinityx/web/templates/
```

## Personnalisation

Les interfaces utilisent des données statiques pour la démonstration. Pour une utilisation réelle, il faudra:

1. **Connecter aux APIs réelles**:
   - InfiniBand: Utiliser `ibstat`, `iblinkinfo` via scripts backend
   - GPFS: Utiliser `mmlsquota`, `mmdf` via scripts backend
   - Slurm: Utiliser `sinfo`, `squeue` via scripts backend

2. **Ajouter un backend API**:
   - Créer des endpoints REST qui exécutent les commandes système
   - Retourner les données en JSON
   - Les interfaces HTML consomment ces APIs via JavaScript

3. **Mise à jour en temps réel**:
   - Utiliser WebSockets ou polling AJAX
   - Rafraîchir les données toutes les 5-10 secondes

## Structure des données

### Réseau InfiniBand
```json
{
  "nodes": [
    {
      "name": "frontal-01",
      "ip": "10.10.10.11",
      "status": "active",
      "throughput": "4.2 Gb/s",
      "latency": "1.1 μs",
      "errors": 0
    }
  ]
}
```

### GPFS Quotas
```json
{
  "filesystem": {
    "name": "gpfsfs1",
    "total": "50.0 TB",
    "used": "42.0 TB",
    "free": "8.0 TB",
    "percent": 84
  },
  "quotas": [
    {
      "user": "jdoe",
      "uid": 1001,
      "used": "8.4 TB",
      "quota": "10.0 TB",
      "percent": 84,
      "status": "warning"
    }
  ]
}
```

### Slurm Jobs
```json
{
  "jobs": [
    {
      "id": 1842,
      "user": "jdoe",
      "partition": "normal",
      "nodes": ["node-01", "node-05"],
      "cpus": "64/64",
      "memory": "128 GB",
      "time": "02:34:12",
      "status": "RUNNING"
    }
  ]
}
```

## Notes

- Les interfaces sont conçues pour un thème sombre (dark theme)
- Compatible avec les navigateurs modernes (Chrome, Firefox, Edge)
- Responsive design (s'adapte aux différentes tailles d'écran)
- Pas de dépendances externes (CSS/JS inline)

## Support

Pour toute question ou problème:
1. Vérifier la console du navigateur (F12) pour les erreurs JavaScript
2. Vérifier que les données sont au bon format JSON
3. Consulter la documentation TrinityX principale

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
