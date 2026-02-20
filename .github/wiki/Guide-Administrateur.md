# 👨‍💼 Guide Administrateur — Administration complète

> **Guide complet pour administrateurs système du Cluster HPC Enterprise**

---

## 🎯 Vue d'ensemble

Ce guide couvre les tâches d’**administration** du cluster : gestion des utilisateurs, quotas, partitions Slurm, monitoring, dépannage et optimisation.

---

## 👥 Gestion des utilisateurs

### LDAP

```bash
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

### FreeIPA

```bash
ipa user-add user1 --first=Test --last=User --password
```

---

## 📊 Gestion des quotas (BeeGFS)

```bash
# Définir quota
beegfs-ctl --setquota --uid=1001 --limit=100G /mnt/beegfs

# Vérifier
beegfs-ctl --listquota --uid=1001 /mnt/beegfs
```

---

## 🔧 Partitions Slurm

- Édition de `/etc/slurm/slurm.conf` pour ajouter ou modifier des partitions
- Rechargement : `scontrol reconfigure` ou redémarrage de `slurmctld` selon la config

---

## 📚 Documentation complète

- **Guide administrateur** : [docs/GUIDE_ADMINISTRATEUR.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_ADMINISTRATEUR.md)

---

## Voir aussi

- **[Maintenance](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Maintenance.md)** — Opérations et dépannage
- **[Sécurité](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Securite.md)** — Sécurité avancée
- **[Monitoring](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Monitoring.md)** — Observabilité
- **[Home](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)** — Accueil du wiki

---

[← Accueil](https://github.com/mickaelangel/hpc-cluster/blob/main/.github/wiki/Home.md)
