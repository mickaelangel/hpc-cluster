# Cluster HPC - Documentation Complète
## Guide de Démarrage Rapide

**Version**: 1.0  
**Date**: 2024

---

## 🎯 Vue d'Ensemble

Ce projet est une infrastructure complète de cluster HPC avec :
- Authentification centralisée (LDAP + Kerberos ou FreeIPA)
- Scheduler de jobs (Slurm)
- Stockage partagé (GPFS)
- Monitoring complet (Prometheus, Grafana)
- Sécurité renforcée (DISA STIG, CIS Level 2)

---

## 🚀 Démarrage Rapide

### Pour les Administrateurs

1. **Installation** :
   ```bash
   cd cluster\ hpc/scripts
   sudo ./install-ldap-kerberos.sh
   ```

2. **Hardening** :
   ```bash
   cd security
   sudo ./hardening.sh
   ```

3. **Backup** :
   ```bash
   cd ../backup
   sudo ./backup-cluster.sh
   ```

### Pour les Utilisateurs

1. **Connexion** :
   ```bash
   ssh votre-utilisateur@frontal-01.cluster.local
   ```

2. **Authentification** :
   ```bash
   kinit votre-utilisateur@CLUSTER.LOCAL
   ```

3. **Soumission de job** :
   ```bash
   sbatch mon-job.sh
   ```

---

## 📚 Documentation

### Pour les Administrateurs

- **Installation** : `docs/GUIDE_INSTALLATION_LDAP_KERBEROS.md`
- **Sécurité** : `docs/GUIDE_SECURITE.md`
- **Maintenance** : `docs/GUIDE_MAINTENANCE.md`
- **Troubleshooting** : `docs/GUIDE_TROUBLESHOOTING.md`
- **Architecture** : `docs/ARCHITECTURE.md`

### Pour les Utilisateurs

- **Guide Utilisateur** : `docs/GUIDE_UTILISATEUR.md`
- **Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS.md`
- **Exemples** : `examples/jobs/`

### Pour les Développeurs

- **Guide Développeur** : `docs/GUIDE_DEVELOPPEUR.md`

---

## 🛠️ Scripts Disponibles

### Installation
- `scripts/install-ldap-kerberos.sh` - Installation LDAP + Kerberos
- `scripts/install-freeipa.sh` - Installation FreeIPA

### Sécurité
- `scripts/security/hardening.sh` - Hardening complet

### Backup/Restore
- `scripts/backup/backup-cluster.sh` - Backup complet
- `scripts/backup/restore-cluster.sh` - Restauration

### Tests
- `scripts/tests/test-cluster-health.sh` - Tests santé
- `scripts/tests/test-ldap-kerberos.sh` - Tests auth
- `scripts/tests/test-slurm.sh` - Tests Slurm

### Troubleshooting
- `scripts/troubleshooting/diagnose-cluster.sh` - Diagnostic
- `scripts/troubleshooting/collect-logs.sh` - Collection logs

### Performance
- `scripts/performance/benchmark-cluster.sh` - Benchmark

### Maintenance
- `scripts/maintenance/update-cluster.sh` - Mise à jour

### Disaster Recovery
- `scripts/disaster-recovery/disaster-recovery.sh` - Récupération

### Conformité
- `scripts/compliance/validate-compliance.sh` - Validation conformité

---

## 📊 Structure du Projet

```
cluster hpc/
├── docs/              # Documentation complète
├── scripts/           # Scripts automatisés
├── examples/          # Exemples de jobs
├── monitoring/        # Configuration monitoring
├── grafana-dashboards/ # Dashboards Grafana
└── README_COMPLET.md  # Ce fichier
```

---

## 🔗 Liens Utiles

- **Guide Démarrage Rapide** : `GUIDE_DEMARRAGE_RAPIDE.md`
- **Résumé Installation** : `RESUME_INSTALLATION.md`
- **Versions** : `README_VERSIONS.md`
- **Améliorations** : `AMELIORATIONS_COMPLETE.md`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
