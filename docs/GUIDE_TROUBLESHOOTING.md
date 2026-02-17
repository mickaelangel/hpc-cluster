# Guide de Troubleshooting - Cluster HPC
## Diagnostic et Résolution de Problèmes

**Classification**: Documentation Technique  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Scripts de Diagnostic](#scripts-de-diagnostic)
3. [Problèmes Courants](#problèmes-courants)
4. [Résolution par Composant](#résolution-par-composant)
5. [Collection de Logs](#collection-de-logs)

---

## 🎯 Vue d'ensemble

Ce guide explique comment diagnostiquer et résoudre les problèmes courants du cluster HPC.

### Scripts Disponibles

- `diagnose-cluster.sh` - Diagnostic complet automatique
- `collect-logs.sh` - Collection de tous les logs

---

## 🔍 Scripts de Diagnostic

### Diagnostic Complet

```bash
cd cluster\ hpc/scripts/troubleshooting
sudo ./diagnose-cluster.sh
```

**Ce que fait le script** :
- Vérifie l'état du système (CPU, mémoire, disque)
- Vérifie le réseau (interfaces, routes, DNS)
- Vérifie tous les services
- Vérifie LDAP, Kerberos, Slurm, GPFS
- Vérifie le monitoring
- Génère un rapport complet

**Rapport généré** : `/tmp/cluster-diagnostic-YYYYMMDD_HHMMSS/diagnostic-report.txt`

### Collection de Logs

```bash
cd cluster\ hpc/scripts/troubleshooting
sudo ./collect-logs.sh
```

**Ce que fait le script** :
- Collecte tous les logs système
- Collecte les logs LDAP, Kerberos, Slurm
- Collecte les logs monitoring
- Collecte les configurations
- Crée une archive compressée

**Archive générée** : `/tmp/cluster-logs-YYYYMMDD_HHMMSS.tar.gz`

---

## 🔧 Problèmes Courants

### 1. Service Ne Démarre Pas

**Symptômes** :
- `systemctl status <service>` montre "failed"
- Le service ne répond pas

**Solutions** :
```bash
# Vérifier les logs
journalctl -u <service> -n 50

# Vérifier les dépendances
systemctl list-dependencies <service>

# Redémarrer
systemctl restart <service>

# Vérifier la configuration
<service> -t  # Test de configuration (si disponible)
```

### 2. LDAP Non Accessible

**Symptômes** :
- `ldapsearch` échoue
- Authentification échoue

**Solutions** :
```bash
# Vérifier le service
systemctl status dirsrv@cluster

# Vérifier les logs
tail -f /var/log/dirsrv/slapd-cluster/errors

# Tester la connexion
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Vérifier les ports
ss -tlnp | grep 389
```

### 3. Kerberos Tickets Échouent

**Symptômes** :
- `kinit` échoue
- Tickets invalides

**Solutions** :
```bash
# Vérifier le service
systemctl status krb5kdc

# Vérifier les logs
tail -f /var/log/krb5kdc.log

# Vérifier la configuration
cat /etc/krb5.conf

# Tester avec admin
kinit admin/admin@CLUSTER.LOCAL
```

### 4. Slurm Jobs Ne Se Lancent Pas

**Symptômes** :
- Jobs restent en "PENDING"
- Erreurs de soumission

**Solutions** :
```bash
# Vérifier SlurmCTLD
scontrol ping

# Vérifier les nœuds
sinfo -N -l

# Vérifier Munge
systemctl status munge
munge -n | unmunge

# Vérifier les logs
tail -f /var/log/slurm/slurmctld.log
```

### 5. GPFS Non Monté

**Symptômes** :
- `/gpfs` non accessible
- Erreurs de montage

**Solutions** :
```bash
# Vérifier l'état GPFS
mmgetstate -a

# Vérifier les montages
mount | grep gpfs

# Vérifier les logs
tail -f /var/mmfs/log/mmfs.log
```

---

## 🔍 Résolution par Composant

### LDAP

**Problèmes fréquents** :
1. Service arrêté
2. Port bloqué
3. Configuration incorrecte
4. Base de données corrompue

**Commandes de diagnostic** :
```bash
systemctl status dirsrv@cluster
ldapsearch -x -b "dc=cluster,dc=local" -s base
ss -tlnp | grep 389
```

### Kerberos

**Problèmes fréquents** :
1. KDC arrêté
2. Base de données corrompue
3. Configuration incorrecte
4. Horloge désynchronisée

**Commandes de diagnostic** :
```bash
systemctl status krb5kdc
kinit admin/admin@CLUSTER.LOCAL
klist
date  # Vérifier synchronisation temps
```

### Slurm

**Problèmes fréquents** :
1. SlurmCTLD arrêté
2. Munge non fonctionnel
3. Nœuds non disponibles
4. Configuration incorrecte

**Commandes de diagnostic** :
```bash
scontrol ping
sinfo -N -l
squeue
systemctl status munge
```

### GPFS

**Problèmes fréquents** :
1. Service arrêté
2. Disques non accessibles
3. Quotas dépassés
4. Réseau de stockage défaillant

**Commandes de diagnostic** :
```bash
mmgetstate -a
mmdf -Y
mmdefquota -j
```

---

## 📊 Collection de Logs

### Quand Collecter les Logs

- Avant de modifier une configuration
- Après un problème
- Pour analyse approfondie
- Pour support technique

### Utilisation

```bash
cd cluster\ hpc/scripts/troubleshooting
sudo ./collect-logs.sh
```

**Contenu de l'archive** :
- Logs système (journalctl, dmesg)
- Logs LDAP
- Logs Kerberos
- Logs Slurm
- Logs monitoring
- Configurations

---

## 🚨 Procédures d'Urgence

### Cluster Complètement Inaccessible

1. **Vérifier la connectivité réseau** :
   ```bash
   ping -c 3 frontal-01
   ```

2. **Vérifier les services critiques** :
   ```bash
   systemctl status sshd
   systemctl status network
   ```

3. **Accès console** :
   - Accès physique si possible
   - Console IPMI/iDRAC
   - Console série

### Perte de Données

1. **Arrêter les écritures** :
   ```bash
   systemctl stop slurmctld
   ```

2. **Vérifier les backups** :
   ```bash
   ls -lh /backup/cluster/
   ```

3. **Restauration** :
   ```bash
   cd cluster\ hpc/scripts/backup
   sudo ./restore-cluster.sh <backup-archive>
   ```

---

## 📚 Ressources

- **Slurm Troubleshooting** : https://slurm.schedmd.com/troubleshooting.html
- **LDAP Troubleshooting** : https://directory.fedoraproject.org/docs/
- **Kerberos Troubleshooting** : https://web.mit.edu/kerberos/krb5-latest/doc/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
