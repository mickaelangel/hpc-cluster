# 🔧 Maintenance — Maintenance et opérations

> **Procédures opérationnelles, vérifications et dépannage du cluster**

---

## 🎯 Vue d'ensemble

Ce guide décrit les **procédures de maintenance** : préventive, services, monitoring, sauvegardes, mises à jour et dépannage.

---

## 🔧 Maintenance préventive

### Vérifications quotidiennes

```bash
# État des services
systemctl status slurmctld --no-pager
systemctl status dirsrv@cluster --no-pager

# État des nœuds
sinfo -N -l

# Jobs actifs
squeue

# Stockage et quotas
df -h /mnt/beegfs
beegfs-ctl --listquota /mnt/beegfs

# Monitoring
systemctl status prometheus --no-pager
systemctl status grafana-server --no-pager
```

### Vérifications hebdomadaires

- Logs système (`/var/log`)
- Quotas et dépassements
- Sauvegardes à jour
- Patches de sécurité disponibles

---

## 📋 Thèmes couverts

| Thème | Contenu |
|--------|--------|
| **Services** | Slurm, LDAP/FreeIPA, Kerberos, stockage |
| **Monitoring** | Prometheus, Grafana, Telegraf, alertes |
| **Sauvegardes** | Stratégie, vérification des backups |
| **Mises à jour** | Procédures de mise à jour et réparation |
| **Dépannage** | Diagnostic, runbooks, procédures d’urgence |

---

## 📚 Documentation complète

- **Guide maintenance** : [docs/GUIDE_MAINTENANCE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_MAINTENANCE.md)
- **Guide maintenance complète** : [docs/GUIDE_MAINTENANCE_COMPLETE.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_MAINTENANCE_COMPLETE.md)
- **Maintenance tous logiciels** : [docs/GUIDE_MAINTENANCE_TOUS_LOGICIELS.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_MAINTENANCE_TOUS_LOGICIELS.md)

---

## Voir aussi

- **[Guide Administrateur](Guide-Administrateur)** — Administration complète
- **[Sécurité](Securite)** — Sécurité avancée
- **[Dépannage](Depannage)** — Solutions aux problèmes courants
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
