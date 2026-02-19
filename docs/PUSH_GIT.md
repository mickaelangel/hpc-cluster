# Push Git de manière cohérente

Procédure recommandée pour garder un historique propre et éviter les conflits avec `origin`.

---

## 1. Vérifier l’état

```powershell
cd "C:\Users\mickaelangel\Documents\hpc docker\hpc docker\cluster hpc"
git status
```

- **Modified** : fichiers déjà suivis, modifiés.
- **Untracked** : nouveaux fichiers/dossiers à ajouter si vous voulez les versionner.

---

## 2. Récupérer les changements distants (éviter les conflits)

Toujours **pull** avant de **push** si d’autres (ou vous sur un autre PC) poussent sur la même branche :

```powershell
git pull origin main
```

En cas de conflit, Git vous le dira ; résolvez les conflits puis :

```powershell
git add .
git commit -m "Merge remote (résolution conflits)"
```

---

## 3. Ajouter les fichiers à commiter

**Tout ajouter :**

```powershell
git add -A
```

**Ou seulement certains dossiers :**

```powershell
git add .github/wiki/
git add src/
git add ansible/playbooks/hpc_compute_nodes.yml
git add docs/
```

*(Les fichiers `*.key` sont ignorés via `.gitignore`, donc `munge.key` ne sera pas ajouté.)*

---

## 4. Vérifier ce qui sera commité

```powershell
git status
```

---

## 5. Commiter avec un message clair

```powershell
git commit -m "Wiki HPC : manuel 8 volumes, dictionnaire, annexes SRE, glossaire, IaC (slurm/gres/Apptainer)"
```

Adapter le message à ce que vous avez réellement modifié (ex. « Doc : complétion glossaire et index »).

---

## 6. Push vers GitHub

```powershell
git push origin main
```

Si c’est la première fois sur cette branche :

```powershell
git push -u origin main
```

---

## En une seule séquence (copier-coller)

À exécuter **à la racine du dépôt** (après `cd` vers le projet) :

```powershell
git pull origin main
git add -A
git status
git commit -m "Votre message de commit descriptif"
git push origin main
```

---

## En cas d’échec du push (credentials)

- **HTTPS** : GitHub n’accepte plus les mots de passe ; utilisez un **Personal Access Token (PAT)** à la place du mot de passe.
- **SSH** : vérifiez que votre clé SSH est ajoutée à l’agent et enregistrée sur GitHub (Settings → SSH and GPG keys).

Création d’un PAT : GitHub → Settings → Developer settings → Personal access tokens → Generate new token (cochez au minimum `repo`).

---

## Résumé

| Étape | Commande |
|--------|----------|
| 1. Se placer dans le dépôt | `cd "chemin\vers\cluster hpc"` |
| 2. Récupérer le distant | `git pull origin main` |
| 3. Ajouter les changements | `git add -A` (ou chemins ciblés) |
| 4. Commiter | `git commit -m "Message clair"` |
| 5. Envoyer | `git push origin main` |
