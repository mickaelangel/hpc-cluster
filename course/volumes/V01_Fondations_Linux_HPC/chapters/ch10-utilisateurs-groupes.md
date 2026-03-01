# Chapitre 10 — Utilisateurs et groupes

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Comprendre le modèle utilisateurs/groupes sous Linux (UID, GID, primary/secondary group).
- Lire et interpréter `/etc/passwd`, `/etc/group`, `/etc/shadow`.
- Créer et modifier utilisateurs et groupes (`useradd`, `usermod`, `groupadd`, `passwd`).
- Gérer les permissions en lien avec les groupes (chown, chgrp).
- Appliquer les bonnes pratiques (pas de connexion root directe en prod, groupes dédiés).

---

## Prérequis

- Chapitres 1–2 (CLI, système de fichiers, permissions).
- Accès root ou sudo pour les commandes d’administration.

---

## Plan détaillé

1. **Modèle utilisateur et groupe** — UID, GID, utilisateur effectif, primary vs secondary group.
2. **Fichiers système** — `/etc/passwd`, `/etc/group`, `/etc/shadow` (champs, lecture).
3. **Création et modification** — `useradd`, `usermod`, `userdel` ; `groupadd`, `groupmod`, `groupdel` ; `passwd`, `chage`.
4. **Permissions et groupes** — `chown`, `chgrp` ; groupes secondaires, `newgrp`.
5. **Bonnes pratiques** — compte de service, groupes métier, pas de secret en clair dans la doc.
6. **Erreurs fréquentes** — oublier le groupe primaire, permissions sur home, lock compte.
7. **Validation** — commandes pour vérifier un utilisateur, lister les groupes.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — man useradd, man groupadd, man passwd.

---

## À écrire

- [ ] **TODO** : Rédiger section 1 (modèle utilisateur/groupe) — 2–3 pp.
- [ ] **TODO** : Rédiger section 2 (fichiers /etc) avec exemples de lignes — 2–3 pp.
- [ ] **TODO** : Rédiger section 3 (commandes) avec exemples génériques Linux — 4–6 pp.
- [ ] **TODO** : Rédiger section 4 (permissions et groupes) — 2–3 pp.
- [ ] **TODO** : Rédiger section 5 (bonnes pratiques) — 1–2 pp.
- [ ] **TODO** : Rédiger section 6 (erreurs fréquentes) — 1–2 pp.
- [ ] **TODO** : Compléter exercices et corrigés (dans `solutions/`).

---

## Exercices

**Facile** : Afficher les champs de son propre utilisateur dans `/etc/passwd` ; lister les groupes dont on fait partie.

**Moyen** : Créer un utilisateur avec home et groupe dédié ; modifier le groupe primaire d’un fichier.

**Challenge** : Configurer un groupe partagé pour un répertoire de projet (permissions, setgid) ; documenter la procédure sans aucun secret.

---

## Validation

```bash
id
getent passwd $USER
getent group $USER
groups
# Après création utilisateur de test (à supprimer) :
# useradd -m -s /bin/bash testuser && id testuser && userdel -r testuser
```

---

## Références

- `man useradd`, `man usermod`, `man groupadd`, `man passwd`, `man shadow`
- Documentation distribution (ex. openSUSE : https://doc.opensuse.org/) — gestion utilisateurs
- Aucune source spécifique au dépôt à inventer ; si référence au cluster, utiliser uniquement ce qui existe (SOURCE_INDEX).
