# Chapitre 11 — Planification des tâches (cron, at)

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Comprendre la planification périodique (cron) et différée (at).
- Éditer la crontab utilisateur et système ; comprendre la syntaxe des champs (min, heure, jour, mois, jour de la semaine).
- Utiliser `at` pour une exécution unique à une date/heure donnée.
- Identifier les bonnes pratiques (redirections, logs, environnement, chemins absolus).
- Éviter les pièges (variable d’environnement, répertoire de travail).

---

## Prérequis

- Chapitres 1–3 (CLI, fichiers, processus).
- Notion de chemin absolu et de répertoire de travail.

---

## Plan détaillé

1. **Cron** — rôle du démon cron, crontab utilisateur vs système.
2. **Syntaxe crontab** — les cinq champs (minute, heure, jour du mois, mois, jour de la semaine) ; exemples.
3. **Édition et liste** — `crontab -e`, `crontab -l`, fichiers sous `/etc/cron.d/` (présentation générique).
4. **At** — file d’attente, `at`, `atq`, `atrm` ; exemples d’exécution différée.
5. **Environnement et chemins** — PATH, répertoire courant ; bonnes pratiques (scripts avec chemin absolu, redirection stdout/stderr).
6. **Erreurs fréquentes** — oublier le PATH, cron sans redirection, permissions.
7. **Validation** — créer une crontab de test (echo à une minute donnée), vérifier l’exécution.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — man crontab, man at.

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–4 (cron et at) — 8–12 pp.
- [ ] **TODO** : Rédiger sections 5–6 (bonnes pratiques, erreurs) — 2–3 pp.
- [ ] **TODO** : Rédiger validation et exercices ; corrigés dans `solutions/`.

---

## Exercices

**Facile** : Afficher sa crontab ; ajouter une entrée qui écrit la date dans un fichier log une fois.

**Moyen** : Planifier un script de sauvegarde (simulation : copie d’un répertoire) tous les jours à 2 h ; documenter les redirections.

**Challenge** : Comparer cron et at pour un job one-shot ; quand utiliser l’un ou l’autre ; pièges d’environnement (documenter sans exécuter de commande destructive).

---

## Validation

```bash
crontab -l
# Vérifier que le service cron tourne (distribution-dépendant) :
# systemctl status cron  ou  systemctl status crond
atq
```

---

## Références

- `man crontab`, `man at`, `man 5 crontab`
- Documentation distribution (cron, at) — pas de copier-coller.
