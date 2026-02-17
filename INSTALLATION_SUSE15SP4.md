# Installation Cluster HPC sur SUSE 15 SP4
## Guide Complet d'Installation Offline avec Docker

**Classification**: Documentation Installation  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 🎯 Vue d'Ensemble

Ce guide décrit l'installation complète du cluster HPC sur **SUSE 15 SP4** en mode **offline (air-gapped)**.

---

## 📋 Prérequis

### Système Cible

- **OS** : SUSE Linux Enterprise Server 15 SP4
- **Docker** : Version 20.10+ (à installer)
- **Docker Compose** : Version 2.0+ (à installer)
- **Espace disque** : 50GB+ minimum
- **RAM** : 16GB+ recommandé
- **Réseau** : Pas d'Internet requis (offline)

---

## 🚀 Installation Étape par Étape

### Étape 1 : Préparation sur Machine en Ligne

**Sur une machine avec Internet** :

```bash
# 1. Cloner/copier le projet
git clone <repository> # ou copier depuis USB

# 2. Exporter les images Docker
cd "cluster hpc/docker"
docker-compose -f docker-compose-opensource.yml build
docker-compose -f docker-compose-opensource.yml save -o hpc-cluster-images.tar

# 3. Créer archive complète
cd ../..
tar -czf hpc-cluster-suse15sp4.tar.gz "cluster hpc/"
```

### Étape 2 : Transfert vers Serveur SUSE 15 SP4

**Options** :
- USB/DVD
- Réseau local
- Support amovible

```bash
# Copier sur serveur
scp hpc-cluster-suse15sp4.tar.gz user@server:/opt/
scp hpc-cluster-images.tar user@server:/opt/
```

### Étape 3 : Installation Docker sur SUSE 15 SP4

**Sur le serveur SUSE 15 SP4** :

```bash
# Installation Docker depuis médias SUSE
zypper install docker docker-compose

# Ou depuis packages téléchargés
rpm -ivh docker-*.rpm

# Démarrer Docker
systemctl enable docker
systemctl start docker

# Vérifier
docker --version
docker-compose --version
```

### Étape 4 : Installation du Cluster

```bash
# 1. Extraire le projet
cd /opt
tar -xzf hpc-cluster-suse15sp4.tar.gz
cd "cluster hpc"

# 2. Charger les images Docker
docker load -i ../hpc-cluster-images.tar

# 3. Démarrer le cluster
cd docker
docker-compose -f docker-compose-opensource.yml up -d

# 4. Vérifier
docker-compose ps
docker-compose logs
```

### Étape 5 : Installation des Applications

```bash
# Applications scientifiques
cd ../scripts/software
sudo ./install-gromacs.sh
sudo ./install-openfoam.sh
sudo ./install-quantum-espresso.sh
sudo ./install-paraview.sh

# Système de fichiers
cd ../storage
sudo ./install-beegfs.sh

# Remote graphics
cd ../remote-graphics
sudo ./install-x2go.sh
```

### Étape 6 : Configuration

```bash
# Authentification (choisir une option)
cd ../..
sudo ./scripts/install-ldap-kerberos.sh
# OU
sudo ./scripts/install-freeipa.sh

# Sécurité
sudo ./scripts/security/hardening.sh

# Monitoring (déjà dans Docker)
# Vérifier accès Grafana: http://server:3000
```

### Étape 7 : Vérification

```bash
# Diagnostic complet
./scripts/troubleshooting/diagnose-cluster.sh

# Tests
./scripts/tests/test-cluster-health.sh

# Vérifier services
systemctl status slurmctld
systemctl status beegfs-mgmtd
```

---

## ✅ Vérification Post-Installation

### Checklist

- [ ] Docker fonctionnel
- [ ] Conteneurs démarrés
- [ ] Slurm fonctionnel
- [ ] BeeGFS monté
- [ ] Monitoring accessible
- [ ] Applications installées
- [ ] Authentification configurée
- [ ] Sécurité appliquée

---

## 📚 Documentation

Toute la documentation est dans `docs/` :
- Guide de démarrage
- Guide de maintenance
- Guide de troubleshooting
- Guide des technologies
- Guide des applications

---

## 🎉 Résultat

**Le cluster HPC est installé et fonctionnel sur SUSE 15 SP4 !**

**Tout est 100% open-source et prêt pour la production !** 🚀

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
