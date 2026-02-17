# Contributing to HPC Cluster

Merci de votre intérêt pour contribuer au projet HPC Cluster ! Ce document fournit les guidelines pour contribuer.

## 📋 Table des Matières

- [Code of Conduct](#code-of-conduct)
- [Comment Contribuer](#comment-contribuer)
- [Processus de Développement](#processus-de-développement)
- [Standards de Code](#standards-de-code)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)
- [Tests](#tests)
- [Documentation](#documentation)

## 📜 Code of Conduct

Ce projet adhère à un code de conduite. En participant, vous êtes tenu de maintenir ce code.

## 🤝 Comment Contribuer

### Signaler un Bug

1. Vérifier que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/mickaelangel/hpc-cluster/issues)
2. Créer une nouvelle issue avec :
   - **Titre clair et descriptif**
   - **Description détaillée** du problème
   - **Étapes pour reproduire**
   - **Comportement attendu vs comportement actuel**
   - **Environnement** (OS, versions, etc.)
   - **Logs** si applicable

### Proposer une Fonctionnalité

1. Vérifier que la fonctionnalité n'a pas déjà été proposée
2. Créer une issue avec le label `enhancement`
3. Décrire la fonctionnalité et son utilité
4. Attendre la discussion avant d'implémenter

### Contribuer du Code

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 🔄 Processus de Développement

### Branches

- `main` : Branche de production (stable)
- `develop` : Branche de développement
- `feature/*` : Nouvelles fonctionnalités
- `bugfix/*` : Corrections de bugs
- `hotfix/*` : Corrections urgentes

### Workflow Git

```bash
# 1. Mettre à jour votre fork
git checkout main
git pull upstream main

# 2. Créer une branche feature
git checkout -b feature/my-feature

# 3. Développer et commit
git add .
git commit -m "feat: add amazing feature"

# 4. Push et créer PR
git push origin feature/my-feature
```

## 📝 Standards de Code

### Shell Scripts

- Utiliser `#!/bin/bash` avec `set -euo pipefail`
- Indentation : 2 espaces
- Noms de variables en UPPER_CASE
- Commentaires pour les sections complexes
- Validation des entrées utilisateur

```bash
#!/bin/bash
set -euo pipefail

# Description du script
SCRIPT_NAME="example"
LOG_FILE="/var/log/${SCRIPT_NAME}.log"

function main() {
    # Code principal
}

main "$@"
```

### Documentation

- Markdown avec formatage cohérent
- Table des matières pour les longs documents
- Exemples de code fonctionnels
- Liens vers la documentation officielle

### Docker

- Multi-stage builds quand possible
- Images minimales (Alpine si possible)
- Labels appropriés
- Healthchecks

## 💬 Commit Messages

Format : `type(scope): subject`

### Types

- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation
- `style`: Formatage (pas de changement de code)
- `refactor`: Refactoring
- `test`: Tests
- `chore`: Maintenance

### Exemples

```
feat(monitoring): add Prometheus alerting rules
fix(slurm): correct partition configuration
docs(install): update installation guide
refactor(docker): optimize image builds
```

## 🔍 Pull Requests

### Checklist PR

- [ ] Code suit les standards du projet
- [ ] Tests passent
- [ ] Documentation mise à jour
- [ ] Commit messages suivent le format
- [ ] Pas de conflits avec `main`
- [ ] Description claire de la PR

### Template PR

```markdown
## Description
Brève description des changements

## Type de changement
- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Tests
Comment tester les changements

## Checklist
- [ ] Code testé
- [ ] Documentation mise à jour
- [ ] Pas de régression
```

## 🧪 Tests

### Tests Requis

- Tests unitaires pour les scripts complexes
- Tests d'intégration pour les workflows
- Tests de validation pour les configurations

### Exécuter les Tests

```bash
# Tests de santé du cluster
sudo bash scripts/tests/test-cluster-health.sh

# Tests d'intégration
sudo bash scripts/tests/test-integration.sh

# Tests complets
sudo bash scripts/tests/test-suite-complete.sh
```

## 📚 Documentation

### Mettre à Jour la Documentation

- Ajouter/modifier les guides dans `docs/`
- Mettre à jour `INDEX_DOCUMENTATION_COMPLETE.md`
- Ajouter des exemples si nécessaire
- Vérifier les liens

### Standards Documentation

- Structure claire avec table des matières
- Exemples de code fonctionnels
- Captures d'écran si utile
- Liens vers ressources externes

## 🎯 Priorités

1. **Sécurité** : Corrections de sécurité critiques
2. **Bugs** : Corrections de bugs
3. **Features** : Nouvelles fonctionnalités
4. **Documentation** : Amélioration de la documentation
5. **Refactoring** : Amélioration du code

## 📞 Questions

Pour toute question :
- Ouvrir une [Discussion](https://github.com/mickaelangel/hpc-cluster/discussions)
- Consulter la [Documentation](docs/)
- Contacter les mainteneurs

Merci de votre contribution ! 🚀
