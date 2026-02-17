# Guide Archivage Long Terme - Cluster HPC
## Archivage Données Long Terme

**Classification**: Documentation Archivage  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Stratégie Archivage](#stratégie-archivage)
2. [Tape Storage](#tape-storage)
3. [Cloud Storage](#cloud-storage)

---

## 💾 Stratégie Archivage

### Politique Archivage

- **Données actives**: < 1 an sur cluster
- **Données archivées**: 1-5 ans sur tape/cloud
- **Données long terme**: > 5 ans sur cloud/tape

---

## ☁️ Cloud Storage

### Archivage Cloud

```bash
# Exporter vers S3
aws s3 cp /data/project s3://archive-bucket/project --recursive
```

---

**Version**: 1.0
