# 🔧 CI/CD — Pipelines et automatisation

> **Intégration continue et déploiement continu sur le Cluster HPC Enterprise**

---

## 🎯 Vue d'ensemble

Le cluster intègre des **pipelines CI/CD** pour automatiser build, tests et déploiements : GitLab CI, Jenkins, GitHub Actions, et pipelines dédiés HPC.

---

## Outils supportés

| Outil | Usage |
|--------|--------|
| **GitLab CI** | Pipelines dans le dépôt (`.gitlab-ci.yml`) |
| **Jenkins** | Jobs automatisés, intégration multi-environnements |
| **GitHub Actions** | Workflows dans le dépôt (`.github/workflows/`) |
| **Pipeline HPC** | Build, test et déploiement des stacks cluster |

---

## Exemple GitLab CI

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - make build

test:
  stage: test
  script:
    - make test

deploy:
  stage: deploy
  script:
    - make deploy
```

---

## Bonnes pratiques

- **Stages** : build → test → deploy
- **Artifacts** : conserver binaires / images pour les étapes suivantes
- **Secrets** : utiliser les variables protégées (GitLab / GitHub / Jenkins), jamais en clair
- **HPC** : lancer les jobs de test via Slurm (`sbatch` / `srun`) depuis le pipeline

---

## 📚 Documentation complète

- **Guide CI/CD complet** : [docs/GUIDE_CI_CD_COMPLET.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_CI_CD_COMPLET.md)
- **Guide CI/CD de base** : [docs/GUIDE_CI_CD.md](https://github.com/mickaelangel/hpc-cluster/blob/main/docs/GUIDE_CI_CD.md)

---

## Voir aussi

- **[Infrastructure as Code](Infrastructure-as-Code)** — Terraform, Ansible
- **[Monitoring](Monitoring)** — Observabilité des déploiements
- **[Home](Home)** — Accueil du wiki

---

[← Accueil](Home)
