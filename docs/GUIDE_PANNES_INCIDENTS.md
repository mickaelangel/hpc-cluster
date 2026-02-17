# Guide des Pannes et Incidents - Cluster HPC
## Procédures de Diagnostic et Résolution

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Classification des Incidents](#classification-des-incidents)
2. [Procédure de Diagnostic](#procédure-de-diagnostic)
3. [Pannes Courantes](#pannes-courantes)
4. [Résolution d'Incidents](#résolution-dincidents)
5. [Procédures de Récupération](#procédures-de-récupération)
6. [Post-Mortem](#post-mortem)

---

## 🚨 Classification des Incidents

### Niveau Critique

**Définition** : Cluster entier inaccessible ou perte de données

**Exemples** :
- Tous les nœuds en panne
- Système de fichiers corrompu
- Perte de données
- Sécurité compromise

**Action** : Résolution immédiate, 24/7

---

### Niveau Haute

**Définition** : Plusieurs nœuds en panne ou service critique indisponible

**Exemples** :
- Plusieurs nœuds en panne
- SlurmCTLD arrêté
- BeeGFS inaccessible
- Authentification en panne

**Action** : Résolution dans les 4 heures

---

### Niveau Moyenne

**Définition** : Un nœud en panne ou service non critique indisponible

**Exemples** :
- Un nœud en panne
- Service monitoring arrêté
- Performance dégradée

**Action** : Résolution dans les 24 heures

---

### Niveau Basse

**Définition** : Problème mineur, impact limité

**Exemples** :
- Job en erreur
- Alerte non critique
- Performance légèrement dégradée

**Action** : Résolution dans les 5 jours

---

## 🔍 Procédure de Diagnostic

### 1. Collecte d'Informations

**Script Automatique** :
```bash
# Diagnostic complet
./scripts/troubleshooting/diagnose-cluster.sh

# Collecte logs
./scripts/troubleshooting/collect-logs.sh
```

### 2. Vérifications Système

**État des Nœuds** :
```bash
# Voir tous les nœuds
sinfo -N -l

# Nœuds en panne
sinfo -N -l | grep DOWN

# Détails d'un nœud
scontrol show node NODE_NAME
```

**Services** :
```bash
# Vérifier services critiques
systemctl status slurmctld
systemctl status beegfs-mgmtd
systemctl status sshd
```

**Réseau** :
```bash
# Test de connectivité
ping NODE_NAME
ssh NODE_NAME "hostname"

# Vérifier les interfaces
ip addr show
```

### 3. Analyse des Logs

**Logs Système** :
```bash
# Journal système
journalctl -xe

# Logs Slurm
tail -f /var/log/slurm/slurmctld.log

# Logs BeeGFS
tail -f /var/log/beegfs-*.log
```

**Logs Applications** :
```bash
# Logs Prometheus
docker logs hpc-prometheus

# Logs Grafana
docker logs hpc-grafana
```

---

## 🔧 Pannes Courantes

### 1. Nœud en Panne

**Symptômes** :
- Nœud marqué DOWN dans Slurm
- Pas de réponse SSH
- Pas de métriques dans Prometheus

**Diagnostic** :
```bash
# Vérifier l'état
sinfo -N -l | grep NODE_NAME

# Test de connectivité
ping NODE_NAME
ssh NODE_NAME "hostname"

# Logs du nœud
ssh NODE_NAME "journalctl -xe"
```

**Résolution** :
```bash
# Redémarrer le nœud
scontrol update NodeName=NODE_NAME State=RESUME

# Si échec, drainer
scontrol update NodeName=NODE_NAME State=DRAIN

# Redémarrer physiquement si nécessaire
```

---

### 2. SlurmCTLD Arrêté

**Symptômes** :
- `squeue` ne répond pas
- `sinfo` ne répond pas
- Jobs en attente

**Diagnostic** :
```bash
# Vérifier le service
systemctl status slurmctld

# Logs
tail -f /var/log/slurm/slurmctld.log
```

**Résolution** :
```bash
# Redémarrer
systemctl restart slurmctld

# Vérifier
scontrol ping
```

---

### 3. BeeGFS Inaccessible

**Symptômes** :
- Montage échoue
- Fichiers inaccessibles
- Erreurs I/O

**Diagnostic** :
```bash
# État BeeGFS
beegfs-ctl --getentryinfo

# Services
systemctl status beegfs-mgmtd
systemctl status beegfs-meta
systemctl status beegfs-storage
```

**Résolution** :
```bash
# Redémarrer services
systemctl restart beegfs-mgmtd
systemctl restart beegfs-meta
systemctl restart beegfs-storage

# Remonter
mount -t beegfs beegfs /mnt/beegfs
```

---

### 4. Authentification en Panne

**Symptômes** :
- Connexion SSH échoue
- Authentification LDAP échoue
- Tickets Kerberos invalides

**Diagnostic** :
```bash
# Test LDAP
ldapsearch -x -b "dc=cluster,dc=local"

# Test Kerberos
kinit USERNAME
klist
```

**Résolution** :
```bash
# Redémarrer services
systemctl restart slapd
systemctl restart krb5kdc

# Vérifier configuration
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

---

### 5. Espace Disque Plein

**Symptômes** :
- Erreurs "No space left"
- Écriture échoue
- Quota dépassé

**Diagnostic** :
```bash
# Espace disponible
df -h

# Quotas
beegfs-ctl --getquota --uid $USER

# Gros fichiers
du -sh /mnt/beegfs/* | sort -h
```

**Résolution** :
```bash
# Nettoyer fichiers temporaires
find /mnt/beegfs -type f -name "*.tmp" -delete

# Archiver anciens résultats
tar -czf archive.tar.gz /mnt/beegfs/old_results/

# Augmenter quota si possible
beegfs-ctl --setquota --uid $USER --size 100G
```

---

## 🛠️ Résolution d'Incidents

### Procédure Standard

**1. Détection** :
- Monitoring automatique
- Alertes Grafana
- Rapports utilisateurs

**2. Évaluation** :
- Classifier l'incident
- Évaluer l'impact
- Déterminer la priorité

**3. Résolution** :
- Suivre les procédures
- Documenter les actions
- Communiquer aux utilisateurs

**4. Vérification** :
- Tester la résolution
- Vérifier les services
- Confirmer avec utilisateurs

**5. Fermeture** :
- Documenter la résolution
- Mettre à jour la documentation
- Post-mortem si critique

---

## 🔄 Procédures de Récupération

### Récupération Complète

**Script** :
```bash
# Récupération complète
./scripts/disaster-recovery/disaster-recovery.sh
```

**Étapes** :
1. Vérifier l'état
2. Restaurer depuis backup
3. Vérifier les services
4. Tester le cluster

### Récupération Partielle

**Nœud Individuel** :
```bash
# Drainer le nœud
scontrol update NodeName=NODE_NAME State=DRAIN

# Réparer
# ... actions de réparation ...

# Remettre en service
scontrol update NodeName=NODE_NAME State=RESUME
```

---

## 📋 Post-Mortem

### Pour Incidents Critiques

**Documenter** :
- Description de l'incident
- Cause racine
- Impact
- Actions entreprises
- Temps de résolution
- Prévention

**Template** :
```markdown
# Post-Mortem - [DATE]

## Incident
Description...

## Cause Racine
...

## Impact
- Utilisateurs affectés: X
- Jobs perdus: Y
- Temps d'indisponibilité: Z

## Actions
1. ...
2. ...

## Prévention
- ...
```

---

## 📊 Tableau de Diagnostic

| Symptôme | Cause Probable | Diagnostic | Résolution |
|----------|---------------|------------|---------------|
| Nœud DOWN | Panne matérielle | `sinfo`, `ping`, `ssh` | Redémarrer, drainer |
| Slurm ne répond pas | SlurmCTLD arrêté | `systemctl status` | Redémarrer service |
| Fichiers inaccessibles | BeeGFS en panne | `beegfs-ctl` | Redémarrer services |
| Authentification échoue | LDAP/Kerberos en panne | `ldapsearch`, `kinit` | Redémarrer services |
| Espace disque plein | Quota dépassé | `df`, `beegfs-ctl` | Nettoyer, archiver |

---

## ✅ Checklist de Résolution

### Avant de Commencer
- [ ] Collecter les informations
- [ ] Classifier l'incident
- [ ] Notifier les utilisateurs
- [ ] Documenter l'incident

### Pendant la Résolution
- [ ] Suivre les procédures
- [ ] Documenter les actions
- [ ] Tester les solutions
- [ ] Communiquer les progrès

### Après la Résolution
- [ ] Vérifier la résolution
- [ ] Tester le cluster
- [ ] Documenter la solution
- [ ] Post-mortem si critique

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
