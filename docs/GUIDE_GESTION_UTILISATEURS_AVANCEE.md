# Guide Gestion Utilisateurs Avancée - Cluster HPC
## Gestion Complète des Utilisateurs

**Classification**: Documentation Utilisateurs  
**Public**: Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [Création Masse Utilisateurs](#création-masse-utilisateurs)
2. [Gestion Groupes](#gestion-groupes)
3. [Permissions Avancées](#permissions-avancées)

---

## 👥 Création Masse Utilisateurs

### Script Automatisé

```bash
# Créer utilisateurs depuis fichier CSV
while IFS=, read -r user email; do
    ipa user-add "$user" --first="$user" --email="$email"
done < users.csv
```

---

## 🔐 Permissions Avancées

### ACL Fichiers

```bash
# Définir ACL pour groupe
setfacl -m g:research:rwx /data/research/
```

---

**Version**: 1.0
