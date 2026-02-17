# Guide de Disaster Recovery - Cluster HPC
## Procédures de Récupération en Cas de Catastrophe

**Classification**: Documentation Technique  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Scénarios de Catastrophe](#scénarios-de-catastrophe)
3. [Procédures de Récupération](#procédures-de-récupération)
4. [Tests de Récupération](#tests-de-récupération)
5. [Plan de Continuité](#plan-de-continuité)

---

## 🎯 Vue d'ensemble

Ce guide explique les procédures de récupération en cas de catastrophe majeure du cluster HPC.

### Principes

1. **Backup régulier** : Backups quotidiens
2. **Documentation** : Procédures documentées
3. **Tests** : Tests réguliers de restauration
4. **Récupération rapide** : Objectif < 4 heures

---

## 🚨 Scénarios de Catastrophe

### 1. Perte Complète du Cluster

**Causes** :
- Incendie, inondation
- Panne électrique prolongée
- Défaillance matérielle majeure

**Impact** :
- Perte de tous les services
- Perte de données si pas de backup

**Récupération** :
- Restauration complète depuis backup
- Réinstallation des nœuds
- Restauration des configurations

### 2. Perte du Nœud Frontal Principal

**Causes** :
- Défaillance matérielle
- Corruption système

**Impact** :
- Services critiques arrêtés
- Jobs en cours perdus

**Récupération** :
- Basculement vers nœud secondaire
- Restauration depuis backup

### 3. Perte de Données GPFS

**Causes** :
- Corruption fichiers
- Erreur humaine
- Attaque malveillante

**Impact** :
- Données utilisateurs perdues
- Jobs ne peuvent plus s'exécuter

**Récupération** :
- Restauration depuis backup GPFS
- Vérification intégrité

### 4. Corruption LDAP/Kerberos

**Causes** :
- Corruption base de données
- Erreur de configuration

**Impact** :
- Authentification impossible
- Accès refusé

**Récupération** :
- Restauration LDAP/Kerberos
- Vérification utilisateurs

---

## 🔄 Procédures de Récupération

### Script de Disaster Recovery

```bash
cd cluster\ hpc/scripts/disaster-recovery
sudo ./disaster-recovery.sh
```

**Options** :
1. Restauration complète
2. Restauration LDAP uniquement
3. Restauration Kerberos uniquement
4. Restauration Slurm uniquement
5. Restauration GPFS uniquement
6. Vérification état actuel

### Restauration Complète

**Étapes** :
1. Vérifier les backups disponibles
2. Arrêter tous les services
3. Restaurer depuis backup
4. Vérifier les services
5. Tester l'authentification
6. Tester la soumission de jobs

**Commande** :
```bash
cd cluster\ hpc/scripts/backup
sudo ./restore-cluster.sh /backup/cluster/cluster-backup-YYYYMMDD_HHMMSS.tar.gz
```

### Restauration Sélective

**LDAP uniquement** :
```bash
sudo ./restore-cluster.sh <backup> --selective ldap
```

**Kerberos uniquement** :
```bash
sudo ./restore-cluster.sh <backup> --selective kerberos
```

**Slurm uniquement** :
```bash
sudo ./restore-cluster.sh <backup> --selective slurm
```

**GPFS uniquement** :
```bash
sudo ./restore-cluster.sh <backup> --selective gpfs
```

---

## ✅ Tests de Récupération

### Test Mensuel

**Objectif** : Vérifier que les backups sont restaurables

**Procédure** :
1. Choisir un backup récent
2. Restaurer sur environnement de test
3. Vérifier tous les services
4. Documenter les résultats

**Commande** :
```bash
# Sur environnement de test
cd cluster\ hpc/scripts/disaster-recovery
sudo ./disaster-recovery.sh
# Choisir option 1 (Restauration complète)
```

### Test Trimestriel

**Objectif** : Test de récupération complète

**Procédure** :
1. Simuler perte complète
2. Restaurer depuis backup
3. Mesurer temps de récupération
4. Documenter les problèmes

---

## 📋 Plan de Continuité

### RTO (Recovery Time Objective)

- **Services critiques** : < 2 heures
- **Services standards** : < 4 heures
- **Services non critiques** : < 24 heures

### RPO (Recovery Point Objective)

- **Données critiques** : < 1 heure (backup horaire)
- **Données standards** : < 24 heures (backup quotidien)
- **Données non critiques** : < 7 jours

### Checklist de Récupération

- [ ] Identifier le problème
- [ ] Évaluer l'impact
- [ ] Choisir le backup approprié
- [ ] Restaurer les services
- [ ] Vérifier le fonctionnement
- [ ] Notifier les utilisateurs
- [ ] Documenter l'incident

---

## 📚 Ressources

- **Backup/Restore Guide** : `docs/GUIDE_BACKUP_RESTORE.md`
- **Troubleshooting Guide** : `docs/GUIDE_TROUBLESHOOTING.md`
- **Architecture Guide** : `docs/ARCHITECTURE.md`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
