# ⚡ GUIDE RAPIDE - Démo Cluster HPC
## Installation Express pour Démo Professionnelle

**Durée totale** : 30-45 minutes

---

## 🚀 Étape 1 : Créer le Package (Machine avec Internet)

```bash
cd "cluster hpc"
chmod +x scripts/deployment/create-demo-package.sh
./scripts/deployment/create-demo-package.sh
```

**Résultat** : `export-demo/hpc-cluster-demo-complete-*.tar.gz`

---

## 📦 Étape 2 : Transférer sur Serveur SUSE 15 SP4

```bash
# Option 1 : USB
cp export-demo/hpc-cluster-demo-complete-*.tar.gz /media/usb/

# Option 2 : Réseau local
scp export-demo/hpc-cluster-demo-complete-*.tar.gz user@server:/opt/
```

---

## 🔧 Étape 3 : Installation (Serveur SUSE 15 SP4)

```bash
# Sur le serveur
cd /opt
tar -xzf hpc-cluster-demo-complete-*.tar.gz
cd hpc-cluster-demo-*
sudo ./install-demo.sh
```

**Attendre 10-15 minutes** pour le build et démarrage.

---

## ✅ Étape 4 : Vérification

```bash
# Vérifier services
docker ps

# Tester accès
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3000/api/health  # Grafana
```

---

## 🎯 Étape 5 : Démo

```bash
# Lancer script démo
./demo-professionnelle.sh

# Accéder aux services
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
```

---

## 📊 Services Disponibles

- **Grafana** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090
- **Nexus** : http://localhost:8081 (admin/admin123)
- **Slurm** : Via SSH sur frontal-01

---

## 🆘 Problèmes ?

Voir `docs/GUIDE_DEPLOIEMENT_HORS_LIGNE.md` section Troubleshooting.

---

**C'est tout ! Le cluster est prêt pour la démo.**
