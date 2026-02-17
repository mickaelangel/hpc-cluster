# Guide de Maintenance - Cluster HPC avec FreeIPA
## Procédures Opérationnelles et Dépannage

**Classification**: Documentation Opérationnelle  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 2.0 (FreeIPA)

---

## 📋 Table des Matières

1. [Maintenance Préventive](#maintenance-préventive)
2. [Maintenance FreeIPA](#maintenance-freeipa)
3. [Maintenance des Services](#maintenance-des-services)
4. [Monitoring et Alertes](#monitoring-et-alertes)
5. [Sauvegardes](#sauvegardes)
6. [Mises à Jour](#mises-à-jour)
7. [Dépannage](#dépannage)
8. [Procédures d'Urgence](#procédures-durgence)

---

## 🔧 Maintenance Préventive

### Vérifications Quotidiennes

```bash
#!/bin/bash
# Script de vérification quotidienne avec FreeIPA

echo "=== Vérification Cluster HPC (FreeIPA) ==="

# 1. FreeIPA Server
echo "FreeIPA Server:"
systemctl status ipa --no-pager
ipa ping

# 2. Services système
echo "Services système:"
systemctl status slurmctld --no-pager

# 3. État des nœuds
echo "État des nœuds:"
sinfo -N -l

# 4. Jobs en cours
echo "Jobs actifs:"
squeue

# 5. Utilisation disque
echo "Utilisation GPFS:"
df -h /gpfs/gpfsfs1
mmlsquota -a /gpfs/gpfsfs1

# 6. Monitoring
echo "Services monitoring:"
systemctl status prometheus --no-pager
systemctl status grafana-server --no-pager

# 7. FreeIPA Clients
echo "FreeIPA Clients:"
for node in node-01 node-02 node-03 node-04 node-05 node-06; do
    ssh $node "ipa-client-status" 2>/dev/null | grep -q "FreeIPA" && \
        echo "  ✅ $node: Client actif" || \
        echo "  ❌ $node: Client inactif"
done
```

### Vérifications Hebdomadaires

- **Logs FreeIPA** : Vérifier les erreurs dans `/var/log/ipa*`
- **Synchronisation** : Vérifier la synchronisation LDAP ↔ Kerberos
- **Quotas utilisateurs** : Vérifier les dépassements
- **Sauvegardes** : Vérifier que les sauvegardes sont à jour
- **Mises à jour de sécurité** : Vérifier les patches disponibles

### Vérifications Mensuelles

- **Audit de sécurité** : Vérifier les accès et permissions
- **Performance** : Analyser les métriques de performance
- **Capacité** : Planifier l'extension si nécessaire
- **Documentation** : Mettre à jour la documentation

---

## 🔄 Maintenance FreeIPA

### Redémarrage

```bash
# Arrêter FreeIPA
systemctl stop ipa

# Démarrer FreeIPA
systemctl start ipa

# Vérifier
ipa ping
```

### Vérification de l'État

```bash
# État général
ipa ping

# Vérifier la configuration
ipa env

# Vérifier les services
ipa service-find

# Vérifier les utilisateurs
ipa user-find
```

### Gestion des Réplicas

```bash
# Lister les replicas
ipa-replica-manage list

# Créer un replica (sur frontal-02)
ipa-replica-install \
    --principal=admin \
    --admin-password='AdminPassword123!' \
    --setup-dns \
    --no-ntp

# Vérifier la réplication
ipa-replica-manage list
```

### Nettoyage

```bash
# Nettoyage des tickets expirés (automatique)
# Vérifier manuellement si nécessaire
klist -A

# Nettoyage des logs
journalctl --vacuum-time=30d
```

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

### GPFS

#### Vérification de l'État

```bash
mmlscluster
mmlsfs gpfsfs1
mmgetstate -a
```

#### Redémarrage

```bash
# Arrêter
mm shutdown -a

# Démarrer
mmstartup -a
```

### Monitoring (Prometheus, Grafana, Telegraf)

Voir `GUIDE_MAINTENANCE.md` - identique

---

## 📊 Monitoring et Alertes

### Métriques FreeIPA à Surveiller

1. **État du serveur** : Service actif/inactif
2. **Connectivité** : Réponses aux requêtes
3. **Réplication** : État des replicas
4. **Authentifications** : Taux d'échec
5. **Tickets Kerberos** : Expiration, renouvellement

### Configuration des Alertes

**Prometheus Alerts** :
```yaml
groups:
  - name: freeipa_cluster
    rules:
      - alert: FreeIPAServerDown
        expr: up{job="freeipa"} == 0
        for: 5m
        annotations:
          summary: "FreeIPA server is down"
      
      - alert: FreeIPAAuthFailures
        expr: rate(freeipa_auth_failures[5m]) > 10
        for: 5m
        annotations:
          summary: "High authentication failure rate"
```

---

## 💾 Sauvegardes

### Sauvegarde FreeIPA

```bash
#!/bin/bash
# Script de sauvegarde FreeIPA quotidienne

BACKUP_DIR="/backup/freeipa"
DATE=$(date +%Y%m%d)

# Sauvegarde complète
ipa-backup --online --data

# La sauvegarde est dans /var/lib/ipa/backup/
# Copier vers le répertoire de backup
cp -r /var/lib/ipa/backup/ipa-data-${DATE}* ${BACKUP_DIR}/

# Compression
tar czf ${BACKUP_DIR}/freeipa_backup_${DATE}.tar.gz \
    ${BACKUP_DIR}/ipa-data-${DATE}*

# Conservation 30 jours
find ${BACKUP_DIR} -name "freeipa_backup_*.tar.gz" -mtime +30 -delete
```

### Restauration FreeIPA

```bash
# Restauration
ipa-restore /backup/freeipa/freeipa_backup_YYYYMMDD.tar.gz
```

### Export LDAP (via FreeIPA)

```bash
# Export LDIF
ldapsearch -x -b "dc=cluster,dc=local" > \
    /backup/freeipa/ldap_export_$(date +%Y%m%d).ldif

# Compression
gzip /backup/freeipa/ldap_export_*.ldif
```

### Sauvegarde Configuration Slurm

Voir `GUIDE_MAINTENANCE.md` - identique

---

## 🔄 Mises à Jour

### Mise à Jour FreeIPA

```bash
# Vérifier les mises à jour
zypper list-updates | grep freeipa

# Mise à jour
zypper update freeipa-server freeipa-client

# Redémarrer
systemctl restart ipa
```

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

Voir `GUIDE_MAINTENANCE.md` - identique

---

## 🔧 Dépannage

### Problème: FreeIPA Inaccessible

```bash
# Vérifier l'état
systemctl status ipa

# Test de connectivité
ipa ping

# Vérifier les logs
tail -f /var/log/ipaserver-install.log
tail -f /var/log/dirsrv/slapd-*/errors

# Redémarrer
systemctl restart ipa
```

### Problème: Client FreeIPA Non Fonctionnel

```bash
# Vérifier l'état du client
ipa-client-status

# Réinitialiser le client
ipa-client-install --uninstall
ipa-client-install \
    --domain=cluster.local \
    --server=ipa.cluster.local \
    --realm=CLUSTER.LOCAL \
    --principal=admin \
    --password='AdminPassword123!' \
    --unattended
```

### Problème: Authentification Échouée

```bash
# Vérifier le ticket
klist

# Obtenir un nouveau ticket
kdestroy
kinit admin@CLUSTER.LOCAL

# Vérifier l'utilisateur
ipa user-find jdoe

# Vérifier les logs
tail -f /var/log/krb5kdc.log
```

### Problème: Synchronisation LDAP ↔ Kerberos

```bash
# Avec FreeIPA, la synchronisation est automatique
# Vérifier l'utilisateur dans les deux
ipa user-show jdoe --all

# Si problème, forcer la synchronisation
ipa user-mod jdoe --password
```

### Problème: DNS Non Fonctionnel

```bash
# Vérifier la résolution
nslookup ipa.cluster.local
dig ipa.cluster.local

# Vérifier les enregistrements
ipa dnsrecord-find cluster.local

# Redémarrer le service DNS
systemctl restart ipa
```

---

## 🚨 Procédures d'Urgence

### Panne FreeIPA Server

1. **Vérifier l'état** :
   ```bash
   systemctl status ipa
   ipa ping
   ```

2. **Redémarrer** :
   ```bash
   systemctl restart ipa
   ```

3. **Si échec, utiliser le replica** :
   ```bash
   # Sur frontal-02 (si replica configuré)
   # Le replica prend le relais automatiquement
   ```

4. **Restauration depuis sauvegarde** :
   ```bash
   ipa-restore /backup/freeipa/freeipa_backup_YYYYMMDD.tar.gz
   ```

### Perte de Données FreeIPA

1. **Arrêter le service** :
   ```bash
   systemctl stop ipa
   ```

2. **Restauration** :
   ```bash
   ipa-restore /backup/freeipa/freeipa_backup_YYYYMMDD.tar.gz
   ```

3. **Redémarrer** :
   ```bash
   systemctl start ipa
   ```

4. **Vérifier** :
   ```bash
   ipa ping
   ipa user-find
   ```

### Panne d'un Nœud Frontal

Voir `GUIDE_MAINTENANCE.md` - identique

### Panne GPFS

Voir `GUIDE_MAINTENANCE.md` - identique

---

## 📚 Commandes Utiles FreeIPA

### Utilisateurs

```bash
ipa user-find              # Lister tous les utilisateurs
ipa user-show jdoe          # Afficher un utilisateur
ipa user-add ...           # Créer un utilisateur
ipa user-mod ...            # Modifier un utilisateur
ipa user-del jdoe           # Supprimer un utilisateur
```

### Groupes

```bash
ipa group-find              # Lister tous les groupes
ipa group-show hpc-users    # Afficher un groupe
ipa group-add ...           # Créer un groupe
ipa group-add-member ...    # Ajouter membre
```

### Services

```bash
ipa service-find            # Lister les services
ipa service-add HTTP/frontal-01  # Ajouter un service
```

### Politiques

```bash
ipa pwpolicy-show           # Afficher les politiques
ipa hbacrule-find           # Lister les règles d'accès
```

### DNS

```bash
ipa dnsrecord-find cluster.local  # Lister les enregistrements
ipa dnsrecord-add ...       # Ajouter un enregistrement
```

### Maintenance

```bash
ipa ping                    # Test de connectivité
ipa env                     # Configuration
ipa-replica-manage list     # Lister les replicas
ipa-backup                  # Sauvegarde
ipa-restore                 # Restauration
```

---

## 📚 Ressources

- **FreeIPA Documentation** : https://www.freeipa.org/page/Documentation
- **FreeIPA Troubleshooting** : https://www.freeipa.org/page/Troubleshooting
- **Slurm**: https://slurm.schedmd.com/troubleshooting.html
- **GPFS**: IBM Spectrum Scale Administration Guide

---

**Version**: 2.0 (FreeIPA)  
**Dernière mise à jour**: 2024
