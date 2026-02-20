# Retirer @cursoragent des Contributors GitHub

Deux approches possibles. **Important** : réécrire l’historique impacte tous les clones et les PR ouvertes ; les collaborateurs devront recloner ou réparer leur historique.

---

## Avant : trouver les commits concernés

Dans **Git Bash** (ou terminal), depuis la racine du dépôt :

```bash
# Mettre à jour les refs distantes (pour voir les commits déjà sur GitHub)
git fetch origin

# Chercher les commits attribués à cursor / cursoragent
git log --all --oneline --author=cursor
git log --all --oneline --author=cursoragent
git log --all --format="%h %an <%ae>" | grep -i cursor
```

- Si **peu de commits** (quelques-uns) → **Option 1** (rebase).
- Si **beaucoup de commits** ou rebase trop compliqué → **Option 2** (réécriture d’auteur).

---

## Option 1 (simple) : rebase interactif — squash ou drop

À utiliser si seulement quelques commits sont à cursoragent.

1. **Repérer le hash du commit juste avant** les commits cursoragent (par ex. `a520a6f`).

2. **Lancer un rebase interactif** :
   ```bash
   git rebase -i a520a6f
   ```
   (remplacer `a520a6f` par le hash réel.)

3. Dans l’éditeur :
   - pour **fusionner** un commit cursoragent dans le vôtre : remplacer `pick` par `squash` (ou `s`) sur la ligne du commit ;
   - pour **supprimer** un commit cursoragent : remplacer `pick` par `drop` (ou `d`).

4. Sauvegarder et fermer. Si vous avez squashed, Git ouvrira un éditeur pour le message du commit fusionné.

5. **Pousser** (écrase l’historique distant) :
   ```bash
   git push --force-with-lease origin main
   ```
   `--force-with-lease` est plus sûr que `--force` (refuse si quelqu’un a poussé entre-temps).

---

## Option 2 (propre) : réécrire l’auteur pour tous les commits

Recommandé si beaucoup de commits sont à cursoragent. Deux outils possibles.

### A. Avec `git filter-repo` (recommandé)

1. **Installer** : https://github.com/newren/git-filter-repo (Python 3 requis).
   ```bash
   pip install git-filter-repo
   ```

2. **Réécrire l’auteur** (depuis la racine du dépôt).  
   Avec **mailmap** (si vous connaissez l’email de cursoragent, par ex. sur la page Contributors) : créer un fichier `authors-mailmap` :
   ```
   Mickael Angel <mickaelangelcv@gmail.com> cursoragent <email-cursoragent@...>
   Mickael Angel <mickaelangelcv@gmail.com> Cursor Agent <email-cursoragent@...>
   ```
   Puis :
   ```bash
   git filter-repo --mailmap authors-mailmap --force
   ```
   Pour une réécriture conditionnelle (uniquement si le nom contient « cursor »), voir la doc officielle : [git filter-repo — commit callbacks](https://github.com/newren/git-filter-repo).

3. **Pousser** :
   ```bash
   git push --force --all origin
   git push --force --tags origin
   ```

### B. Avec le script `filter-branch` (déjà dans ce dépôt)

Si vous n’installez pas `git filter-repo` :

1. **Arbre propre** (pas de modifications non commitées) :
   ```bash
   git stash push -m "avant remove-cursoragent"   # si vous avez des changements
   ```

2. **Lancer le script** :
   ```bash
   sh .github/scripts/remove-cursoragent-from-history.sh
   ```

3. **Pousser** :
   ```bash
   git push --force origin main
   ```

4. **Récupérer le stash** si besoin :
   ```bash
   git stash pop
   ```

---

## Après la réécriture

- Vérifier les auteurs : `git log --format="%an <%ae>" | sort -u`
- La page **Contributors** sur GitHub se met à jour après quelques minutes.
- **Prévenir** toute personne qui clone ou a déjà cloné le dépôt : elles devront **recloner** ou faire un `git fetch origin && git reset --hard origin/main` sur leur branche.

---

## Éviter que cursoragent réapparaisse

Déjà en place dans ce dépôt :

- **Identité Git** : `user.name` et `user.email` sont définis localement (Mickael Angel).
- **Règle Cursor** : `.cursor/rules/git-identity.mdc` — ne jamais utiliser cursoragent / Cursor Agent comme auteur.

Optionnel : bloquer le compte **@cursoragent** sur GitHub (profil → Block user) pour qu’il ne soit plus notifié.
