# Guide CI/CD - Cluster HPC
## GitLab CI pour Automatisation

**Classification**: Documentation DevOps  
**Public**: Administrateurs / Développeurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation GitLab CI](#installation-gitlab-ci)
3. [Configuration Pipeline](#configuration-pipeline)
4. [Stages et Jobs](#stages-et-jobs)
5. [Utilisation](#utilisation)
6. [Intégration Cluster](#intégration-cluster)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**CI/CD (Continuous Integration / Continuous Deployment)** : Automatisation du développement, des tests et du déploiement.

### Bénéfices

- ✅ **Tests automatiques** : Validation à chaque changement
- ✅ **Déploiement automatisé** : Réduction erreurs
- ✅ **Rollback rapide** : Retour en arrière facile
- ✅ **Traçabilité** : Historique complet

---

## 🚀 Installation GitLab CI

### Installation GitLab Runner

```bash
./scripts/ci-cd/install-gitlab-ci.sh
```

### Configuration Runner

```bash
# Enregistrer runner
gitlab-runner register

# Informations requises :
# - URL GitLab : http://gitlab.example.com
# - Token : <registration-token>
# - Description : hpc-cluster-runner
# - Tags : hpc, cluster
# - Executor : shell ou docker
```

### Vérification

```bash
# Vérifier runner
gitlab-runner list

# Tester runner
gitlab-runner verify
```

---

## ⚙️ Configuration Pipeline

### Fichier .gitlab-ci.yml

**Exemple basique** :
```yaml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - ./scripts/tests/test-cluster-health.sh
    - ./scripts/tests/test-infrastructure.sh
    - ./scripts/tests/test-applications.sh
  only:
    - main
    - develop

build:
  stage: build
  script:
    - cd docker
    - docker-compose build
  only:
    - main

deploy:
  stage: deploy
  script:
    - cd docker
    - docker-compose up -d
  only:
    - main
  when: manual
```

### Pipeline Complet

**Exemple avancé** :
```yaml
variables:
  DOCKER_IMAGE: hpc-cluster:latest

stages:
  - validate
  - test
  - build
  - deploy
  - monitor

validate:
  stage: validate
  script:
    - yamllint docker-compose.yml
    - shellcheck scripts/*.sh
  only:
    - merge_requests

test:
  stage: test
  script:
    - ./scripts/tests/test-cluster-health.sh
    - ./scripts/tests/test-infrastructure.sh
    - ./scripts/tests/test-applications.sh
    - ./scripts/tests/test-integration.sh
  coverage: '/Coverage: \d+\.\d+%/'
  artifacts:
    reports:
      junit: test-results.xml
    paths:
      - test-reports/

build:
  stage: build
  script:
    - cd docker
    - docker-compose build
    - docker tag hpc-cluster:latest $DOCKER_IMAGE
  only:
    - main

deploy:
  stage: deploy
  script:
    - cd docker
    - docker-compose up -d
    - ./scripts/tests/test-cluster-health.sh
  environment:
    name: production
    url: http://frontal-01:3000
  only:
    - main
  when: manual

monitor:
  stage: monitor
  script:
    - ./scripts/monitoring/check-services.sh
  only:
    - main
```

---

## 📋 Stages et Jobs

### Stage : Validate

**Objectif** : Valider la syntaxe et la configuration

```yaml
validate:
  stage: validate
  script:
    - yamllint .
    - shellcheck scripts/*.sh
    - terraform validate
```

### Stage : Test

**Objectif** : Exécuter tous les tests

```yaml
test-infrastructure:
  stage: test
  script:
    - ./scripts/tests/test-infrastructure.sh
  artifacts:
    when: always
    paths:
      - test-reports/
```

### Stage : Build

**Objectif** : Construire les images Docker

```yaml
build:
  stage: build
  script:
    - docker-compose build
  artifacts:
    paths:
      - docker-images/
```

### Stage : Deploy

**Objectif** : Déployer sur le cluster

```yaml
deploy:
  stage: deploy
  script:
    - ./scripts/deployment/deploy-cluster.sh
  environment:
    name: production
  when: manual
```

---

## 🔄 Utilisation

### Déclencher Pipeline

**Automatique** :
- Push sur `main` ou `develop`
- Merge request

**Manuel** :
```bash
# Via interface GitLab
# CI/CD → Pipelines → Run Pipeline

# Via API
curl -X POST \
  -F token=$CI_JOB_TOKEN \
  -F ref=main \
  https://gitlab.example.com/api/v4/projects/1/trigger/pipeline
```

### Suivre Pipeline

**Interface GitLab** :
1. Aller dans CI/CD → Pipelines
2. Voir statut jobs
3. Consulter logs
4. Télécharger artifacts

**CLI** :
```bash
# Voir pipelines
gitlab-runner list

# Voir logs
gitlab-runner logs
```

---

## 🔗 Intégration Cluster

### Tests Cluster

```yaml
test-cluster:
  stage: test
  script:
    - ssh admin@frontal-01 './scripts/tests/test-cluster-health.sh'
    - ssh admin@frontal-01 'sinfo'
    - ssh admin@frontal-01 'squeue'
```

### Déploiement Cluster

```yaml
deploy-cluster:
  stage: deploy
  script:
    - |
      ssh admin@frontal-01 << EOF
        cd /opt/hpc-cluster
        git pull
        cd docker
        docker-compose pull
        docker-compose up -d
      EOF
```

---

## 🔧 Dépannage

### Problèmes Courants

**Runner ne démarre pas** :
```bash
# Vérifier service
systemctl status gitlab-runner

# Vérifier logs
journalctl -u gitlab-runner -f
```

**Pipeline échoue** :
```bash
# Vérifier logs
gitlab-runner logs

# Vérifier configuration
gitlab-runner verify
```

**Jobs timeout** :
```yaml
# Augmenter timeout
test:
  timeout: 1h
  script:
    - ./long-running-test.sh
```

---

## 📚 Documentation Complémentaire

- `GUIDE_TESTS.md` - Guide tests automatisés
- `GUIDE_DEPLOIEMENT_PRODUCTION.md` - Déploiement production
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
