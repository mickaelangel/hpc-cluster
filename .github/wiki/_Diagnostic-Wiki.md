# Diagnostic Wiki — Audit documentation

**Date** : 2025  
**Objectif** : Incohérences, manques, doublons, risques (max 30 lignes).

---

## Diagnostic (synthèse)

1. **Pas de _Sidebar.md / _Footer.md** : navigation wiki non structurée côté thème GitHub ; Home.md et WIKI_HOME.md font office de sommaire.
2. **Doublons** : WIKI_HOME.md et .github/wiki/Home.md se recoupent ; liens vers les mêmes pages (FAQ, Installation-Rapide, etc.) à deux endroits.
3. **Mélange déploiement** : Installation-Rapide.md et Depannage.md utilisent `systemctl` (Prometheus, Grafana) alors que le repo déploie en **Docker** (docker-compose). Risque : commandes inapplicables en mode “stack Docker”.
4. **Secrets / identifiants** : Home.md indique “admin/admin123” pour Grafana ; le projet utilise désormais des variables (.env, défaut démo documenté). À aligner (pas de mot de passe en clair).
5. **Promesses non couvertes** : FAQ mentionne “podman/install-podman.sh” ; à vérifier présence dans le repo. Références à des scripts (diagnostic.sh, verify-installation.sh) à confirmer.
6. **Pages longues** : Manuel volumes 1–9 et Cours-HPC-Complet sont denses ; pas de sommaire cliquable en tête dans plusieurs pages.
7. **Noms de nœuds** : slurm.conf et docker-compose utilisent **compute-01…06** et **frontal-01/02** ; la doc wiki est globalement cohérente (ex. Cas-d-Usage, Guide-Utilisateur). Quelques exemples génériques (compute-045, compute-084) restent des exemples, pas une incohérence.
8. **openSUSE** : Installation-Rapide et FAQ indiquent openSUSE Leap 15.6 ; cohérent avec le repo. Aucune référence SLE SPx à corriger dans les pages auditées.
9. **Manque DEMO vs PROD** : aucune page dédiée “Quickstart DEMO (30 min)” ni “Checklist PROD (hardening, secrets, sauvegardes, upgrade/rollback)”.
10. **Manque Status/Scope** : pas de tableau ✅/🟡/🔜/❌ aligné sur ce qui est réellement implémenté (Docker, Slurm, monitoring, etc.).
11. **Troubleshooting** : Depannage.md existe mais peu de cas “concrets” (ex. conteneur down, Slurm nodes down, Grafana 502) avec commandes exactes et causes probables.
12. **Liens internes** : beaucoup de liens en URL complète (github.com/…/wiki/…). Liens relatifs entre pages wiki amélioreraient la maintenance.
13. **Conventions** : code blocks parfois sans label `bash`/`yaml` ; titres de niveaux (H1/H2) variables selon les pages.
14. **Risque sécurité** : Configuration-de-Base.md et autres peuvent contenir des exemples avec “password” ; audit rapide : privilégier variables d’environnement et renvoi vers .env.example.
15. **Arborescence** : 36 fichiers .md dans .github/wiki ; pas de sous-dossiers (tout à plat). Une structure par thème (getting-started/, reference/, courses/) pourrait clarifier.

---

**Suite** : Structure proposée, _Sidebar.md, _Footer.md, pages Quickstart DEMO / Checklist PROD, Status-Scope, Troubleshooting (10 cas), corrections factuelles et lisibilité.
