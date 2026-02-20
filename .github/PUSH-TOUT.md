# Comment tout bien push vers GitHub

## 1. Ouvrir un terminal

- **Git Bash** (recommandé) ou **PowerShell**
- Se placer à la racine du projet :

```bash
cd "c:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
```

## 2. Vérifier l’état

```bash
git status
```

Vous verrez les fichiers modifiés ou non suivis.

## 3. Ajouter les fichiers à committer

**Tout ajouter (modifications + nouveaux fichiers) :**
```bash
git add -A
```

**Ou seulement certains dossiers :**
```bash
git add README.md .github/
```

## 4. Committer

```bash
git commit -m "docs: README, wiki, cours, script push"
```

(Adaptez le message si besoin.)

## 5. Pousser vers GitHub

```bash
git push -u origin main
```

- Si une fenêtre de connexion s’ouvre (Git Credential Manager), connectez-vous à GitHub.
- Si on vous demande un **mot de passe** : utilisez un **Personal Access Token** (pas votre mot de passe GitHub) :  
  https://github.com/settings/tokens → Generate new token (classic) → cocher `repo` → copier le token et le coller quand Git demande le mot de passe.

## 6. En cas d’erreur

- **"Everything up-to-date"** : rien de nouveau à pousser (déjà à jour).
- **"Permission denied" / "Authentication failed"** : vérifier le token ou lancer `git config --global credential.helper manager` puis refaire `git push`.
- **"Updates were rejected"** : quelqu’un a poussé avant vous ; faire d’abord `git pull origin main` puis `git push origin main`.

## Récap en 4 commandes

```bash
cd "c:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
git add -A
git commit -m "docs: mise à jour README et wiki"
git push -u origin main
```
