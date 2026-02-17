# Guide Troubleshooting Stockage - Cluster HPC
## Diagnostic et Résolution Problèmes Stockage

**Classification**: Documentation Troubleshooting  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Diagnostic BeeGFS](#diagnostic-beegfs)
2. [Diagnostic Lustre](#diagnostic-lustre)
3. [Problèmes Performance](#problèmes-performance)

---

## 🔍 Diagnostic BeeGFS

### Vérification État

```bash
# État services
systemctl status beegfs-mgmtd beegfs-meta beegfs-storage

# Vérification montage
mountpoint -q /mnt/beegfs && echo "OK" || echo "FAIL"
```

---

## 💾 Diagnostic Lustre

### Vérification État

```bash
# État services
systemctl status lustre

# Vérification montage
mountpoint -q /mnt/lustre && echo "OK" || echo "FAIL"
```

---

**Version**: 1.0
