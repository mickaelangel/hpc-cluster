# Mettre le wiki au bon endroit (onglet Wiki GitHub)

Le contenu est dans **`.github/wiki/`** (dossier du dépôt) mais pour qu’il s’affiche dans l’**onglet Wiki** de votre projet GitHub, il faut le pousser dans le dépôt wiki.

## 1. Activer le Wiki sur GitHub

1. Ouvrez **https://github.com/mickaelangel/hpc-cluster**
2. **Settings** → **General** → **Features**
3. Cochez **Wiki**
4. Enregistrez.

(Créer au moins une page vide dans l’onglet Wiki si le dépôt wiki n’existe pas encore.)

## 2. Lancer la synchronisation

Dans **PowerShell**, depuis la racine du projet `cluster hpc` :

```powershell
cd "c:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
.\.github\scripts\sync-wiki-to-github.ps1
```

Le script :

- clone `hpc-cluster.wiki` à côté du projet (si besoin),
- copie tous les `.md` de `.github/wiki/` dans ce wiki,
- fait un commit et un **push** vers le wiki GitHub.

## 3. Vérifier

Ouvrez : **https://github.com/mickaelangel/hpc-cluster/wiki**

Vous devriez y voir **Home**, les volumes du manuel, le cours, le glossaire, etc.

## En cas d’erreur de push

Comme pour le dépôt principal : identifiants GitHub (token). Vérifiez que vous avez bien fait :

```powershell
git config --global credential.helper manager
```

puis relancez le script.
