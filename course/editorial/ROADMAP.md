# ROADMAP — Passage à 40 volumes

**Objectif** : Atteindre 40 volumes de 400–800 pages chacun, de façon incrémentale (volume par volume, chapitre par chapitre).

---

## Jalons

| Jalon | Contenu | Estimation |
|-------|---------|------------|
| **J1** | Cadre éditorial (SOURCE_INDEX, STYLE_GUIDE, CROSS_REFERENCE_MAP, GLOSSARY, BIBLIOGRAPHY, ROADMAP) | Fait |
| **J2** | V01 « Fondations Linux pour HPC » — structure + 6–8 chapitres + 2 labs + exercices + corrigés | En cours |
| **J3** | V02 … V05 (Licence) — même format, dépendances V01 | Lots successifs |
| **J4** | V06 … V14 (Licence) — compléter le socle Licence | Lots successifs |
| **J5** | V15 … V24 (Master) — Slurm avancé, stockage, conteneurs, observabilité, IaC | Par volume |
| **J6** | V25 … V30 (Master) — HA, backup, capacity, sécurité, CI/CD, projet Master | Par volume |
| **J7** | V31 … V40 (Doctorat) — théorie, énergie, chaos, benchmarking, SRE, synthèse | Par volume |

---

## Granularité pour 400–800 pages/volume

- **Chapitres** : 15–25 par volume.
- **Pages équivalent** : ~15–25 pages par chapitre (texte + figures + exercices).
- **Lots** : 1 chapitre complet à la fois (objectifs, cours, exemples, erreurs fréquentes, validation, exercices, corrigé séparé).
- **Labs** : 2–3 par volume en Licence ; 3–5 en Master/Doctorat.

---

## Méthode de génération

1. **Ne pas écrire les 40 volumes d’un coup** : risque de incohérence et de fatigue.
2. **Volume par volume** : finaliser V01 (structure + contenu minimal), puis V02, etc.
3. **Release interne** : à chaque volume, appliquer la checklist qualité (STYLE_GUIDE) et mettre à jour CROSS_REFERENCE_MAP si besoin.
4. **Export** : Option A — Quarto (`_quarto.yml` par volume) ; Option B — MkDocs Material + plugin PDF. Build guide à rédiger une fois l’option choisie.

---

## Estimation des lots (indicative)

- **V01** : 6–8 chapitres + 2 labs + exercices ≈ 80–120 pages équivalent (première version).
- **Extension** : ajouter chapitres jusqu’à 15–25 pour atteindre 400+ pages (thèmes : sécurité basique, réseau, premiers pas Slurm côté utilisateur, etc.).
- **V02–V14** : idem, ~2–4 semaines par volume en rythme soutenu (selon disponibilité).
- **Master/Doctorat** : contenu plus dense ; 1–2 mois par volume réaliste pour version 1.0.

---

## Dépendances éditoriales

- **SOURCE_INDEX** : à mettre à jour si le dépôt acquiert de nouveaux guides ou scripts.
- **CROSS_REFERENCE_MAP** : à ajuster si le découpage des volumes change.
- **GLOSSARY** : enrichir au fil des volumes (nouveaux termes).
- **BIBLIOGRAPHY** : ajouter les références spécifiques à chaque volume en fin de chapitre ou en annexe.
