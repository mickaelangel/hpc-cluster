# Chapitre 18 — Synthèse et bonnes pratiques admin

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Synthétiser les compétences des chapitres 1–17 (CLI, fichiers, processus, paquets, services, réseau, utilisateurs, planification, archives, recherche, redirections, conteneurs, labs).
- Énoncer les bonnes pratiques d’administration Linux (sécurité, logs, sauvegardes, documentation).
- Préparer la transition vers les volumes suivants (réseau avancé, Slurm, monitoring) ou vers un environnement cluster réel.
- Ne pas inventer de pratiques spécifiques au dépôt non documentées ailleurs (SOURCE_INDEX, docs existantes).

---

## Prérequis

- Chapitres 1–17.

---

## Plan détaillé

1. **Récapitulatif par thème** — fichiers et permissions ; processus et services ; réseau ; utilisateurs et groupes ; planification ; outils (find, grep, tar, pipes) ; conteneurs (notions).
2. **Bonnes pratiques sécurité** — moindre privilège ; pas de root en prod pour SSH interactif ; clés SSH ; mise à jour des paquets ; firewall.
3. **Bonnes pratiques opérationnelles** — logs (journalctl, fichiers log) ; sauvegardes (stratégie, pas de détail sensible) ; documentation des changements.
4. **Checklist « avant de toucher à la prod »** — sauvegarde, test en staging, rollback possible, communication.
5. **Erreurs fréquentes** — modifier sans backup ; oublier les dépendances entre services ; documenter des secrets.
6. **Validation** — auto-évaluation (QCM ou checklist) sur les chapitres 1–17.
7. **Exercices** — facile / moyen / challenge (synthèse).
8. **À retenir** — 10–15 points clés du volume.
9. **Références** — STYLE_GUIDE, CIBLE_400_800_PAGES ; docs du dépôt (liens existants uniquement).

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–4 — 10–15 pp.
- [ ] **TODO** : Rédiger sections 5–9 ; pas d’invention sur le dépôt.

---

## Exercices

**Facile** : Énumérer 5 bonnes pratiques vues dans le volume.

**Moyen** : Rédiger une checklist « mise en production d’un changement » en 8 points (générique).

**Challenge** : Proposer un plan de formation pour un nouvel admin (ordre des chapitres, labs prioritaires) ; justifier en 1 page.

---

## Validation

- Compléter une checklist de synthèse (à créer) couvrant chapitres 1–17.
- Aucune commande sensible ; références documentaires uniquement.

---

## Références

- [STYLE_GUIDE](../../../editorial/STYLE_GUIDE.md), [CIBLE_400_800_PAGES.md](../../../editorial/CIBLE_400_800_PAGES.md)
- [SOURCE_INDEX](../../../editorial/SOURCE_INDEX.md) — pour toute référence au projet (pas d’invention).
