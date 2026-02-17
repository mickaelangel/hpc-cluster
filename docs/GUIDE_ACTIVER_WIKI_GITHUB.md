# 📚 Guide : Activer et Configurer le Wiki GitHub

> **Guide pour activer le Wiki GitHub et uploader la documentation**

---

## 🎯 Étape 1 : Activer le Wiki GitHub

### Via l'Interface Web

1. **Aller sur le repository** : https://github.com/mickaelangel/hpc-cluster
2. **Cliquer sur "Settings"** (en haut à droite)
3. **Dans le menu de gauche**, aller dans **"Features"**
4. **Cocher "Wikis"** pour activer le Wiki
5. **Sauvegarder** les changements

### Vérification

Une fois activé, vous verrez un onglet **"Wiki"** dans le menu du repository.

---

## 🚀 Étape 2 : Uploader les Pages Wiki

### Option 1 : Via Script Automatique (Recommandé)

Une fois le Wiki activé, exécutez :

```powershell
# Windows PowerShell
.\scripts\upload-wiki.ps1
```

```bash
# Linux/Mac
chmod +x scripts/upload-wiki.sh
./scripts/upload-wiki.sh
```

### Option 2 : Via Git (Manuel)

```bash
# Cloner le Wiki (créé automatiquement après activation)
git clone https://github.com/mickaelangel/hpc-cluster.wiki.git
cd hpc-cluster.wiki

# Copier les fichiers
cp ../.github/wiki/*.md .

# Commit et push
git add *.md
git commit -m "Add complete Wiki documentation"
git push origin master
```

### Option 3 : Via l'Interface Web

1. **Aller sur** : https://github.com/mickaelangel/hpc-cluster/wiki
2. **Cliquer sur "New Page"** pour chaque page
3. **Copier le contenu** depuis `.github/wiki/`
4. **Coller dans l'éditeur**
5. **Sauvegarder**

---

## 📋 Pages à Créer

Les fichiers suivants sont prêts dans `.github/wiki/` :

1. **Home.md** → Page d'accueil du Wiki
2. **Installation-Rapide.md** → Guide d'installation
3. **Configuration-de-Base.md** → Configuration minimale
4. **FAQ.md** → Questions fréquentes
5. **Depannage.md** → Guide de dépannage
6. **Astuces.md** → Astuces et optimisations
7. **Commandes-Utiles.md** → Référence rapide
8. **Monitoring.md** → Guide du monitoring
9. **README.md** → Guide d'utilisation du Wiki

---

## ✅ Vérification

Après l'upload, vérifiez que toutes les pages sont visibles sur :
https://github.com/mickaelangel/hpc-cluster/wiki

---

## 🔧 Dépannage

### Le Wiki n'apparaît pas

- Vérifier que le Wiki est bien activé dans Settings > Features
- Rafraîchir la page
- Vérifier les permissions du repository

### Erreur lors du push

- Vérifier que le Wiki est activé
- Vérifier les permissions Git
- Essayer de cloner d'abord : `git clone https://github.com/mickaelangel/hpc-cluster.wiki.git`

---

**Dernière mise à jour** : 2024
