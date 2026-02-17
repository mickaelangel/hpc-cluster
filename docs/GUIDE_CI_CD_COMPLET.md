# Guide CI/CD Complet - Cluster HPC
## Intégration Continue et Déploiement Continu

**Classification**: Documentation CI/CD  
**Public**: Développeurs / Administrateurs  
**Version**: 1.0

---

## 📚 Table des Matières

1. [GitLab CI](#gitlab-ci)
2. [Jenkins](#jenkins)
3. [GitHub Actions](#github-actions)
4. [Pipeline HPC](#pipeline-hpc)

---

## 🔄 GitLab CI

### Configuration .gitlab-ci.yml

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

## 📚 Documentation Complémentaire

- `GUIDE_CI_CD.md` - CI/CD de base

---

**Version**: 1.0
