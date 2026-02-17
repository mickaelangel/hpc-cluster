# Disaster Recovery Plan - Cluster HPC

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Scénarios de Sinistre](#scénarios-de-sinistre)
- [Procédures de Récupération](#procédures-de-récupération)
- [Backup & Restore](#backup--restore)
- [Tests de Récupération](#tests-de-récupération)
- [Contacts d'Urgence](#contacts-durgence)

## 🎯 Vue d'ensemble

Ce document décrit les procédures de récupération en cas de sinistre pour le cluster HPC.

### Objectifs de Récupération

- **RTO (Recovery Time Objective)**: 1 heure
- **RPO (Recovery Point Objective)**: 15 minutes
- **Disponibilité cible**: 99.9%

## 🚨 Scénarios de Sinistre

### Niveau 1 - Service Individuel

**Exemples:**
- Panne d'un nœud de calcul
- Service Prometheus down
- Service Grafana down

**Impact**: Faible  
**RTO**: 15 minutes

### Niveau 2 - Service Critique

**Exemples:**
- Panne des 2 nœuds frontaux
- Perte du stockage principal
- Panne réseau majeure

**Impact**: Moyen  
**RTO**: 30 minutes

### Niveau 3 - Sinistre Complet

**Exemples:**
- Perte du datacenter
- Corruption complète des données
- Attaque de sécurité majeure

**Impact**: Critique  
**RTO**: 1 heure

## 🔄 Procédures de Récupération

### Récupération d'un Nœud

```bash
# 1. Identifier le nœud défaillant
docker ps -a | grep -i down

# 2. Redémarrer le nœud
docker-compose -f docker/docker-compose-opensource.yml restart <node-name>

# 3. Vérifier la santé
bash scripts/tests/test-cluster-health.sh
```

### Récupération du Stockage

```bash
# 1. Vérifier l'état du stockage
gluster volume status

# 2. Restaurer depuis backup
sudo bash scripts/backup/restore-storage.sh

# 3. Vérifier l'intégrité
gluster volume heal gv_hpc full
```

### Récupération Complète

```bash
# 1. Restaurer la configuration
sudo bash scripts/backup/restore-config.sh

# 2. Restaurer les données
sudo bash scripts/backup/restore-data.sh

# 3. Redémarrer les services
sudo bash scripts/deployment/deploy-production.sh

# 4. Vérification complète
sudo bash scripts/tests/test-cluster-health.sh
```

## 💾 Backup & Restore

### Stratégie de Backup

- **Fréquence**: Quotidienne (incrementiel), Hebdomadaire (complet)
- **Rétention**: 30 jours
- **Emplacement**: Stockage distant (S3, Azure Blob, etc.)

### Scripts de Backup

```bash
# Backup complet
sudo bash scripts/backup/backup-cluster.sh

# Backup incrémentiel
sudo bash scripts/backup/backup-incremental.sh

# Vérification backup
sudo bash scripts/backup/verify-backup.sh
```

### Restore

```bash
# Restore complet
sudo bash scripts/backup/restore-cluster.sh

# Restore sélectif
sudo bash scripts/backup/restore-selective.sh <component>
```

## 🧪 Tests de Récupération

### Tests Mensuels

- Test de restauration d'un nœud
- Test de restauration du stockage
- Test de restauration complète

### Procédure de Test

```bash
# 1. Créer un environnement de test
sudo bash scripts/tests/create-test-environment.sh

# 2. Simuler un sinistre
sudo bash scripts/tests/simulate-disaster.sh

# 3. Tester la récupération
sudo bash scripts/tests/test-recovery.sh

# 4. Documenter les résultats
sudo bash scripts/tests/document-recovery-test.sh
```

## 📞 Contacts d'Urgence

### Équipe DevOps

- **Chef d'équipe**: [Nom] - [Téléphone]
- **On-call**: [Nom] - [Téléphone]
- **Email**: devops@example.com

### Support Technique

- **Niveau 1**: support@example.com
- **Niveau 2**: support-escalation@example.com
- **Niveau 3**: support-critical@example.com

### Fournisseurs

- **Cloud Provider**: [Contact]
- **Stockage**: [Contact]
- **Réseau**: [Contact]

## 📊 Métriques de Récupération

### KPIs

- **MTTR (Mean Time To Recovery)**: < 1h
- **Taux de succès des récupérations**: > 95%
- **Fréquence des tests**: Mensuelle

### Reporting

- Rapport mensuel de tests de récupération
- Analyse post-incident
- Améliorations continues

## 🔗 Références

- **Runbook**: `docs/RUNBOOK.md`
- **Backup**: `scripts/backup/`
- **Monitoring**: `docs/GUIDE_MONITORING_COMPLET.md`
