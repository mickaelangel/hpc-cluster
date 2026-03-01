# Chapitre 13 — Recherche et filtres (find, grep, xargs)

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Rechercher des fichiers par nom, type, date, taille avec `find`.
- Filtrer le contenu des fichiers avec `grep` (options -r, -i, -n, -E).
- Enchaîner find et commandes avec `xargs` (sécurité des espaces, -0).
- Comprendre les expressions régulières de base (grep -E).
- Bonnes pratiques (limiter la portée, éviter les injections de chemins).

---

## Prérequis

- Chapitres 1–2 (fichiers, chemins, permissions).

---

## Plan détaillé

1. **find** — syntaxe de base ; -name, -type, -mtime, -size ; -exec et -ok.
2. **grep** — recherche dans fichiers ; options -r, -i, -n, -l, -c ; sortie.
3. **Regex basiques** — . * [ ] ^ $ ; grep -E.
4. **xargs** — passer la sortie d’une commande en arguments ; find | xargs ; -0 et find -print0.
5. **Combinaisons** — find + grep ; find + xargs cmd.
6. **Erreurs fréquentes** — chemins avec espaces sans -print0/-0 ; regex trop large ; recherche depuis / sans prudence.
7. **Validation** — find des fichiers modifiés récemment ; grep dans un arbre ; pipeline find | xargs.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — man find, man grep, man xargs.

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–5 — 10–15 pp.
- [ ] **TODO** : Rédiger erreurs, validation, exercices, à retenir, références.

---

## Exercices

**Facile** : Trouver tous les fichiers .conf dans /etc ; compter les lignes contenant « root » dans /etc/passwd.

**Moyen** : Lister les fichiers .md modifiés dans les 7 derniers jours sous un répertoire ; utiliser find + xargs pour afficher leur première ligne.

**Challenge** : Construire une commande find + xargs sûre pour des noms avec espaces ; expliquer -print0 et xargs -0.

---

## Validation

```bash
find /etc -name "*.conf" -type f 2>/dev/null | head -5
grep -r "nobody" /etc/passwd
find . -name "*.md" -mtime -7 -print0 | xargs -0 -I {} head -1 {}
```

---

## Références

- `man find`, `man grep`, `man xargs`
- Documentation distribution — pas d’invention sur le dépôt.
