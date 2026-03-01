# Chapitre 3 — systemd et unités

**Cible** : 20–35 pp (~6k–14k mots). [CIBLE_400_800_PAGES](../../../editorial/CIBLE_400_800_PAGES.md).

## Objectifs
- Comprendre les unités (service, socket, target). (3–6 puces à compléter.)
## Prérequis
- Ch. 1–2.
## Plan détaillé
1. Types d’unités. 2. Fichiers .service, .target. 3. Exemples. 4. Erreurs fréquentes. 5. Validation. 6. Exercices. 7. À retenir. 8. Références.
## À écrire
- [ ] TODO : Rédiger 20–35 pp. Pas de secret ; pas d’invention dépôt.
## Exercices
**Facile** : À rédiger. **Moyen** : À rédiger. **Challenge** : À rédiger.
## Validation
```bash
systemctl list-unit-files --type=service | head
```
## Références
- man systemd.unit ; docs officielles.
