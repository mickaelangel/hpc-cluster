# Guide de Mise à Jour et Réparation - Cluster HPC
## Procédures Complètes de Maintenance

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Mise à Jour](#mise-à-jour)
2. [Réparation](#réparation)
3. [Maintenance Préventive](#maintenance-préventive)
4. [Procédures de Redémarrage](#procédures-de-redémarrage)
5. [Restauration](#restauration)

---

## 🔄 Mise à Jour

### Mise à Jour des Conteneurs Docker

**Procédure** :
```bash
cd docker

# 1. Arrêter les conteneurs
docker-compose down

# 2. Sauvegarder les données
docker-compose exec prometheus tar -czf /tmp/prometheus-backup.tar.gz /prometheus
docker-compose exec grafana tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana

# 3. Rebuild les images
docker-compose build --no-cache

# 4. Redémarrer
docker-compose up -d

# 5. Vérifier
docker-compose ps
docker-compose logs
```

**Script Automatisé** :
```bash
./scripts/maintenance/update-cluster.sh
```

---

### Mise à Jour des Applications

**GROMACS** :
```bash
cd scripts/software
sudo ./install-gromacs.sh
# Nouvelle version dans script
```

**OpenFOAM** :
```bash
cd scripts/software
sudo ./install-openfoam.sh
```

**Quantum ESPRESSO** :
```bash
cd scripts/software
sudo ./install-quantum-espresso.sh
```

**ParaView** :
```bash
cd scripts/software
sudo ./install-paraview.sh
```

---

### Mise à Jour du Système

**openSUSE 15.6** :
```bash
# Rafraîchir repositories
zypper refresh

# Mise à jour de sécurité
zypper update --category security

# Mise à jour complète
zypper update

# Redémarrer si nécessaire
reboot
```

**Précaution** :
- Tester en environnement de test d'abord
- Planifier fenêtre de maintenance
- Communiquer aux utilisateurs
- Sauvegarder avant mise à jour

---

## 🔨 Réparation

### Réparation d'un Nœud

**Procédure** :
```bash
# 1. Drainer le nœud
scontrol update NodeName=NODE_NAME State=DRAIN

# 2. Vérifier jobs en cours
squeue -w NODE_NAME

# 3. Attendre fin des jobs ou annuler
scancel -w NODE_NAME

# 4. Réparer
# ... actions de réparation ...

# 5. Remettre en service
scontrol update NodeName=NODE_NAME State=RESUME
```

---

### Réparation d'un Service

**SlurmCTLD** :
```bash
# Arrêter
systemctl stop slurmctld

# Réparer configuration
slurmctld -t  # Test configuration

# Redémarrer
systemctl start slurmctld

# Vérifier
scontrol ping
```

**BeeGFS** :
```bash
# Arrêter services
systemctl stop beegfs-storage
systemctl stop beegfs-meta
systemctl stop beegfs-mgmtd

# Réparer si nécessaire
beegfs-checkfs --repair

# Redémarrer
systemctl start beegfs-mgmtd
systemctl start beegfs-meta
systemctl start beegfs-storage

# Vérifier
beegfs-ctl --getentryinfo
```

---

### Réparation du Système de Fichiers

**BeeGFS Corrompu** :
```bash
# Vérifier
beegfs-checkfs

# Réparer
beegfs-checkfs --repair

# Si échec, restaurer depuis backup
./scripts/backup/restore-cluster.sh
```

---

## 🛠️ Maintenance Préventive

### Quotidienne

**Vérifications** :
```bash
# État des nœuds
sinfo -N -l

# Jobs en erreur
squeue -t PD,CF,CA,F,TO,NF

# Espace disque
df -h

# Services critiques
systemctl status slurmctld
systemctl status beegfs-mgmtd
```

**Actions** :
- Nettoyer fichiers temporaires
- Vérifier logs d'erreur
- Vérifier alertes

---

### Hebdomadaire

**Vérifications** :
```bash
# Performance
sinfo -o "%P %a %l %D %T %N %C"

# Utilisation
sreport cluster Utilization

# Logs
journalctl -u slurmctld --since "7 days ago"
```

**Actions** :
- Analyse des performances
- Nettoyage des anciens jobs
- Vérification des sauvegardes

---

### Mensuelle

**Vérifications** :
```bash
# Santé système
./scripts/troubleshooting/diagnose-cluster.sh

# Sécurité
./scripts/compliance/validate-compliance.sh

# Performance
./scripts/performance/benchmark-cluster.sh
```

**Actions** :
- Mise à jour de sécurité
- Audit de conformité
- Revue des configurations

---

## 🔄 Procédures de Redémarrage

### Redémarrage Complet

**Procédure** :
```bash
# 1. Notifier utilisateurs
# 2. Drainer tous les nœuds
for node in $(sinfo -h -o "%N"); do
    scontrol update NodeName=$node State=DRAIN
done

# 3. Attendre fin des jobs
squeue

# 4. Arrêter services
systemctl stop slurmctld
systemctl stop beegfs-*

# 5. Redémarrer
reboot

# 6. Vérifier après redémarrage
systemctl status slurmctld
systemctl status beegfs-*
sinfo
```

---

### Redémarrage d'un Nœud

**Procédure** :
```bash
# 1. Drainer
scontrol update NodeName=NODE_NAME State=DRAIN

# 2. Attendre fin jobs
squeue -w NODE_NAME

# 3. Redémarrer
ssh NODE_NAME "reboot"

# 4. Vérifier après redémarrage
sinfo -N -l | grep NODE_NAME
```

---

## 💾 Restauration

### Restauration Complète

**Script** :
```bash
./scripts/backup/restore-cluster.sh
```

**Procédure Manuelle** :
```bash
# 1. Arrêter services
systemctl stop slurmctld
systemctl stop beegfs-*

# 2. Restaurer depuis backup
restic -r /backup/restic-repo restore latest --target /

# 3. Redémarrer services
systemctl start beegfs-*
systemctl start slurmctld

# 4. Vérifier
sinfo
beegfs-ctl --getentryinfo
```

---

### Restauration Partielle

**Fichiers Utilisateur** :
```bash
# Restaurer depuis backup
restic -r /backup/restic-repo restore latest --target /mnt/beegfs/home/USERNAME --include /mnt/beegfs/home/USERNAME
```

**Configuration** :
```bash
# Restaurer configuration
cp /backup/configs/slurm.conf /etc/slurm/slurm.conf
systemctl restart slurmctld
```

---

## 📋 Checklist de Maintenance

### Avant Maintenance
- [ ] Planifier fenêtre de maintenance
- [ ] Notifier utilisateurs
- [ ] Sauvegarder données
- [ ] Préparer procédures

### Pendant Maintenance
- [ ] Suivre procédures
- [ ] Documenter actions
- [ ] Tester après chaque étape
- [ ] Communiquer progrès

### Après Maintenance
- [ ] Vérifier tous les services
- [ ] Tester le cluster
- [ ] Documenter changements
- [ ] Notifier utilisateurs

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
