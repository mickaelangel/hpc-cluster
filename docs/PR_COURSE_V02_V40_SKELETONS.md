# PR — course-v02-v40-skeletons

## Titre

**docs(course): add full skeletons V02→V40 (structure + chapters/labs), convention 400–800 pp**

---

## Description

### Objectif

Créer et pousser les **squelettes** des volumes V02→V40 (structure livre + chapitres/labs), en appliquant la convention 400–800 pages, sans rédiger le contenu long — même esprit que V01 ch10–ch20.

### Modifications

- **Templates** : `course/editorial/TEMPLATE_CHAPTER.md` et `TEMPLATE_LAB.md` (sections obligatoires : objectifs, prérequis, taille cible, plan, À écrire/TODOs, exercices 3 niveaux, validation, références).
- **Volumes V02–V40** (nouveaux titres HPC + observabilité + SRE) :
  - **V02_Linux_Avance_Admins** … **V40_Projet_Doctoral_Etude** (dossiers + `book.md` + `chapters/` + `figures/` + `assets/`).
  - Chaque `book.md` : encadré « Cible 400–800 pages », lien vers CIBLE_400_800_PAGES, index rapide (GLOSSARY, BIBLIOGRAPHY, SOURCE_INDEX), table des matières 14 chapitres (squelettes à rédiger / labs 10–30 pp), liens cliquables vers chaque chapitre.
  - Chaque chapitre : squelette complet (objectifs, prérequis, plan, À écrire avec TODOs, exercices facile/moyen/challenge, validation, références) ; pas de contenu long ; zéro secret ; pas d’invention dépôt.
- **Script** : `course/scripts/gen_volumes_skeletons.py` (génération V03–V40).
- **Index** : `course/volumes/README.md` — liste V01–V40 avec statut « Structure + squelettes » et liens vers les nouveaux dossiers.
- **ROADMAP** : jalon « Squelettes V02–V40 créés » + prochaine étape « rédiger chapitre par chapitre ».

### Règles respectées

- Aucun secret (tokens, mots de passe).
- Pas d’invention de fonctionnalités spécifiques au dépôt (contenu générique Linux/HPC).
- Même style, mêmes sections, même convention que V01.

---

## Checklist de vérification

- [ ] Ouvrir `course/editorial/TEMPLATE_CHAPTER.md` et `TEMPLATE_LAB.md` : sections obligatoires présentes.
- [ ] Ouvrir `course/volumes/V02_Linux_Avance_Admins/book.md` : encadré 400–800 pp, lien CIBLE_400_800_PAGES, TOC avec liens vers chapters/*.
- [ ] Cliquer les liens des chapitres 1–14 : tous valides.
- [ ] Ouvrir un chapitre (ex. ch01-introduction.md) : objectifs, prérequis, plan, À écrire (TODOs), exercices, validation, références.
- [ ] Vérifier un volume généré (ex. V03_Reseaux_Linux_HPC) : book.md + 14 fichiers dans chapters/ + figures/.gitkeep + assets/.gitkeep.
- [ ] Ouvrir `course/volumes/README.md` : liste V01–V40 avec liens vers les dossiers (V02_Linux_Avance_Admins … V40_Projet_Doctoral_Etude).
- [ ] Ouvrir `course/editorial/ROADMAP.md` : jalon J2c + prochaine étape rédaction.
- [ ] Aucun lien cassé depuis les book.md ; aucun secret dans les squelettes.

---

**Branche** : `course-v02-v40-skeletons`  
**Push** : `git push -u origin course-v02-v40-skeletons`
