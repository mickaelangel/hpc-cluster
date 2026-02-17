# Guide Complet de Maintenance - Cluster HPC
## Maintenance, Mise à Jour, Réparation, Debug, Troubleshooting

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Maintenance Préventive](#maintenance-préventive)
2. [Mise à Jour](#mise-à-jour)
3. [Réparation](#réparation)
4. [Debug](#debug)
5. [Troubleshooting](#troubleshooting)
6. [Gestion des Pannes](#gestion-des-pannes)
7. [Gestion des Incidents](#gestion-des-incidents)

---

## 🔧 Maintenance Préventive

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
- Vérifier les logs d'erreur
- Nettoyer les fichiers temporaires
- Vérifier les quotas utilisateurs

---

### Hebdomadaire

**Vérifications** :
```bash
# Performance du cluster
sinfo -o "%P %a %l %D %T %N %C"

# Utilisation des ressources
sreport cluster Utilization

# Logs système
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
# Santé du système de fichiers
beegfs-ctl --getentryinfo

# Sécurité
fail2ban-client status
auditctl -l

# Conformité
./scripts/compliance/validate-compliance.sh
```

**Actions** :
- Mise à jour de sécurité
- Audit de conformité
- Revue des configurations

---

## 🔄 Mise à Jour

### Mise à Jour des Conteneurs Docker

```bash
cd docker

# Arrêter les conteneurs
docker-compose down

# Rebuild les images
docker-compose build --no-cache

# Redémarrer
docker-compose up -d

# Vérifier
docker-compose ps
docker-compose logs
```

### Mise à Jour des Applications

```bash
# GROMACS
cd scripts/software
sudo ./install-gromacs.sh

# OpenFOAM
sudo ./install-openfoam.sh

# Quantum ESPRESSO
sudo ./install-quantum-espresso.sh

# ParaView
sudo ./install-paraview.sh
```

### Mise à Jour du Système

```bash
# Mise à jour SUSE
zypper refresh
zypper update

# Redémarrer si nécessaire
reboot
```

---

## 🔨 Réparation

### Nœud en Panne

**Diagnostic** :
```bash
# Vérifier l'état
sinfo -N -l | grep DOWN

# Logs du nœud
ssh node-XX "journalctl -xe"

# Test de connectivité
ping node-XX
ssh node-XX "hostname"
```

**Réparation** :
```bash
# Redémarrer le nœud
scontrol update NodeName=node-XX State=RESUME

# Si échec, drainer le nœud
scontrol update NodeName=node-XX State=DRAIN

# Redémarrer physiquement si nécessaire
```

### Système de Fichiers Corrompu

**Diagnostic** :
```bash
# Vérifier BeeGFS
beegfs-ctl --getentryinfo

# Vérifier l'intégrité
beegfs-checkfs
```

**Réparation** :
```bash
# Réparer si possible
beegfs-checkfs --repair

# Restaurer depuis backup si nécessaire
./scripts/backup/restore-cluster.sh
```

### Service en Panne

**Diagnostic** :
```bash
# Vérifier le service
systemctl status SERVICE_NAME

# Logs
journalctl -u SERVICE_NAME -xe

# Test de connexion
systemctl restart SERVICE_NAME
```

**Réparation** :
```bash
# Redémarrer le service
systemctl restart SERVICE_NAME

# Vérifier la configuration
SERVICE_NAME --config-check

# Réinstaller si nécessaire
```

---

## 🐛 Debug

### Debug d'un Job

**Collecte d'Informations** :
```bash
# Détails du job
scontrol show job JOB_ID

# Logs du job
cat slurm-JOB_ID.out
cat slurm-JOB_ID.err

# Ressources utilisées
seff JOB_ID
```

**Analyse** :
```bash
# Vérifier les ressources demandées
# Comparer avec les ressources disponibles
sinfo -o "%P %a %l %D %T %N %C"

# Vérifier les dépendances
module list
which APPLICATION
```

### Debug de Performance

**Outils** :
```bash
# Monitoring
htop
iotop
nethogs

# Profiling
perf record APPLICATION
perf report
```

---

## 🔍 Troubleshooting

### Problèmes Courants

#### 1. Job en Attente Indéfiniment

**Diagnostic** :
```bash
# Vérifier les ressources
sinfo -o "%P %a %l %D %T %N %C"

# Vérifier les partitions
sinfo -p PARTITION_NAME

# Vérifier les contraintes
scontrol show job JOB_ID
```

**Solutions** :
- Réduire les ressources demandées
- Changer de partition
- Vérifier les contraintes

#### 2. Erreur d'Authentification

**Diagnostic** :
```bash
# Tester LDAP
ldapsearch -x -b "dc=cluster,dc=local"

# Tester Kerberos
kinit USERNAME
klist
```

**Solutions** :
- Vérifier les credentials
- Renouveler le ticket Kerberos
- Vérifier la configuration LDAP

#### 3. Espace Disque Plein

**Diagnostic** :
```bash
# Vérifier l'espace
df -h

# Voir les gros fichiers
du -sh /mnt/beegfs/* | sort -h

# Vérifier les quotas
beegfs-ctl --getquota --uid $USER
```

**Solutions** :
- Nettoyer les fichiers temporaires
- Archiver les anciens résultats
- Augmenter l'espace si possible

---

## 🚨 Gestion des Pannes

### Procédure de Panne

**1. Détection** :
```bash
# Monitoring automatique
./scripts/troubleshooting/diagnose-cluster.sh

# Alertes Grafana
# Vérifier les notifications
```

**2. Évaluation** :
```bash
# Impact
# - Nombre d'utilisateurs affectés
# - Jobs en cours
# - Services critiques

# Priorité
# - Critique : Cluster entier
# - Haute : Plusieurs nœuds
# - Moyenne : Un nœud
# - Basse : Service non critique
```

**3. Résolution** :
```bash
# Suivre les procédures de réparation
# Documenter les actions
# Communiquer aux utilisateurs
```

**4. Post-Mortem** :
```bash
# Analyser la cause
# Documenter la solution
# Prévenir les récurrences
```

---

## 📋 Gestion des Incidents

### Classification des Incidents

**Critique** :
- Cluster entier inaccessible
- Perte de données
- Sécurité compromise

**Haute** :
- Plusieurs nœuds en panne
- Service critique indisponible
- Performance dégradée

**Moyenne** :
- Un nœud en panne
- Service non critique indisponible

**Basse** :
- Problème mineur
- Impact limité

### Procédure d'Incident

**1. Enregistrement** :
```bash
# Créer un ticket
# Documenter :
# - Description
# - Impact
# - Priorité
# - Actions entreprises
```

**2. Escalade** :
```bash
# Si non résolu rapidement
# Escalader selon la priorité
```

**3. Résolution** :
```bash
# Appliquer la solution
# Vérifier la résolution
# Documenter
```

**4. Fermeture** :
```bash
# Valider avec l'utilisateur
# Fermer le ticket
# Mettre à jour la documentation
```

---

## 📚 Scripts de Maintenance

### Scripts Disponibles

```bash
# Diagnostic
./scripts/troubleshooting/diagnose-cluster.sh

# Collecte de logs
./scripts/troubleshooting/collect-logs.sh

# Backup
./scripts/backup/backup-cluster.sh

# Restauration
./scripts/backup/restore-cluster.sh

# Mise à jour
./scripts/maintenance/update-cluster.sh

# Tests
./scripts/tests/test-cluster-health.sh
```

---

## ✅ Checklist de Maintenance

### Quotidienne
- [ ] Vérifier l'état des nœuds
- [ ] Vérifier les jobs en erreur
- [ ] Vérifier l'espace disque
- [ ] Vérifier les services critiques

### Hebdomadaire
- [ ] Analyser les performances
- [ ] Nettoyer les anciens jobs
- [ ] Vérifier les sauvegardes
- [ ] Revue des logs

### Mensuelle
- [ ] Mise à jour de sécurité
- [ ] Audit de conformité
- [ ] Revue des configurations
- [ ] Planification des améliorations

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
