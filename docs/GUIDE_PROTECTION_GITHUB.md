# Guide de Protection du Dépôt GitHub
## Configuration pour Restreindre les Modifications

**Objectif** : Protéger le dépôt pour que seul le propriétaire puisse modifier, supprimer ou uploader des fichiers.

---

## 🔒 Protection de la Branche Principale

### Méthode 1 : Via l'Interface Web GitHub (Recommandé)

#### Étape 1 : Accéder aux Paramètres de Protection

1. Aller sur https://github.com/mickaelangel/hpc-cluster
2. Cliquer sur **Settings** (Paramètres)
3. Dans le menu de gauche, cliquer sur **Branches**
4. Cliquer sur **Add rule** (Ajouter une règle) ou modifier la règle existante pour `main`

#### Étape 2 : Configurer la Protection

**Nom de la branche** : `main`

**Options à activer** :

✅ **Require a pull request before merging**
   - Require approvals: `1` (vous seul)
   - Dismiss stale pull request approvals when new commits are pushed: ✅
   - Require review from Code Owners: ✅ (si vous avez un fichier CODEOWNERS)

✅ **Require status checks to pass before merging**
   - Require branches to be up to date before merging: ✅
   - Status checks (si vous avez CI/CD) : Sélectionner les checks requis

✅ **Require conversation resolution before merging**
   - ✅ Require all conversations on code to be resolved

✅ **Require signed commits**
   - ✅ Require signed commits (optionnel mais recommandé)

✅ **Require linear history**
   - ✅ Require linear history (empêche les merges, force les rebases)

✅ **Include administrators**
   - ✅ **IMPORTANT** : Cocher cette case pour que même vous soyez soumis aux règles

✅ **Restrict who can push to matching branches**
   - Sélectionner : **Restrict pushes that create files**
   - Sélectionner : **Restrict pushes that create files or update refs**
   - **Allow specified actors to bypass required pull requests** : Ne cocher **PAS** cette case

✅ **Allow force pushes**
   - ❌ **DÉCOCHER** : Ne pas autoriser les force pushes

✅ **Allow deletions**
   - ❌ **DÉCOCHER** : Ne pas autoriser la suppression de la branche

#### Étape 3 : Sauvegarder

Cliquer sur **Create** ou **Save changes**

---

### Méthode 2 : Via GitHub CLI (gh)

#### Installation GitHub CLI

```bash
# Windows (via winget)
winget install GitHub.cli

# Ou via Chocolatey
choco install gh
```

#### Authentification

```bash
gh auth login
```

#### Configuration de la Protection

```bash
# Activer la protection de branche
gh api repos/mickaelangel/hpc-cluster/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":["mickaelangel"],"teams":[]}' \
  --field allow_force_pushes=false \
  --field allow_deletions=false \
  --field required_linear_history=true \
  --field allow_squash_merge=false \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=true
```

---

### Méthode 3 : Via l'API GitHub (curl)

#### Token d'Accès Personnel

1. Aller sur https://github.com/settings/tokens
2. Cliquer sur **Generate new token (classic)**
3. Sélectionner les scopes :
   - ✅ `repo` (accès complet aux dépôts)
   - ✅ `admin:repo_hook` (gestion des hooks)
4. Générer et copier le token

#### Configuration via API

```bash
# Définir votre token
export GITHUB_TOKEN="votre_token_ici"

# Protéger la branche main
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/mickaelangel/hpc-cluster/branches/main/protection \
  -d '{
    "required_status_checks": {
      "strict": true,
      "contexts": []
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": true
    },
    "restrictions": {
      "users": ["mickaelangel"],
      "teams": []
    },
    "allow_force_pushes": false,
    "allow_deletions": false,
    "required_linear_history": true,
    "allow_squash_merge": false,
    "allow_merge_commit": false,
    "allow_rebase_merge": true
  }'
```

---

## 🛡️ Protection Supplémentaire

### 1. Fichier CODEOWNERS

Créer un fichier `.github/CODEOWNERS` :

```
# Propriétaire par défaut
* @mickaelangel
```

**Effet** : Tous les fichiers nécessitent votre approbation pour être modifiés.

### 2. Désactiver les Forks

1. Aller dans **Settings** > **General**
2. Section **Features**
3. ❌ Décocher **Allow forking**

### 3. Désactiver les Issues et Pull Requests (Optionnel)

Si vous ne voulez pas que d'autres créent des issues ou PRs :

1. Aller dans **Settings** > **General**
2. Section **Features**
3. ❌ Décocher **Issues**
4. ❌ Décocher **Pull requests**

### 4. Restreindre les Collaborateurs

1. Aller dans **Settings** > **Collaborators & teams**
2. Vérifier qu'aucun collaborateur n'est ajouté
3. Si des collaborateurs existent, les supprimer

### 5. Protection des Tags

1. Aller dans **Settings** > **Tags**
2. Cliquer sur **Add rule**
3. Pattern : `*` (tous les tags)
4. ✅ Cocher **Restrict who can create tags**
5. Sélectionner uniquement votre compte

---

## 🔐 Configuration Recommandée Complète

### Checklist de Protection

- [ ] Protection de branche `main` activée
- [ ] `Include administrators` coché (vous êtes soumis aux règles)
- [ ] Force pushes désactivés
- [ ] Suppression de branche désactivée
- [ ] Pull requests requis avant merge
- [ ] Approbation requise (1 minimum)
- [ ] Restrictions de push activées
- [ ] Fichier CODEOWNERS créé
- [ ] Forks désactivés (optionnel)
- [ ] Protection des tags activée

---

## 📝 Fichier CODEOWNERS

Créer `.github/CODEOWNERS` :

```
# ============================================================================
# CODEOWNERS - Propriétaires du Code
# ============================================================================
# Tous les fichiers nécessitent l'approbation du propriétaire
# ============================================================================

# Propriétaire par défaut pour tous les fichiers
* @mickaelangel

# Exceptions spécifiques (si nécessaire)
# docs/ @mickaelangel
# scripts/ @mickaelangel
```

---

## 🚨 Important : Vous Êtes le Seul à Pouvoir Modifier

### Avec cette Configuration

✅ **Vous pouvez** :
- Créer des branches
- Faire des commits sur vos branches
- Créer des pull requests
- Approuver vos propres pull requests (si `Include administrators` n'est pas coché)
- Merge vos pull requests

❌ **Les autres ne peuvent pas** :
- Push directement sur `main`
- Faire des force pushes
- Supprimer la branche
- Merge sans votre approbation

### Note Importante

Si vous cochez **"Include administrators"**, même vous devrez :
- Créer une branche
- Faire un pull request
- L'approuver vous-même
- Le merger

**Recommandation** : Ne pas cocher "Include administrators" si vous voulez pouvoir push directement sur `main` tout en protégeant contre les autres.

---

## 🔄 Workflow Recommandé

### Pour Vous (Propriétaire)

```bash
# Option 1 : Push direct (si "Include administrators" non coché)
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin main

# Option 2 : Via Pull Request (si "Include administrators" coché)
git checkout -b feature/nouvelle-fonctionnalite
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite
# Créer PR sur GitHub, l'approuver, merger
```

---

## ✅ Vérification

### Vérifier la Protection

```bash
# Via GitHub CLI
gh api repos/mickaelangel/hpc-cluster/branches/main/protection

# Via curl
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/mickaelangel/hpc-cluster/branches/main/protection
```

---

## 🆘 Dépannage

### Problème : Je ne peux plus push

**Solution** :
1. Vérifier que vous êtes bien authentifié
2. Si "Include administrators" est coché, créer une branche et un PR
3. Ou désactiver temporairement la protection

### Problème : Protection trop restrictive

**Solution** :
1. Aller dans Settings > Branches
2. Modifier la règle de protection
3. Ajuster les paramètres selon vos besoins

---

**Documentation maintenue par** : Équipe DevOps HPC  
**Dernière mise à jour** : 2024-02-15
