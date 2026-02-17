# Guide GitHub - Publier le Cluster HPC sur GitHub

## 📋 Étapes pour publier le projet sur GitHub

### 1. Configuration Git (si pas encore fait)

Exécuter le script PowerShell :
```powershell
.\setup-github.ps1
```

Ou manuellement :
```powershell
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### 2. Créer un compte GitHub

Si vous n'avez pas encore de compte :
1. Aller sur https://github.com/signup
2. Créer un compte (gratuit)
3. Vérifier votre email

### 3. Créer un Personal Access Token (PAT)

GitHub nécessite un token pour l'authentification :

1. Aller sur : https://github.com/settings/tokens
2. Cliquer sur "Generate new token" → "Generate new token (classic)"
3. Donner un nom : `HPC Cluster Push`
4. Sélectionner les permissions :
   - ✅ `repo` (toutes les permissions repo)
5. Cliquer sur "Generate token"
6. **COPIER LE TOKEN** (il ne sera affiché qu'une fois !)

### 4. Créer le dépôt sur GitHub

1. Aller sur : https://github.com/new
2. Remplir :
   - **Repository name** : `hpc-cluster` (ou autre nom)
   - **Description** : `Cluster HPC complet - 2 frontaux + 6 nœuds + monitoring`
   - **Visibility** : Public ou Private (selon votre choix)
   - ⚠️ **NE PAS** cocher "Add a README file"
   - ⚠️ **NE PAS** cocher "Add .gitignore"
   - ⚠️ **NE PAS** cocher "Choose a license"
3. Cliquer sur "Create repository"

### 5. Connecter le dépôt local à GitHub

Dans PowerShell, depuis le dossier du projet :

```powershell
# Remplacer VOTRE_USERNAME par votre nom d'utilisateur GitHub
git remote add origin https://github.com/VOTRE_USERNAME/hpc-cluster.git

# Renommer la branche en main
git branch -M main

# Pousser le projet (GitHub demandera votre username et le token comme password)
git push -u origin main
```

**Lors de `git push`** :
- **Username** : votre nom d'utilisateur GitHub
- **Password** : le Personal Access Token (PAT) que vous avez créé

### 6. Vérification

Après le push, aller sur :
```
https://github.com/VOTRE_USERNAME/hpc-cluster
```

Vous devriez voir tous vos fichiers !

## 📝 Notes importantes

### Fichiers exclus (via .gitignore)

Les fichiers suivants ne seront **PAS** poussés sur GitHub (trop volumineux) :
- Images Docker (`*.tar.gz` dans `docker-images/`)
- RPM Docker (`*.rpm` dans `docker-offline-rpms/`)
- Exports (`export-demo/`)
- Volumes Docker
- Logs

### Si le push échoue

**Erreur d'authentification** :
- Vérifier que le PAT a les bonnes permissions
- Utiliser le PAT comme mot de passe (pas votre mot de passe GitHub)

**Fichiers trop volumineux** :
- GitHub limite à 100 MB par fichier
- Les images Docker sont exclues automatiquement via `.gitignore`

**Push trop lent** :
- Normal pour un projet de cette taille
- Patienter, le push peut prendre plusieurs minutes

## 🚀 Après la publication

Une fois sur GitHub, vous pouvez :

1. **Cloner le projet** :
   ```bash
   git clone https://github.com/VOTRE_USERNAME/hpc-cluster.git
   ```

2. **Partager le lien** avec d'autres personnes

3. **Créer des releases** pour les versions importantes

4. **Ajouter une description** dans le README du dépôt GitHub

## ✅ Résumé des commandes

```powershell
# 1. Configuration Git
.\setup-github.ps1

# 2. Créer le dépôt sur GitHub (via navigateur)
# https://github.com/new

# 3. Connecter et pousser
git remote add origin https://github.com/VOTRE_USERNAME/hpc-cluster.git
git branch -M main
git push -u origin main
```

---

**Bon push ! 🚀**
