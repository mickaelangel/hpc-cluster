# Guide Gestion Dépendances - Cluster HPC
## Gestion des Dépendances Logiciels

**Classification**: Documentation Dépendances  
**Public**: Administrateurs / Développeurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Dépendances Spack](#dépendances-spack)
2. [Dépendances Python](#dépendances-python)
3. [Résolution Conflits](#résolution-conflits)

---

## 📦 Dépendances Spack

### Visualiser Dépendances

```bash
spack find -d gromacs
spack graph gromacs
```

---

## 🐍 Dépendances Python

### Gestion avec pip

```bash
pip freeze > requirements.txt
pip install -r requirements.txt
```

---

**Version**: 1.0
