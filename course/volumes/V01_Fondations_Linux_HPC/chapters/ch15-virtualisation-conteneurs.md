# Chapitre 15 — Notions de virtualisation et conteneurs

**Cible** : 20–35 pages (~6 000–14 000 mots).

---

## Objectifs

- Distinguer machine virtuelle (VM) et conteneur (isolation, noyau partagé).
- Comprendre les concepts de base de Docker (image, conteneur, registre).
- Relier au dépôt : présence de Docker/docker-compose pour le cluster (référence SOURCE_INDEX uniquement).
- Bonnes pratiques génériques (pas de secret dans les images, variables d’environnement).
- Ne pas inventer de fonctionnalités absentes du repo.

---

## Prérequis

- Chapitres 1–7 (CLI, processus, services, réseau de base).
- Notion de processus et d’isolation.

---

## Plan détaillé

1. **Virtualisation** — VM : hyperviseur, noyau dédié par VM ; cas d’usage.
2. **Conteneurs** — isolation (namespaces, cgroups) ; image vs conteneur ; exécution.
3. **Docker (notions)** — image, conteneur, Dockerfile (présentation générique) ; docker run, docker ps.
4. **Lien avec le projet** — si le dépôt contient docker-compose et Dockerfiles (frontal, client), les mentionner comme exemples réels ; sinon marquer « Planned » ou renvoyer à SOURCE_INDEX. Ne pas inventer de détails non présents.
5. **Bonnes pratiques** — pas de secrets en clair ; variables d’environnement ; .env non versionné.
6. **Erreurs fréquentes** — confondre image et conteneur ; oublier la persistance (volumes).
7. **Validation** — commandes génériques (docker ps, docker images) si Docker disponible.
8. **Exercices** — facile / moyen / challenge.
9. **À retenir** — synthèse.
10. **Références** — doc Docker officielle ; SOURCE_INDEX pour le dépôt.

---

## À écrire

- [ ] **TODO** : Rédiger sections 1–3 (théorie VM/conteneurs, Docker) — 8–12 pp.
- [ ] **TODO** : Rédiger section 4 en s’appuyant uniquement sur les fichiers existants (docker-compose, Dockerfiles) ; pas d’invention.
- [ ] **TODO** : Rédiger sections 5–10.

---

## Exercices

**Facile** : Expliquer la différence VM / conteneur en 5 lignes ; lister les conteneurs (docker ps) si Docker est installé.

**Moyen** : À partir du dépôt, identifier le fichier docker-compose et le nombre de services décrits (sans inventer).

**Challenge** : Décrire comment le projet gère les secrets (référence .env.example, pas de mot de passe en clair) ; documenter sans exposer de valeur réelle.

---

## Validation

```bash
# Si Docker disponible :
docker ps -a
docker images
# Référence dépôt : présence de docker/docker-compose-opensource.yml (voir SOURCE_INDEX)
```

---

## Références

- Documentation Docker : https://docs.docker.com/
- [SOURCE_INDEX](../../../editorial/SOURCE_INDEX.md) — sections Docker, docker-compose, Dockerfiles du dépôt (uniquement ce qui existe).
