# Convention 400–800 pages par volume

**Objectif** : Chaque volume de la collection vise **400 à 800 pages** (équivalent livre imprimé). Ce document définit la convention, les gabarits et la stratégie de rédaction.

---

## 1. Objectif et définition « 400–800 pages »

- **Cible** : 400 à 800 pages par volume (équivalent A4, police 11–12 pt, interligne standard).
- **Périmètre** : cours + labs + annexes (glossaire, biblio, corrigés) ; hors couverture et pages blanches.
- **Règle** : on ne génère pas 400 pages d’un coup ; on met en place la **convention** et les **squelettes**, puis on rédige **chapitre par chapitre** à pleine longueur.

---

## 2. Conversion page ↔ mots

| Référence | Valeur |
|-----------|--------|
| **1 page** | ≈ **300–400 mots** (ou ~2 500–3 000 signes espaces compris) |
| **400 pages** | ≈ 120 000–160 000 mots |
| **800 pages** | ≈ 240 000–320 000 mots |

**Exemples de calcul** :
- Chapitre cible 25 pages → 25 × 350 ≈ **8 750 mots** (~6 000–10 000 selon densité).
- Lab cible 15 pages → 15 × 350 ≈ **5 250 mots**.
- Volume 20 chapitres × 25 pp + 4 labs × 15 pp + 30 pp annexes → 500 + 60 + 30 = **590 pages**.

---

## 3. Gabarit d’un volume (15–25 chapitres + labs + annexes)

| Élément | Fourchette | Rôle |
|---------|------------|------|
| **Chapitres** | 15–25 | Cours (théorie + pratique) ; ~20–35 pp chacun |
| **Labs** | 2–10 | Guidés pas à pas ; 10–30 pp chacun (peuvent être des chapitres dédiés) |
| **Annexes** | 20–50 pp | Glossaire, biblio, index des commandes, corrigés détaillés |

**Formule de sizing** :
```
Volume (pages) ≈ (nb_chapitres × 25) + (nb_labs × 15) + 30
Ex. : (20 × 25) + (4 × 15) + 30 = 500 + 60 + 30 = 590 pp
```
Ajuster le nombre de chapitres ou la longueur moyenne (20–35 pp/chapitre) pour viser 400–800 pp.

---

## 4. Gabarit d’un chapitre (sections obligatoires + fourchettes)

Chaque chapitre doit contenir (voir aussi STYLE_GUIDE) :

| Section | Fourchette pages | Contenu |
|---------|------------------|---------|
| Objectifs d’apprentissage | 0,5–1 | 3–6 puces claires |
| Prérequis | 0,5 | Chapitres/volumes requis |
| Théorie / concepts | 8–15 | Développement, schémas (Mermaid si utile), tableaux |
| Exemples concrets | 3–5 | Commandes, configs ; si spécifique cluster, uniquement ce qui existe dans le dépôt |
| Erreurs fréquentes / pièges | 1–2 | Pièges courants, bonnes pratiques |
| Validation | 0,5–1 | Commandes pour vérifier que le lecteur a compris |
| Exercices | 2–4 | 3 niveaux : facile / moyen / challenge ; renvoi aux corrigés |
| À retenir | 0,5 | Synthèse en 5–10 points |
| Références | 0,5 | Manpages, docs officielles (sans copier-coller) |

**Total cible par chapitre** : 20–35 pages (~6 000–14 000 mots).

---

## 5. Gabarit d’un lab (objectifs, prérequis, étapes, validation, troubleshooting)

| Section | Contenu |
|---------|---------|
| **Objectifs** | Ce que le lecteur saura faire à la fin (3–5 puces) |
| **Prérequis** | Chapitres lus, environnement (machine, accès root/sudo si besoin) |
| **Durée indicative** | Ex. 45 min – 1 h 30 |
| **Étapes** | Numérotées, avec commandes complètes et sorties attendues (génériques Linux OK ; si spécifique dépôt, référencer uniquement ce qui existe) |
| **Validation** | Commandes ou critères pour vérifier que le lab est réussi |
| **Troubleshooting** | 3–5 pannes courantes + cause probable + correctif (sans inventer de features du repo) |

**Longueur cible lab** : 10–30 pages (~3 000–12 000 mots).

---

## 6. Checklist qualité « chapitre prêt »

Avant de considérer un chapitre comme rédigé à pleine longueur :

- [ ] Objectifs (3–6 puces) présents et clairs
- [ ] Prérequis indiqués
- [ ] Théorie développée (8–15 pp équivalent)
- [ ] Exemples concrets (commandes/configs) ; pas d’invention sur le dépôt
- [ ] Section « Erreurs fréquentes / pièges »
- [ ] Section « Validation » avec commandes exécutables
- [ ] Exercices (facile / moyen / challenge) + renvoi corrigés
- [ ] « À retenir » en fin de chapitre
- [ ] Références (man, docs officielles)
- [ ] Aucun secret (mot de passe, token) dans le texte
- [ ] Longueur cible : ~20–35 pp (~6k–14k mots) pour un chapitre ; ~10–30 pp pour un lab

---

## 7. Stratégie de rédaction incrémentale (lots, jalons, versioning)

- **Lot** = 1 chapitre complet (ou 1 lab) rédigé à pleine longueur selon le gabarit.
- **Jalons** : voir [ROADMAP.md](ROADMAP.md) (V01 : étendre ch1–9, puis rédiger ch10–20 ; puis V02, etc.).
- **Ordre** : rédiger dans l’ordre des chapitres pour éviter les incohérences ; les références croisées restent « Chapitre X (à venir) » tant que non rédigé.
- **Versioning** : pas de version sémantique imposée ; indiquer en tête de volume ou de chapitre « Version courte » vs « Version pleine longueur » si utile.
- **Ne pas** : générer 400 pages d’un coup ; inventer des fonctionnalités absentes du dépôt ; inclure des secrets.

---

## 8. État actuel

**Aucun volume n’atteint encore 400–800 pages.** État actuel :

- **V01** : structure à 20 chapitres ; chapitres 1–9 rédigés en **version courte** (à étendre) ; chapitres 10–20 en **squelette** (à rédiger à 20–35 pp chacun).
- **V02–V40** : squelette (book.md par volume) ; contenu à rédiger volume par volume.

La rédaction se fait **progressivement** : convention et squelettes d’abord, puis chapitre par chapitre à pleine longueur.

---

## Fichiers de référence

- [STYLE_GUIDE.md](STYLE_GUIDE.md) — format des chapitres, admonitions, code
- [ROADMAP.md](ROADMAP.md) — jalons et prochaines étapes V01
- [CROSS_REFERENCE_MAP.md](CROSS_REFERENCE_MAP.md) — plan des 40 volumes
