# PR — course-v01-400-800-convention

## Titre

**docs(course): apply 400-800 pages convention and extend V01 with full skeletons (ch10–ch20)**

---

## Description

### Objectif

Appliquer la convention « 400–800 pages » par volume et étendre le Volume 01 (Fondations Linux pour HPC) avec une structure solide et des squelettes propres (chapitres 10–20), sans inventer de contenu technique absent du dépôt.

### Modifications

**Étape 1 — Convention (course/editorial/CIBLE_400_800_PAGES.md)**  
- Objectif et définition 400–800 pages.  
- Conversion page ↔ mots (300–400 mots/page) + exemples de calcul.  
- Gabarit volume (15–25 chapitres + labs + annexes) + formule de sizing.  
- Gabarit chapitre (sections obligatoires + fourchettes de pages).  
- Gabarit lab (objectifs, prérequis, étapes, validation, troubleshooting).  
- Checklist qualité « chapitre prêt ».  
- Stratégie de rédaction incrémentale (lots, jalons, versioning).  
- État actuel (aucun volume n’atteint encore 400–800 pages).

**Étape 2 — V01 (course/volumes/V01_Fondations_Linux_HPC/)**  
- **book.md** : encadré « Cible 400–800 pages » + lien vers `../../editorial/CIBLE_400_800_PAGES.md` ; TOC à 20 chapitres (ch1–9 existants à étendre, ch10–20 squelettes à rédiger) ; index rapide + liens références en format lien Markdown.  
- **ch10–ch20** : squelettes complets par chapitre/lab avec :  
  - Objectifs (3–6 puces), prérequis, taille cible (20–35 pp ou 10–30 pp pour labs).  
  - Plan détaillé (H2/H3).  
  - Section « À écrire » avec TODOs.  
  - Exercices (facile / moyen / challenge).  
  - Validation (commandes génériques Linux).  
  - Références (manpages, docs officielles ; pas de copier-coller ; lien SOURCE_INDEX si spécifique dépôt, sans invention).

**Étape 3 — ROADMAP et README volumes**  
- **ROADMAP.md** : lien CIBLE_400_800_PAGES ; règle « chapitre 20–35 pp, labs 10–30 pp, rédaction incrémentale » ; mini-checklist « Prochaines étapes V01 » (étendre ch1–9, rédiger ch10–20, vérifier checklist qualité).  
- **course/volumes/README.md** : objectif 400–800 pp/volume ; état actuel = structure + contenu partiel ; méthode de progression (chapitre par chapitre).

**Étape 4 — Liens**  
- Vérification : book.md pointe vers tous les chapitres (ch01–ch20) ; liens vers editorial (CIBLE_400_800_PAGES, GLOSSARY, BIBLIOGRAPHY, SOURCE_INDEX) en relatifs corrects. Aucun lien cassé.

### Règles respectées

- Aucun secret (tokens, mots de passe) dans le contenu.  
- Pas d’invention de fonctionnalités propres au dépôt : exemples génériques Linux ; si référence au cluster, renvoi à SOURCE_INDEX / ce qui existe (docker-compose, Dockerfiles, .env.example).  
- Convention et squelettes uniquement ; pas de génération de 400 pages d’un coup.

---

## Checklist « Comment vérifier »

- [ ] Ouvrir `course/editorial/CIBLE_400_800_PAGES.md` et vérifier les 8 sections (objectif, conversion, gabarit volume, gabarit chapitre, gabarit lab, checklist qualité, stratégie incrémentale, état actuel).
- [ ] Ouvrir `course/volumes/V01_Fondations_Linux_HPC/book.md` : encadré « Cible 400–800 pages » présent ; lien vers `../../editorial/CIBLE_400_800_PAGES.md` valide ; table des matières à 20 chapitres ; index rapide et références cliquables.
- [ ] Vérifier l’arborescence : `course/volumes/V01_Fondations_Linux_HPC/chapters/ch10-utilisateurs-groupes.md` … `ch20-evaluation-projet.md` existent.
- [ ] Ouvrir un squelette (ex. ch10 ou ch16) : objectifs, prérequis, plan détaillé, « À écrire » (TODOs), exercices (facile/moyen/challenge), validation, références.
- [ ] Ouvrir `course/editorial/ROADMAP.md` : section « Prochaines étapes V01 » et lien CIBLE_400_800_PAGES.
- [ ] Ouvrir `course/volumes/README.md` : objectif 400–800 pp, état actuel, méthode de progression.
- [ ] Cliquer tous les liens depuis book.md (chapitres 1–20, editorial) : aucun 404.

---

**Branche** : `course-v01-400-800-convention`  
**Commits suggérés** :  
- docs(editorial): add 400-800 pages convention  
- docs(v01): extend toc to 20 chapters + add full skeletons ch10–ch20  
- docs(roadmap): reference convention + chapter length + V01 next steps  
- docs(volumes): update volumes README with convention and method
