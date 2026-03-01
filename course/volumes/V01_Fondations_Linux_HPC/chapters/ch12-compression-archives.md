# Chapitre 12 — Compression et archives

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Distinguer archive (tar) et compression (gzip, xz, bzip2).
- Créer et extraire des archives (tar, options c, x, t, v, f).
- Combiner tar et compression (tgz, tar.xz).
- Utiliser zip/unzip pour échange inter-plateformes.
- Bonnes pratiques (exclusions, chemins relatifs, vérification intégrité).

---

## Prérequis

- Chapitres 1–2 (fichiers, chemins, permissions).

---

## Plan détaillé

1. **Archive vs compression** — rôle de tar (fichiers réunis) ; rôle de gzip/xz/bzip2 (réduction taille).
2. **tar** — créer (c), extraire (x), lister (t) ; options v, f, chemins.
3. **Compression** — gzip, xz, bzip2 ; niveaux, débit vs ratio.
4. **tar + compression** — tar.gz, tar.xz ; options -z, -J, -j.
5. **zip / unzip** — format ZIP ; usage basique.
6. **Erreurs fréquentes** — écraser sans vérifier, chemins absolus qui « explosent », oublier les exclusions.
7. **Validation** — créer une archive, lister, extraire, comparer.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — man tar, man gzip, man xz.

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–5 — 10–15 pp.
- [ ] **TODO** : Rédiger erreurs fréquentes, validation, exercices, à retenir, références.

---

## Exercices

**Facile** : Créer une archive tar.gz d’un répertoire ; lister son contenu ; l’extraire ailleurs.

**Moyen** : Créer une archive en excluant certains motifs (ex. *.log) ; documenter les options.

**Challenge** : Comparer tailles et temps pour tar.gz vs tar.xz sur un même répertoire ; interpréter (ratio vs vitesse).

---

## Validation

```bash
tar -czvf /tmp/test.tar.gz /chemin/source
tar -tzvf /tmp/test.tar.gz
mkdir /tmp/extract && tar -xzvf /tmp/test.tar.gz -C /tmp/extract
```

---

## Références

- `man tar`, `man gzip`, `man xz`, `man zip`
- Documentation distribution — pas de contenu spécifique au dépôt inventé.
