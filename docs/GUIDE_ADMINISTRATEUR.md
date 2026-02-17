# Guide Administrateur - Cluster HPC
## Guide Complet pour Administrateurs Système

**Classification**: Documentation Administrateur  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Gestion Utilisateurs](#gestion-utilisateurs)
2. [Gestion Quotas](#gestion-quotas)
3. [Gestion Partitions Slurm](#gestion-partitions-slurm)
4. [Monitoring Avancé](#monitoring-avancé)
5. [Troubleshooting Avancé](#troubleshooting-avancé)
6. [Optimisation Cluster](#optimisation-cluster)

---

## 👥 Gestion Utilisateurs

### Création Utilisateur LDAP

```bash
# Créer utilisateur
ldapadd -x -D "cn=admin,dc=cluster,dc=local" -w password <<EOF
dn: uid=user1,ou=people,dc=cluster,dc=local
objectClass: inetOrgPerson
uid: user1
sn: User
givenName: Test
cn: Test User
userPassword: {SSHA}password
EOF
```

### Création Utilisateur FreeIPA

```bash
# Créer utilisateur
ipa user-add user1 --first=Test --last=User --password
```

---

## 📊 Gestion Quotas

### Configuration Quotas BeeGFS

```bash
# Définir quota utilisateur
beegfs-ctl --setquota --uid=1001 --limit=100G /mnt/beegfs

# Vérifier quota
beegfs-ctl --listquota --uid=1001 /mnt/beegfs
```

---

## 🔧 Gestion Partitions Slurm

### Créer Partition

```bash
# Éditer slurm.conf
vim /etc/slurm/slurm.conf

# Ajouter partition
PartitionName=compute Nodes=compute-[01-06] Default=YES MaxTime=INFINITE State=UP

# Recharger
scontrol reconfig
```

---

## 📈 Monitoring Avancé

### Métriques Personnalisées

```bash
# Exporter métrique custom
echo "custom_metric 123" >> /var/lib/prometheus/node-exporter/custom.prom
```

---

## 🔧 Troubleshooting Avancé

### Debug Slurm

```bash
# Logs détaillés
slurmctld -D -vvv

# Vérifier configuration
scontrol show config
```

---

## 📚 Documentation Complémentaire

- `GUIDE_MAINTENANCE_COMPLETE.md` - Maintenance
- `GUIDE_TROUBLESHOOTING.md` - Troubleshooting
- `GUIDE_SECURITE_AVANCEE.md` - Sécurité

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
