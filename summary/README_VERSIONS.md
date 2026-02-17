# Guide des Versions - Cluster HPC
## LDAP + Kerberos vs FreeIPA

**Classification**: Documentation Technique  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Vue d'ensemble

Ce projet propose **deux versions** d'authentification pour le cluster HPC :

1. **Version 1 : LDAP + Kerberos séparés** (Version originale)
2. **Version 2 : FreeIPA** (Solution unifiée)

---

## 🔀 Version 1 : LDAP + Kerberos Séparés

### Caractéristiques

- **LDAP** : 389 Directory Server (annuaire centralisé)
- **Kerberos** : KDC séparé (authentification sécurisée)
- **Configuration** : Deux services à configurer et maintenir
- **Synchronisation** : Manuelle entre LDAP et Kerberos

### Documentation

- **`docs/TECHNOLOGIES_CLUSTER.md`** - Technologies complètes
- **`docs/GUIDE_AUTHENTIFICATION.md`** - Guide LDAP + Kerberos
- **`docs/GUIDE_LANCEMENT_JOBS.md`** - Guide utilisateur
- **`docs/GUIDE_MAINTENANCE.md`** - Guide administrateur
- **`docs/STATUT_INSTALLATION.md`** - État d'installation
- **`docs/INDEX_DOCUMENTATION.md`** - Index

### Installation

```bash
# Script d'installation automatisé
cd cluster\ hpc/scripts
sudo ./install-ldap-kerberos.sh
```

**Guide détaillé** : Voir `docs/GUIDE_INSTALLATION_LDAP_KERBEROS.md`

### Avantages

- ✅ Contrôle total sur chaque service
- ✅ Flexibilité de configuration
- ✅ Compatible avec tous les systèmes

### Inconvénients

- ⚠️ Configuration plus complexe (2 services)
- ⚠️ Synchronisation manuelle nécessaire
- ⚠️ Pas d'interface web
- ⚠️ Maintenance de 2 services

---

## 🆓 Version 2 : FreeIPA

### Caractéristiques

- **FreeIPA** : Solution unifiée (LDAP + Kerberos + DNS + PKI)
- **Configuration** : Un seul service à configurer
- **Synchronisation** : Automatique
- **Interface Web** : Administration graphique

### Documentation

- **`docs/TECHNOLOGIES_CLUSTER_FREEIPA.md`** - Technologies complètes
- **`docs/GUIDE_AUTHENTIFICATION_FREEIPA.md`** - Guide FreeIPA
- **`docs/GUIDE_LANCEMENT_JOBS_FREEIPA.md`** - Guide utilisateur
- **`docs/GUIDE_MAINTENANCE_FREEIPA.md`** - Guide administrateur
- **`docs/STATUT_INSTALLATION_FREEIPA.md`** - État d'installation
- **`docs/INDEX_DOCUMENTATION_FREEIPA.md`** - Index
- **`docs/README_FREEIPA.md`** - Guide rapide

### Installation

```bash
# Script d'installation automatisé
cd cluster\ hpc/scripts
sudo ./install-freeipa.sh
```

**Guide détaillé** : Voir `docs/TECHNOLOGIES_CLUSTER_FREEIPA.md`

### Avantages

- ✅ Solution unifiée (1 service au lieu de 2)
- ✅ Interface web d'administration
- ✅ Synchronisation automatique LDAP ↔ Kerberos
- ✅ DNS intégré
- ✅ PKI intégrée
- ✅ Maintenance simplifiée

### Inconvénients

- ⚠️ Moins de flexibilité (tout est intégré)
- ⚠️ Nécessite une distribution compatible (CentOS/RHEL ou Docker)

---

## 📊 Comparaison

| Aspect | LDAP + Kerberos | FreeIPA |
|--------|----------------|---------|
| **Complexité** | ⚠️ Élevée (2 services) | ✅ Faible (1 service) |
| **Interface Web** | ❌ Non | ✅ Oui |
| **Synchronisation** | ⚠️ Manuelle | ✅ Automatique |
| **DNS** | ❌ Séparé | ✅ Intégré |
| **PKI** | ❌ Séparé | ✅ Intégré |
| **Maintenance** | ⚠️ 2 services | ✅ 1 service |
| **Flexibilité** | ✅ Élevée | ⚠️ Moyenne |
| **Support** | Communautaire | ✅ Communauté + Enterprise |

---

## 🎯 Quelle Version Choisir ?

### Choisir LDAP + Kerberos si :

- Vous avez besoin de contrôle total sur chaque service
- Vous avez une expertise en LDAP et Kerberos
- Vous préférez la flexibilité de configuration
- Vous utilisez des systèmes non compatibles FreeIPA

### Choisir FreeIPA si :

- Vous voulez une solution simple et unifiée
- Vous préférez une interface web d'administration
- Vous voulez une synchronisation automatique
- Vous voulez DNS et PKI intégrés
- Vous préférez une maintenance simplifiée

---

## 📚 Documentation par Version

### Version 1 : LDAP + Kerberos

```
docs/
├── TECHNOLOGIES_CLUSTER.md
├── GUIDE_AUTHENTIFICATION.md
├── GUIDE_LANCEMENT_JOBS.md
├── GUIDE_MAINTENANCE.md
├── STATUT_INSTALLATION.md
└── INDEX_DOCUMENTATION.md

scripts/
└── install-ldap-kerberos.sh
```

### Version 2 : FreeIPA

```
docs/
├── TECHNOLOGIES_CLUSTER_FREEIPA.md
├── GUIDE_AUTHENTIFICATION_FREEIPA.md
├── GUIDE_LANCEMENT_JOBS_FREEIPA.md
├── GUIDE_MAINTENANCE_FREEIPA.md
├── STATUT_INSTALLATION_FREEIPA.md
├── INDEX_DOCUMENTATION_FREEIPA.md
└── README_FREEIPA.md

scripts/
└── install-freeipa.sh
```

---

## 🚀 Installation Rapide

### Version 1 : LDAP + Kerberos

```bash
cd cluster\ hpc
sudo ./scripts/install-ldap-kerberos.sh
```

### Version 2 : FreeIPA

```bash
cd cluster\ hpc
sudo ./scripts/install-freeipa.sh
```

---

## 📝 Notes

- Les deux versions sont **complètes et fonctionnelles**
- Les **jobs peuvent être lancés** avec les deux versions
- Choisissez selon vos besoins et votre expertise
- La documentation est **séparée** pour chaque version

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
