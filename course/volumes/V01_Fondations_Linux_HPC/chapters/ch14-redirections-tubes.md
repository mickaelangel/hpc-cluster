# Chapitre 14 — Redirections et tubes

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Comprendre les flux standard : stdin (0), stdout (1), stderr (2).
- Utiliser les redirections >, >>, <, 2>, 2>&1, &>.
- Enchaîner des commandes avec le pipe |.
- Appliquer les bonnes pratiques dans les scripts (erreurs, logs).
- Éviter les pièges (ordre 2>&1, écrasement avec >).

---

## Prérequis

- Chapitres 1–3 (CLI, fichiers, processus).

---

## Plan détaillé

1. **Flux standard** — stdin, stdout, stderr ; descripteurs 0, 1, 2.
2. **Redirection sortie** — > (écraser), >> (ajouter) ; 2>, 2>&1, &>.
3. **Redirection entrée** — < ; here-document (<<).
4. **Tube (pipe)** — | ; chaînes de commandes ; limites (stderr non pipé par défaut).
5. **Scripts** — rediriger stderr dans un log ; bonnes pratiques.
6. **Erreurs fréquentes** — 2>&1 après > vs avant ; ordre des redirections ; pipe et erreurs.
7. **Validation** — commandes de test (echo, ls, cat) avec redirections ; pipe avec grep.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — man bash (REDIRECTION), documentation shell.

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–5 — 10–15 pp.
- [ ] **TODO** : Rédiger erreurs, validation, exercices, à retenir, références.

---

## Exercices

**Facile** : Rediriger la sortie de `ls` dans un fichier ; rediriger stderr d’une commande (ex. `ls /nonexistent`) dans un fichier.

**Moyen** : Chaîner trois commandes avec des pipes ; capturer stdout et stderr dans deux fichiers distincts dans un script.

**Challenge** : Expliquer la différence entre `cmd > file 2>&1` et `cmd 2>&1 > file` ; documenter avec un exemple.

---

## Validation

```bash
ls -l > /tmp/out.txt ; cat /tmp/out.txt
ls /nonexistent 2> /tmp/err.txt ; cat /tmp/err.txt
echo "hello" | cat
```

---

## Références

- `man bash` (section REDIRECTION)
- Documentation shell (Bash) — pas de contenu spécifique au dépôt inventé.
