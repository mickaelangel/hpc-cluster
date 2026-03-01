# Cluster HPC - Documentation Principale
## Projet 100% Open-Source pour openSUSE 15.6

**Version**: 1.0  
**Date**: 2024

---

## 🎯 Bienvenue

Ce projet est un **cluster HPC complet, 100% open-source**, prêt pour déploiement sur **openSUSE 15.6** via Docker.

---

## 🚀 Démarrage Rapide

### Installation

```bash
# 1. Copier le projet
cp -r "cluster hpc" /opt/hpc-cluster
cd /opt/hpc-cluster

# 2. Démarrer Docker
cd docker
docker-compose -f docker-compose-opensource.yml build
docker-compose -f docker-compose-opensource.yml up -d

# 3. Vérifier
docker-compose ps
```

### Première Utilisation

```bash
# Se connecter
ssh user@frontal-01

# Voir l'état
sinfo
squeue

# Soumettre un job
sbatch examples/jobs/exemple-python.sh
```

---

## 📚 Documentation

### Pour Débutants

- **`docs/GUIDE_COMPLET_DEMARRAGE.md`** - Démarrage complet
- **`docs/GUIDE_TECHNOLOGIES_EXPLIQUEES.md`** - Technologies expliquées

### Pour Administrateurs

- **`docs/GUIDE_MAINTENANCE_COMPLETE.md`** - Maintenance complète
- **`docs/GUIDE_PANNES_INCIDENTS.md`** - Pannes et incidents
- **`docs/GUIDE_DEBUG_TROUBLESHOOTING.md`** - Debug et troubleshooting
- **`docs/GUIDE_MISE_A_JOUR_REPARATION.md`** - Mise à jour et réparation

### Pour Ingénieurs

- **`docs/TECHNOLOGIES_CLUSTER.md`** - Technologies détaillées
- **`docs/GUIDE_INSTALLATION_COMPLETE.md`** - Installation complète
- **`docs/GUIDE_APPLICATIONS_DETAILLE.md`** - Applications détaillées

**Voir `DOCUMENTATION_COMPLETE_INDEX.md` pour l'index complet !**

---

## ✅ Composants Open-Source

- **Authentification** : LDAP, Kerberos, FreeIPA
- **Scheduler** : Slurm
- **Stockage** : BeeGFS, Lustre
- **Monitoring** : Prometheus, Grafana, InfluxDB, Telegraf, Loki
- **Applications** : GROMACS, OpenFOAM, Quantum ESPRESSO, ParaView
- **Remote Graphics** : X2Go, NoMachine
- **Autres** : JupyterHub, Apptainer, Ansible AWX, Nexus, Spack

**Tous sont 100% gratuits et open-source !**

---

## 📁 Structure

```
cluster hpc/
├── docker/          # Configuration Docker
├── docs/            # 30+ guides complets
├── scripts/         # 50+ scripts
├── examples/        # Exemples
└── monitoring/      # Configuration monitoring
```

---

## 🎉 Résultat

**Le cluster HPC est** :
- ✅ 100% Open-Source
- ✅ Complet
- ✅ Fonctionnel
- ✅ Portable (Docker, openSUSE 15.6)
- ✅ Documenté (30+ guides)

**Prêt pour démonstration et production !** 🚀

---

**Voir `DOCUMENTATION_COMPLETE_INDEX.md` pour toute la documentation !**
