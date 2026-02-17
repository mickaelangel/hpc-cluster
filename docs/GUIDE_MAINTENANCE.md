# Guide de Maintenance du Cluster HPC
## Procédures Opérationnelles et Dépannage

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 1.0

---

## 📋 Table des Matières

1. [Maintenance Préventive](#maintenance-préventive)
2. [Maintenance des Services](#maintenance-des-services)
3. [Monitoring et Alertes](#monitoring-et-alertes)
4. [Sauvegardes](#sauvegardes)
5. [Mises à Jour](#mises-à-jour)
6. [Dépannage](#dépannage)
7. [Procédures d'Urgence](#procédures-durgence)

---

## 🔧 Maintenance Préventive

### Vérifications Quotidiennes

```bash
#!/bin/bash
# Script de vérification quotidienne

echo "=== Vérification Cluster HPC ==="

# 1. État des services
echo "Services système:"
systemctl status slurmctld --no-pager
systemctl status dirsrv@cluster --no-pager
systemctl status krb5kdc --no-pager

# 2. État des nœuds
echo "État des nœuds:"
sinfo -N -l

# 3. Jobs en cours
echo "Jobs actifs:"
squeue

# 4. Utilisation disque
echo "Utilisation stockage:"
df -h /mnt/beegfs
df -h /mnt/lustre
beegfs-ctl --listquota /mnt/beegfs

# 5. Monitoring
echo "Services monitoring:"
systemctl status prometheus --no-pager
systemctl status grafana-server --no-pager
systemctl status telegraf --no-pager

# 6. Réseau
echo "Connectivité réseau:"
ping -c 1 frontal-02
ping -c 1 node-01
```

### Vérifications Hebdomadaires

- **Logs système** : Vérifier les erreurs dans `/var/log`
- **Quotas utilisateurs** : Vérifier les dépassements
- **Sauvegardes** : Vérifier que les sauvegardes sont à jour
- **Mises à jour de sécurité** : Vérifier les patches disponibles

### Vérifications Mensuelles

- **Audit de sécurité** : Vérifier les accès et permissions
- **Performance** : Analyser les métriques de performance
- **Capacité** : Planifier l'extension si nécessaire
- **Documentation** : Mettre à jour la documentation

---

## 🔄 Maintenance des Services

### Slurm

#### Redémarrage

```bash
# Arrêter
systemctl stop slurmctld
systemctl stop slurmd

# Démarrer
systemctl start slurmctld
systemctl start slurmd

# Vérifier
scontrol ping
sinfo
```

#### Recharger la Configuration

```bash
# Sans arrêter les jobs
scontrol reconfigure
```

#### Nettoyage des Jobs Zombies

```bash
# Lister les jobs zombies
squeue | grep Z

# Nettoyer
scancel --state=ZOMBIE
```

### LDAP (389 Directory Server)

#### Redémarrage

```bash
systemctl restart dirsrv@cluster
```

#### Vérification

```bash
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

#### Indexation

```bash
# Reconstruire les index
db2index -n userRoot
```

### Kerberos

#### Redémarrage

```bash
systemctl restart krb5kdc
systemctl restart kadmin
```

#### Vérification

```bash
kadmin.local -q "listprincs"
```

#### Nettoyage des Tickets Expirés

```bash
# Les tickets expirés sont automatiquement nettoyés
# Vérifier manuellement si nécessaire
klist -A
```

### Stockage Parallèle (BeeGFS / Lustre)

#### Vérification de l'État BeeGFS

```bash
# État services
systemctl status beegfs-mgmtd beegfs-meta beegfs-storage

# Vérification montage
mountpoint -q /mnt/beegfs && echo "OK" || echo "FAIL"

# Quotas
beegfs-ctl --listquota /mnt/beegfs
```

#### Vérification de l'État Lustre

```bash
# État services
systemctl status lustre

# Vérification montage
mountpoint -q /mnt/lustre && echo "OK" || echo "FAIL"

# État filesystem
lfs df -h
```

#### Redémarrage BeeGFS

```bash
# Redémarrer services
systemctl restart beegfs-mgmtd
systemctl restart beegfs-meta
systemctl restart beegfs-storage
```

#### Redémarrage Lustre

```bash
# Redémarrer services
systemctl restart lustre
```

### Monitoring (Prometheus, Grafana, Telegraf)

#### Prometheus

```bash
# Redémarrage
systemctl restart prometheus

# Vérification
curl http://localhost:9090/-/healthy

# Recharger la configuration
curl -X POST http://localhost:9090/-/reload
```

#### Grafana

```bash
# Redémarrage
systemctl restart grafana-server

# Vérification
curl http://localhost:3000/api/health
```

#### Telegraf

```bash
# Redémarrage
systemctl restart telegraf

# Test de configuration
telegraf --config /etc/telegraf/telegraf.conf --test
```

---

## 📊 Monitoring et Alertes

### Métriques à Surveiller

1. **CPU** : Utilisation > 95%
2. **Mémoire** : Utilisation > 90%
3. **Disque** : Utilisation > 85%
4. **Réseau** : Erreurs > 0.1%
5. **Services** : État != running
6. **Jobs** : Échecs > 5%

### Configuration des Alertes

**Prometheus Alerts** (`monitoring/prometheus/alerts.yml`) :
```yaml
groups:
  - name: hpc_cluster
    rules:
      - alert: HighCPUUsage
        expr: node_cpu_usage > 0.95
        for: 5m
        annotations:
          summary: "CPU usage is above 95%"
      
      - alert: HighMemoryUsage
        expr: node_memory_usage > 0.90
        for: 5m
        annotations:
          summary: "Memory usage is above 90%"
```

### Dashboard Grafana

Accéder à `http://frontal-01:3000` pour visualiser :
- État du cluster
- Utilisation des ressources
- Jobs actifs
- Métriques BeeGFS/Lustre

---

## 💾 Sauvegardes

### Sauvegarde LDAP

```bash
#!/bin/bash
# Script de sauvegarde LDAP quotidienne

BACKUP_DIR="/backup/ldap"
DATE=$(date +%Y%m%d)

# Export LDIF
ldapsearch -x -b "dc=cluster,dc=local" > \
    ${BACKUP_DIR}/ldap_backup_${DATE}.ldif

# Compression
gzip ${BACKUP_DIR}/ldap_backup_${DATE}.ldif

# Conservation 30 jours
find ${BACKUP_DIR} -name "ldap_backup_*.ldif.gz" -mtime +30 -delete
```

### Sauvegarde Kerberos

```bash
#!/bin/bash
# Sauvegarde base de données Kerberos

BACKUP_DIR="/backup/kerberos"
DATE=$(date +%Y%m%d)

# Dump de la base
kdb5_util dump ${BACKUP_DIR}/krb5_dump_${DATE}

# Compression
gzip ${BACKUP_DIR}/krb5_dump_${DATE}
```

### Sauvegarde GPFS

```bash
# GPFS a sa propre réplication
# Vérifier la réplication
mmlsfs gpfsfs1 -Y | grep replication

# Sauvegarde des métadonnées
mmbackup config /backup/gpfs/config_$(date +%Y%m%d).tar.gz
```

### Sauvegarde Configuration Slurm

```bash
#!/bin/bash
# Sauvegarde configuration Slurm

BACKUP_DIR="/backup/slurm"
DATE=$(date +%Y%m%d)

tar czf ${BACKUP_DIR}/slurm_config_${DATE}.tar.gz \
    /etc/slurm/ \
    /var/spool/slurmctld/
```

---

## 🔄 Mises à Jour

### Mise à Jour SUSE

```bash
# Vérifier les mises à jour
zypper list-updates

# Mise à jour de sécurité
zypper patch --security

# Mise à jour complète
zypper update
```

### Mise à Jour Slurm

```bash
# Arrêter Slurm
systemctl stop slurmctld
systemctl stop slurmd

# Mise à jour
zypper update slurm

# Redémarrer
systemctl start slurmctld
systemctl start slurmd
```

### Mise à Jour Prometheus/Grafana

```bash
# Prometheus
systemctl stop prometheus
docker pull prom/prometheus:latest
# Mettre à jour docker-compose.yml
docker-compose up -d prometheus

# Grafana
systemctl stop grafana-server
zypper update grafana
systemctl start grafana-server
```

---

## 🔧 Dépannage

### Problème: Nœud Inaccessible

```bash
# Vérifier la connectivité réseau
ping node-01

# Vérifier SSH
ssh node-01 "echo 'OK'"

# Vérifier l'état Slurm
scontrol show node node-01

# Redémarrer le daemon Slurm
ssh node-01 "systemctl restart slurmd"
```

### Problème: Jobs en Échec

```bash
# Voir les logs du job
scontrol show job <job_id>

# Voir les logs système
journalctl -u slurmd -n 100

# Vérifier les ressources
sinfo -N -l
```

### Problème: GPFS Non Monté

```bash
# Vérifier l'état
mmgetstate -a
mmlsfs gpfsfs1

# Redémarrer GPFS
mmstartup -a

# Monter manuellement
mmmount gpfsfs1 -a
```

### Problème: Authentification Échouée

```bash
# Vérifier LDAP
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Vérifier Kerberos
kinit test@CLUSTER.LOCAL

# Vérifier les logs
tail -f /var/log/dirsrv/slapd-cluster/errors
tail -f /var/log/krb5kdc.log
```

---

## 🚨 Procédures d'Urgence

### Panne d'un Nœud Frontal

1. **Basculer sur le secondaire** :
   ```bash
   # Sur frontal-02
   systemctl start slurmctld
   ```

2. **Mettre à jour la configuration** :
   ```bash
   # Modifier slurm.conf pour pointer vers frontal-02
   ```

3. **Redémarrer les services** :
   ```bash
   scontrol reconfigure
   ```

### Panne Stockage

1. **Vérifier l'état** :
   ```bash
   mmgetstate -a
   mmhealth cluster show
   ```

2. **Redémarrer** :
   ```bash
   mmstartup -a
   ```

3. **Vérifier les disques** :
   ```bash
   # BeeGFS
   beegfs-ctl --listnodes
   # Lustre
   lfs df -h
   ```

### Perte de Données LDAP

1. **Arrêter le service** :
   ```bash
   systemctl stop dirsrv@cluster
   ```

2. **Restauration** :
   ```bash
   # Restaurer depuis la sauvegarde
   ldapadd -x -D "cn=Directory Manager" -w "password" \
       -f /backup/ldap/ldap_backup_YYYYMMDD.ldif
   ```

3. **Redémarrer** :
   ```bash
   systemctl start dirsrv@cluster
   ```

---

## 📚 Ressources

- **Slurm**: https://slurm.schedmd.com/troubleshooting.html
- **BeeGFS**: https://www.beegfs.io/documentation/
- **Lustre**: https://wiki.lustre.org/
- **LDAP**: https://directory.fedoraproject.org/docs/
- **Kerberos**: https://web.mit.edu/kerberos/krb5-latest/doc/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
