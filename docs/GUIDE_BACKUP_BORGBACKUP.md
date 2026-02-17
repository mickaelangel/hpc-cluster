# Guide Backup BorgBackup - Cluster HPC
## Backup Dédupliqué et Incrémental

**Classification**: Documentation Maintenance  
**Public**: Administrateurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation BorgBackup](#installation-borgbackup)
3. [Configuration](#configuration)
4. [Backup](#backup)
5. [Restauration](#restauration)
6. [Maintenance](#maintenance)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**BorgBackup** : Système de backup dédupliqué et incrémental qui compresse et chiffre les sauvegardes.

### Avantages

- ✅ **Déduplification** : Économise espace disque
- ✅ **Incrémental** : Sauvegarde uniquement changements
- ✅ **Chiffrement** : Données sécurisées
- ✅ **Compression** : Réduit taille backups

---

## 🚀 Installation BorgBackup

### Installation

```bash
./scripts/backup/backup-borg.sh
```

### Vérification

```bash
borg --version
```

---

## ⚙️ Configuration

### Initialisation Repository

```bash
# Créer repository
export BORG_PASSPHRASE="mot-de-passe-securise"
borg init --encryption=repokey /backup/borg-repo
```

### Configuration Variables

```bash
# Repository
export BORG_REPO="/backup/borg-repo"

# Passphrase
export BORG_PASSPHRASE="mot-de-passe-securise"
```

---

## 💾 Backup

### Backup Automatique

**Script** : `scripts/backup/backup-borg.sh`

```bash
# Exécuter backup
./scripts/backup/backup-borg.sh
```

### Backup Manuel

```bash
# Backup simple
borg create \
  --stats \
  --progress \
  "$BORG_REPO::cluster-$(date +%Y%m%d-%H%M%S)" \
  /etc \
  /mnt/beegfs/home \
  /opt

# Backup avec compression
borg create \
  --compression lz4 \
  "$BORG_REPO::cluster-$(date +%Y%m%d-%H%M%S)" \
  /path/to/backup
```

### Chemins Sauvegardés

**Par défaut** :
- `/etc` - Configuration système
- `/mnt/beegfs/home` - Home utilisateurs
- `/opt` - Applications
- `/var/lib/ldap` - LDAP
- `/var/kerberos/krb5kdc` - Kerberos

---

## 🔄 Restauration

### Restauration Complète

**Script** : `scripts/backup/restore-borg.sh`

```bash
# Restauration
./scripts/backup/restore-borg.sh
```

### Restauration Manuelle

```bash
# Lister backups
borg list "$BORG_REPO"

# Restaurer archive
borg extract "$BORG_REPO::cluster-20240101-120000"

# Restaurer fichier spécifique
borg extract "$BORG_REPO::cluster-20240101-120000" path/to/file
```

### Restauration Sélective

```bash
# Restaurer répertoire
borg extract \
  "$BORG_REPO::cluster-20240101-120000" \
  etc/slurm

# Restaurer avec filtres
borg extract \
  "$BORG_REPO::cluster-20240101-120000" \
  --include '*.conf'
```

---

## 🔧 Maintenance

### Nettoyage Anciens Backups

**Automatique** :
```bash
# Garder 7 backups quotidiens, 4 hebdomadaires, 12 mensuels
borg prune \
  --keep-daily=7 \
  --keep-weekly=4 \
  --keep-monthly=12 \
  "$BORG_REPO"
```

**Manuel** :
```bash
# Supprimer archive spécifique
borg delete "$BORG_REPO::cluster-20240101-120000"
```

### Vérification Intégrité

```bash
# Vérifier repository
borg check "$BORG_REPO"

# Vérifier archive
borg check "$BORG_REPO::cluster-20240101-120000"
```

### Statistiques

```bash
# Statistiques repository
borg info "$BORG_REPO"

# Statistiques archive
borg info "$BORG_REPO::cluster-20240101-120000"
```

---

## 📊 Utilisation

### Lister Backups

```bash
# Liste complète
borg list "$BORG_REPO"

# Liste détaillée
borg list "$BORG_REPO" --verbose

# Liste avec dates
borg list "$BORG_REPO" --format "{archive} {time} {size}"
```

### Montage Archive

```bash
# Monter archive en lecture seule
borg mount "$BORG_REPO::cluster-20240101-120000" /mnt/backup

# Démonter
borg umount /mnt/backup
```

### Recherche

```bash
# Rechercher fichier
borg find "$BORG_REPO" --name "slurm.conf"

# Rechercher avec pattern
borg find "$BORG_REPO" --pattern "*.conf"
```

---

## 🔧 Dépannage

### Problèmes Courants

**Repository corrompu** :
```bash
# Réparer repository
borg check --repair "$BORG_REPO"
```

**Passphrase oubliée** :
```bash
# Impossible de récupérer sans passphrase
# Toujours sauvegarder la passphrase !
```

**Espace disque insuffisant** :
```bash
# Nettoyer anciens backups
borg prune --keep-daily=3 "$BORG_REPO"
```

**Backup lent** :
```bash
# Utiliser compression plus rapide
borg create --compression lz4 "$BORG_REPO::archive" /path
```

---

## 📚 Documentation Complémentaire

- `GUIDE_MAINTENANCE_COMPLETE.md` - Maintenance complète
- `GUIDE_DISASTER_RECOVERY.md` - Disaster recovery
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
