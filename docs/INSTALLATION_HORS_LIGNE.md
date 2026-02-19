# Installation Serveur Hors Ligne - openSUSE 15

## ⚠️ Sécurité

**NE JAMAIS** stocker de mots de passe en clair dans le dépôt Git.

Utilisez un gestionnaire de mots de passe ou des variables d'environnement sécurisées.

---

## 📋 Étapes d'Installation Hors Ligne

### 1. Copier l'Archive

```bash
# Copier l'archive depuis la clé USB vers /opt (ou autre)
cp /chemin/clé/hpc-cluster-demo-*.tar.gz /opt/
cd /opt && tar -xzf hpc-cluster-demo-*.tar.gz
cd hpc-cluster-demo-*
```

### 2. Installer Docker (Hors Ligne)

Si le dossier `docker-offline-rpms/` contient des `.rpm` :

```bash
sudo ./scripts/deployment/install-docker-offline.sh
```

Sinon, sur une machine openSUSE 15 avec Internet, exécuter une fois :

```bash
sudo bash scripts/deployment/download-docker-rpms-opensuse15.sh
```

Puis copier le dossier `docker-offline-rpms/` dans cet export.

### 3. Installer et Démarrer le Cluster

```bash
sudo ./install-all.sh
```

### 4. Vérification

```bash
sudo bash scripts/tests/test-cluster-health.sh
```

---

## 🌐 Services Après Installation

- **Grafana**: http://localhost:3000 (admin / admin123 - ⚠️ À changer)
- **Prometheus**: http://localhost:9090
- **JupyterHub**: http://localhost:8000

Voir [DEMO.md](../DEMO.md) pour la démo complète.

---

## 🔒 Sécurité

- ⚠️ **Changer tous les mots de passe par défaut**
- ⚠️ **Configurer le firewall**
- ⚠️ **Activer les sauvegardes**
- Voir [docs/GUIDE_SECURITE_AVANCEE.md](GUIDE_SECURITE_AVANCEE.md) pour plus de détails
