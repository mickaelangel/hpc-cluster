# PR — course-40-volumes

## Titre

**docs: add editorial framework and Volume 01 (Fondations Linux pour HPC)**

---

## Description

### Objectif

Mise en place du cadre éditorial pour une collection de **40 volumes** de cours (Licence → Master → Doctorat) sur l’administration HPC, l’observabilité, la sécurité et l’exploitation de clusters, puis livraison du **Volume 01** (Fondations Linux pour HPC).

### Modifications

- **Cadre éditorial** (`course/editorial/`) :
  - **SOURCE_INDEX.md** : inventaire des sources du dépôt (README, scripts, docker, configs, wiki, docs) et manques identifiés.
  - **STYLE_GUIDE.md** : charte (titres, blocs de code, admonitions, vocabulaire, objectifs pédagogiques, exercices, pas de secrets).
  - **CROSS_REFERENCE_MAP.md** : plan des 40 volumes (métadonnées, prérequis, objectifs, labs, dépendances).
  - **GLOSSARY.md** et **BIBLIOGRAPHY.md** : glossaire et références communes.
  - **ROADMAP.md** : jalons, granularité (chapitres/pages), méthode de génération incrémentale.

- **Volume 01 — Fondations Linux pour HPC** (`course/volumes/V01_Fondations_Linux_HPC/`) :
  - **book.md** : index du volume, table des matières, liens vers chapitres/labs/exercices.
  - **chapters/** : ch01 (intro Linux/CLI), ch02 (fichiers/permissions), ch03 (processus), ch04 (paquets zypper/rpm), ch05 (systemd), ch06 (réseau base), ch07 (scripts minimalistes), ch08 (Lab 1 — environnement), ch09 (Lab 2 — Node Exporter).
  - **exercises/ch01-exercises.md** : exercices chapitres 1–2.
  - **solutions/ch01-solutions.md** : corrigés.

### Contraintes respectées

- Aucun secret dans la doc ; variables d’environnement et renvoi à `.env.example`.
- Noms de nœuds cohérents avec le repo : `frontal-01`, `frontal-02`, `compute-01` … `compute-06`.
- Contenu factuel traçable au dépôt (SOURCE_INDEX) ; pas de features inventées.

### Comment tester

- [ ] Lire `course/editorial/SOURCE_INDEX.md` et vérifier que les fichiers listés existent dans le repo.
- [ ] Parcourir `course/editorial/CROSS_REFERENCE_MAP.md` (plan 40 volumes) pour cohérence des prérequis et dépendances.
- [ ] Suivre le Volume 01 (book.md → ch01, ch02, …) et exécuter les commandes d’exemple (pwd, ls, chmod, etc.).
- [ ] Vérifier que les exercices ch01/ch02 ont des corrigés dans `solutions/ch01-solutions.md`.
- [ ] Vérifier que les liens vers le wiki (Quickstart DEMO, Troubleshooting) et vers l’editorial (GLOSSARY, STYLE_GUIDE) sont valides.

---

**Branche** : `course-40-volumes`  
**Commits** : atomiques (chore: editorial framework ; docs: V01 skeleton ; docs: V01 ch01–ch09 ; labs: V01 lab1 lab2 ; exercises: V01 ch01 + solutions).
