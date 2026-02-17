# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

### Added
- Documentation complète (93 guides)
- 54 dashboards Grafana
- Scripts CI/CD GitHub Actions
- Documentation de contribution
- Politique de sécurité

## [2.0.0] - 2024-02-15

### Added
- Architecture complète : 2 frontaux + 6 nœuds de calcul
- Stack monitoring complet : Prometheus, Grafana, InfluxDB, Loki
- Authentification enterprise : LDAP/Kerberos et FreeIPA
- 27+ applications scientifiques
- Big Data & ML : Spark, TensorFlow, PyTorch
- CI/CD : GitLab CI, Jenkins, Tekton
- Sécurité niveau entreprise : MFA, RBAC, Zero Trust
- 258 scripts d'installation/configuration
- Support déploiement hors ligne (air-gapped)
- Documentation complète (93 guides)

### Changed
- Migration vers 100% open-source
- Amélioration de la structure du projet
- Optimisation des configurations Docker

### Fixed
- Corrections de bugs dans les scripts d'installation
- Amélioration de la gestion des erreurs
- Corrections dans la documentation

## [1.0.0] - 2024-01-01

### Added
- Version initiale du cluster HPC
- Configuration Docker de base
- Monitoring basique (Prometheus + Grafana)
- Documentation initiale

---

[Unreleased]: https://github.com/mickaelangel/hpc-cluster/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/mickaelangel/hpc-cluster/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/mickaelangel/hpc-cluster/releases/tag/v1.0.0
