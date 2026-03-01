# Charte éditoriale — Collection de cours HPC

**Objectif** : Uniformiser titres, blocs de code, admonitions, vocabulaire et structure pédagogique pour les 40 volumes.

---

## 1. Titres et hiérarchie

- **H1** (`#`) : Titre du volume ou de la page (une seule H1 par fichier).
- **H2** (`##`) : Partie ou chapitre (ex. « Chapitre 1 : Introduction »).
- **H3** (`###`) : Section (ex. « 1.1 Le paradigme du co-design »).
- **H4** (`####`) : Sous-section si nécessaire.
- Numérotation : Chapitre N, Section N.M (ex. 1.1, 1.2, 2.1).
- Titres courts, sans point final ; pas de caractères spéciaux inutiles.

---

## 2. Blocs de code

- Toujours préciser le langage pour la coloration :
  - `bash` pour commandes shell (Linux/WSL).
  - `yaml` pour YAML (docker-compose, Ansible, Prometheus).
  - `ini` pour fichiers .ini (Grafana).
  - `text` ou pas de label si sortie brute.
- Exemple :

````markdown
```bash
docker compose -f docker/docker-compose-opensource.yml up -d
```
````

- Les chemins et noms de nœuds doivent être cohérents avec le repo : `frontal-01`, `compute-01` … `compute-06`, `configs/slurm/slurm.conf`.

---

## 3. Admonitions (encadrés)

- **NOTE** : Information utile, rappel.
- **ATTENTION** : Piège, erreur fréquente, risque.
- **EXEMPLE** : Cas concret, commande commentée.
- **À retenir** : Synthèse en fin de section.

Format proposé (Markdown) :

```markdown
> **NOTE** — Les limites `deploy.resources` dans docker-compose ne s’appliquent qu’en mode Docker Swarm.
```

```markdown
> **ATTENTION** — Ne jamais commiter le fichier `.env` contenant des secrets.
```

---

## 4. Vocabulaire et acronymes

- **Première occurrence** : écrire en entier puis acronyme entre parenthèses (ex. « High Performance Computing (HPC) »).
- Termes récurrents : Slurm, Munge, LDAP, FreeIPA, Prometheus, Grafana, InfluxDB, Loki, Promtail, SlurmCTLD, SlurmD, SlurmDBD.
- Renvoyer au **Glossaire** (course/editorial/GLOSSARY.md ou wiki Glossaire-et-Acronymes) pour les définitions.
- Noms de nœuds du projet : `frontal-01`, `frontal-02`, `compute-01` … `compute-06` (pas `slave-01` dans la doc alignée).

---

## 5. Objectifs pédagogiques et prérequis

En début de chapitre :

- **Objectifs** : 3 à 6 puces (compétences visées).
- **Prérequis** : chapitres ou volumes précédents, connaissances supposées.
- **Durée indicative** : optionnel (ex. 1h lecture, 30 min lab).

Format :

```markdown
### Objectifs d'apprentissage
- Comprendre...
- Savoir configurer...
- Être capable de diagnostiquer...
```

---

## 6. Évaluation et exercices

- **Exercices** : numérotés (Ex. 1.1, 1.2), progressifs (du simple au projet).
- **Corrigés** : dans un fichier séparé (ex. `solutions/ch01_exercises.md`) pour éviter le spoiler.
- **Labs** : objectif, prérequis, étapes numérotées, commandes complètes, critères de validation.
- **QCM / études de cas** : barème et corrigé en annexe ou document séparé.

---

## 7. Références et citations

- Pas de copier-coller de docs externes ; paraphraser. Si citation courte (1–2 phrases), indiquer la source.
- Liens : préférer liens stables (doc officielle, RFC). Éviter les URLs qui changent souvent.
- **Bibliographie** : course/editorial/BIBLIOGRAPHY.md pour les références communes.

---

## 8. Contenu factuel et repo

- Toute affirmation sur le **projet** (scripts, configs, noms de nœuds, versions) doit être vérifiable dans le dépôt (voir SOURCE_INDEX.md).
- Si une fonctionnalité n’est **pas** dans le repo : marquer « Planned », « Out-of-scope » ou « Hypothèse / à implémenter ».
- Pas de secrets : uniquement variables d’environnement (ex. `GF_SECURITY_ADMIN_PASSWORD`) et renvoi à `.env.example`.

---

## 9. Figures et schémas

- **Mermaid** : pour diagrammes (flux, architecture) quand c’est lisible.
- **Tableaux** : pour comparatifs (ex. démo vs prod, composants).
- Légendes courtes sous chaque figure.

---

## 10. Sommaire

- Pages longues (> 2 écrans) : sommaire en tête avec ancres (liens vers les H2/H3).
- Exemple : `## Sommaire` puis liste à puces avec `[Texte](#ancre)` (ancre = titre en minuscules, espaces en tirets).
