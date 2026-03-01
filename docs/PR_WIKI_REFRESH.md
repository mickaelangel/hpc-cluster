# PR — docs/wiki-refresh

## Titre

**docs: refresh wiki — structure, DEMO/PROD, Status-Scope, Troubleshooting, corrections factuelles**

---

## Description

### Objectif

Audit et amélioration de la documentation Wiki du dépôt : cohérence, navigation, split DEMO/PROD, alignement avec ce qui est réellement implémenté, et corrections factuelles.

### Modifications

- **Diagnostic** : `.github/wiki/_Diagnostic-Wiki.md` — synthèse des incohérences, doublons, risques (15 points).
- **Structure** : `.github/wiki/_Structure-Wiki-Proposee.md` — arborescence et plan de navigation.
- **Navigation** : `.github/wiki/_Sidebar.md` et `_Footer.md` — menu hiérarchisé et pied de page.
- **DEMO / PROD** :
  - **Quickstart DEMO (30 min)** : `.github/wiki/Quickstart-DEMO.md` — installation Docker, .env, vérifications, accès aux services (sans secrets en clair).
  - **Checklist PROD** : `.github/wiki/Checklist-PROD.md` — hardening, secrets, sauvegardes, upgrade/rollback.
- **Status / Scope** : `.github/wiki/Status-Scope.md` — tableau ✅/🟡/🔜/❌ aligné sur le repo (Docker, Slurm, monitoring, auth, formation).
- **Troubleshooting** : `.github/wiki/Troubleshooting.md` — 10 cas réels avec commandes Docker, causes probables et correctifs.
- **Corrections factuelles** :
  - `Home.md` : identifiants Grafana/InfluxDB via variables d’environnement + lien Quickstart DEMO ; quick start basé sur `make up-demo` / Docker.
  - `Installation-Rapide.md` : contexte « Docker vs bare-metal », vérification selon le type de déploiement (docker ps / make health vs systemctl).
  - `Depannage.md` : sommaire + note sur l’usage Docker (docker logs, docker exec) et lien vers Troubleshooting.
  - `WIKI_HOME.md` : liens vers Quickstart-DEMO, Checklist-PROD, Status-Scope, Troubleshooting.

### Risques

- Aucun changement de code ou de configuration ; documentation uniquement.
- Les liens relatifs entre pages wiki peuvent nécessiter un ajustement selon la façon dont GitHub restitue le wiki (ancres, noms de fichiers).

### Comment tester

- [ ] Lire `Quickstart-DEMO.md` et exécuter les étapes (clone, `make up-demo` ou docker compose, vérifications).
- [ ] Vérifier que `Checklist-PROD.md` et `Status-Scope.md` reflètent bien le contenu du repo (slurm.conf, docker-compose, scripts).
- [ ] Parcourir `Troubleshooting.md` et vérifier que les commandes (docker, curl, scontrol) sont cohérentes avec le projet.
- [ ] Vérifier les liens internes depuis `Home.md` et `WIKI_HOME.md` vers les nouvelles pages.
- [ ] Confirmer qu’aucun secret (mot de passe en clair) n’apparaît dans les pages modifiées ou ajoutées.

---

**Branche** : `docs/wiki-refresh`  
**Commits** : atomiques (nav, corrections factuelles, pages demo/prod, troubleshooting, etc.)
