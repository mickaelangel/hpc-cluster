# Guide Rapide : Activer le Wiki GitHub

## Étapes pour Activer le Wiki

1. **Aller sur le dépôt GitHub** :
   - Ouvrir : https://github.com/mickaelangel/hpc-cluster

2. **Accéder aux Paramètres** :
   - Cliquer sur l'onglet **"Settings"** (en haut du dépôt)

3. **Activer le Wiki** :
   - Dans le menu de gauche, cliquer sur **"Features"**
   - Trouver la section **"Wikis"**
   - **Cocher la case** pour activer les Wikis
   - Cliquer sur **"Save"** pour sauvegarder

4. **Vérifier** :
   - Un nouvel onglet **"Wiki"** devrait apparaître dans le menu du dépôt

## Après Activation

Une fois le Wiki activé, exécutez le script pour pousser le contenu :

```powershell
cd "C:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
powershell -ExecutionPolicy Bypass -File ".\scripts\upload-wiki.ps1"
```

## Pages Wiki Prêtes

Les pages suivantes sont prêtes dans `.github/wiki/` :

- **Home.md** - Page d'accueil du Wiki
- **Installation-Rapide.md** - Guide d'installation rapide
- **Configuration-de-Base.md** - Configuration minimale
- **FAQ.md** - Questions fréquentes
- **Depannage.md** - Guide de dépannage
- **Astuces.md** - Astuces et optimisations
- **Commandes-Utiles.md** - Référence rapide des commandes
- **Monitoring.md** - Guide du monitoring
- **README.md** - Guide d'utilisation du Wiki

---

**Note** : Le Wiki GitHub est un dépôt Git séparé accessible via `https://github.com/mickaelangel/hpc-cluster.wiki.git`
