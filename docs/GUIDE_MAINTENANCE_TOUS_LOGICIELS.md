# 🔧 GUIDE DE MAINTENANCE - TOUS LES LOGICIELS
## Comment Maintenir Chaque Logiciel Installé

**Classification**: Guide Maintenance  
**Public**: Administrateurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Maintenance Slurm](#1-maintenance-slurm)
2. [Maintenance Stockage](#2-maintenance-stockage)
3. [Maintenance Authentification](#3-maintenance-authentification)
4. [Maintenance Monitoring](#4-maintenance-monitoring)
5. [Maintenance Applications](#5-maintenance-applications)
6. [Maintenance Bases de Données](#6-maintenance-bases-de-données)
7. [Maintenance Sécurité](#7-maintenance-sécurité)

---

## 1. Maintenance Slurm

### 1.1 Vérification

```bash
# Statut services
systemctl status slurmctld
systemctl status slurmd

# Contrôle
scontrol show nodes
scontrol show partition normal
scontrol show job JOBID
```

### 1.2 Recharger Configuration

```bash
# Recharger
scontrol reconfigure

# Redémarrer
systemctl restart slurmctld
systemctl restart slurmd
```

### 1.3 Logs

```bash
# Logs controller
tail -f /var/log/slurmctld.log

# Logs daemon
tail -f /var/log/slurmd.log
```

---

## 2. Maintenance Stockage

### 2.1 BeeGFS

**Vérification** :
```bash
# Statut
systemctl status beegfs-mgmtd
systemctl status beegfs-storage
systemctl status beegfs-client

# Nœuds
beegfs-ctl --listnodes --nodetype=storage
beegfs-ctl --listnodes --nodetype=client
```

**Logs** :
```bash
tail -f /var/log/beegfs-mgmtd.log
tail -f /var/log/beegfs-storage.log
```

---

## 3. Maintenance Authentification

### 3.1 LDAP

**Vérification** :
```bash
systemctl status dirsrv@cluster
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

**Sauvegarde** :
```bash
ldapsearch -x -b "dc=cluster,dc=local" > backup.ldif
```

**Restauration** :
```bash
ldapadd -x -D "cn=Directory Manager" -w "password" -f backup.ldif
```

---

### 3.2 Kerberos

**Vérification** :
```bash
systemctl status krb5kdc
kadmin.local -q "listprincs"
```

**Logs** :
```bash
tail -f /var/log/krb5kdc.log
```

---

## 4. Maintenance Monitoring

### 4.1 Prometheus

**Vérification** :
```bash
curl http://localhost:9090/-/healthy
```

**Reload configuration** :
```bash
curl -X POST http://localhost:9090/-/reload
```

**Logs** :
```bash
docker logs hpc-prometheus
```

---

### 4.2 Grafana

**Vérification** :
```bash
curl http://localhost:3000/api/health
```

**Backup dashboards** :
```bash
cp -r grafana-dashboards/ backup/
```

---

## 5. Maintenance Applications

### 5.1 Mise à Jour

```bash
# GROMACS
cd /opt/gromacs
git pull
make install

# OpenFOAM
# Suivre instructions mise à jour
```

---

## 6. Maintenance Bases de Données

### 6.1 PostgreSQL

**Vérification** :
```bash
systemctl status postgresql
psql -U slurm -d slurm_acct_db -c "SELECT version();"
```

**Backup** :
```bash
pg_dump -U slurm slurm_acct_db > backup.sql
```

**Restauration** :
```bash
psql -U slurm slurm_acct_db < backup.sql
```

---

## 7. Maintenance Sécurité

### 7.1 Vault

**Vérification** :
```bash
systemctl status vault
vault status
```

**Backup** :
```bash
vault operator unseal
vault operator backup backup.vault
```

---

## 📚 Documentation Complémentaire

- `docs/GUIDE_MAINTENANCE_COMPLETE.md` - Maintenance complète
- `docs/GUIDE_MISE_A_JOUR_REPARATION.md` - Mise à jour et réparation

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
