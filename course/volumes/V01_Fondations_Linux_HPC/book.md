# Volume 01 — Fondations Linux pour HPC

**Niveau** : Licence  
**Prérequis** : Aucun  
**Objectif** : Maîtriser les bases de Linux (CLI, système de fichiers, processus, paquets, services) nécessaires pour utiliser et administrer un cluster HPC.

---

> **Cible 400–800 pages**  
> Ce volume vise **400 à 800 pages** (1 page ≈ 300–400 mots). Convention, gabarits chapitre/lab et checklist qualité : [CIBLE_400_800_PAGES.md](../../editorial/CIBLE_400_800_PAGES.md).  
> **État actuel** : ch. 1–9 rédigés (version courte à étendre) ; ch. 10–20 en squelette à rédiger (cible 20–35 pp/chapitre, labs 10–30 pp).

---

## Comment utiliser ce livre

- **Ordre recommandé** : Chapitres 1 à 20 dans l’ordre ; les labs peuvent être faits après les chapitres indiqués.
- **Exercices** : À faire après chaque chapitre ; les corrigés sont dans `solutions/`.
- **Conventions** : Voir `course/editorial/STYLE_GUIDE.md`. Noms de nœuds du projet : `frontal-01`, `compute-01` … `compute-06`.

---

## Table des matières (cible 400–800 pp)

### Rédigés (version courte, à étendre)

1. [Chapitre 1 — Introduction au système Linux et à la ligne de commande](chapters/ch01-introduction-linux-cli.md)
2. [Chapitre 2 — Système de fichiers et permissions](chapters/ch02-filesystem-permissions.md)
3. [Chapitre 3 — Processus et gestion des tâches](chapters/ch03-processus.md)
4. [Chapitre 4 — Gestion des paquets (zypper, rpm)](chapters/ch04-paquets.md)
5. [Chapitre 5 — Services et systemd (notions)](chapters/ch05-systemd.md)
6. [Chapitre 6 — Réseau de base (IP, ping, curl)](chapters/ch06-reseau-base.md)
7. [Chapitre 7 — Édition et scripts minimalistes](chapters/ch07-scripts-minimalistes.md)
8. [Chapitre 8 — Lab 1 — Environnement de travail](chapters/ch08-lab1-environnement.md)
9. [Chapitre 9 — Lab 2 — Installation d’un service type (Node Exporter)](chapters/ch09-lab2-node-exporter.md)

### À rédiger (objectif ~20–35 pp chacun)

10. [Chapitre 10 — Utilisateurs et groupes](chapters/ch10-utilisateurs-groupes.md)
11. [Chapitre 11 — Planification des tâches (cron, at)](chapters/ch11-cron-at.md)
12. [Chapitre 12 — Compression et archives](chapters/ch12-compression-archives.md)
13. [Chapitre 13 — Recherche et filtres (find, grep, xargs)](chapters/ch13-recherche-filtres.md)
14. [Chapitre 14 — Redirections et tubes](chapters/ch14-redirections-tubes.md)
15. [Chapitre 15 — Notions de virtualisation et conteneurs](chapters/ch15-virtualisation-conteneurs.md)
16. [Chapitre 16 — Lab 3 — Configuration réseau avancée](chapters/ch16-lab3-reseau.md)
17. [Chapitre 17 — Lab 4 — Sécurité de base (utilisateurs, SSH)](chapters/ch17-lab4-securite-base.md)
18. [Chapitre 18 — Synthèse et bonnes pratiques admin](chapters/ch18-synthese-bonnes-pratiques.md)
19. [Chapitre 19 — Annexes (référence commandes, FHS)](chapters/ch19-annexes-reference.md)
20. [Chapitre 20 — Évaluation finale et projet](chapters/ch20-evaluation-projet.md)

---

## Labs

- **Lab 1** (ch. 8) : Environnement de travail (terminal, SSH, structure du projet hpc-cluster).
- **Lab 2** (ch. 9) : Installation et vérification d’un service type (ex. Node Exporter) — lien avec le monitoring du cluster.
- **Lab 3** (ch. 16) : Configuration réseau avancée — à rédiger (~10–30 pp).
- **Lab 4** (ch. 17) : Sécurité de base (utilisateurs, SSH) — à rédiger (~10–30 pp).

---

## Exercices et évaluation

- **Exercices** : `exercises/ch01-exercises.md` … (un fichier par chapitre ou regroupé).
- **Corrigés** : `solutions/ch01-solutions.md` …
- **Évaluation** : QCM ou mini-projet en fin de volume (sujet dans `exercises/`, barème et corrigé dans `solutions/`).

---

## Index rapide

- [Convention 400–800 pages](../../editorial/CIBLE_400_800_PAGES.md)
- [Labs](#labs) (ch. 8, 9, 16, 17)
- [Exercices et corrigés](#exercices-et-évaluation) — `exercises/`, `solutions/`
- [Références](#références)

---

## Références

- **Glossaire** : [course/editorial/GLOSSARY.md](../../editorial/GLOSSARY.md)
- **Bibliographie** : [course/editorial/BIBLIOGRAPHY.md](../../editorial/BIBLIOGRAPHY.md)
- **Source du projet** : [course/editorial/SOURCE_INDEX.md](../../editorial/SOURCE_INDEX.md)
