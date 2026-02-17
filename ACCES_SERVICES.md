# Accès aux Services - Cluster HPC
## Identifiants et URLs

**Date de mise à jour** : 2025-02-15

---

## 🔐 Grafana

- **URL** : http://localhost:3000
- **Login** : `admin`
- **Mot de passe** : `$Password!2026`

**Fonctionnalités** :
- Dashboards de monitoring (54+ dashboards)
- Visualisation des métriques Prometheus
- Alertes et notifications

---

## 📊 Prometheus

- **URL** : http://localhost:9090
- **Pas d'authentification** (accès direct)

**Fonctionnalités** :
- Collecte de métriques (17 targets)
- Requêtes PromQL
- Alertes configurées

---

## 📓 JupyterHub

- **URL** : http://localhost:8000
- **Authentification** : DummyAuthenticator (démo)
  - Mot de passe : `jupyter-demo`

**Fonctionnalités** :
- Notebooks interactifs
- Environnement Python/Scientific

---

## 💾 InfluxDB

- **URL** : http://localhost:8086
- **Login** : `admin`
- **Mot de passe** : `admin1234`
- **Organisation** : `hpc-cluster`
- **Bucket** : `hpc-metrics`

---

## 📝 Loki (Logs)

- **URL** : http://localhost:3100
- **Pas d'authentification** (accès direct)

**Fonctionnalités** :
- Agrégation de logs
- Intégration avec Grafana

---

## 🔧 Accès SSH aux Nœuds

### Frontaux

**Frontal-01** :
```bash
ssh -p 2222 root@localhost
# Mot de passe : hpc-demo-2024
```

**Frontal-02** :
```bash
ssh -p 2223 root@localhost
# Mot de passe : hpc-demo-2024
```

---

## 📋 Résumé Rapide

| Service | URL | Login | Mot de passe |
|---------|-----|-------|--------------|
| **Grafana** | http://localhost:3000 | `admin` | `$Password!2026` |
| **Prometheus** | http://localhost:9090 | - | - |
| **JupyterHub** | http://localhost:8000 | - | `jupyter-demo` |
| **InfluxDB** | http://localhost:8086 | `admin` | `admin1234` |
| **Loki** | http://localhost:3100 | - | - |

---

## 🔒 Sécurité

⚠️ **Important** : Ces identifiants sont pour un environnement de démonstration.

Pour la production :
1. Changez tous les mots de passe
2. Activez l'authentification sur Prometheus
3. Configurez HTTPS/TLS
4. Utilisez des secrets managés (Vault, etc.)

---

**Version** : 1.0
