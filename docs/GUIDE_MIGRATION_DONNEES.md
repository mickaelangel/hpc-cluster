# Guide Migration Données - Cluster HPC
## Guide pour Migrer des Données

**Classification**: Documentation Migration  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Migration BeeGFS](#migration-beegfs)
2. [Migration Lustre](#migration-lustre)
3. [Migration Applications](#migration-applications)

---

## 💾 Migration BeeGFS

### rsync

```bash
rsync -avz /source/ /mnt/beegfs/destination/
```

---

## 📚 Documentation Complémentaire

- `GUIDE_BACKUP_RESTORE.md` - Backup/Restore

---

**Version**: 1.0
