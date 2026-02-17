# Index de la Documentation - Cluster HPC
## Guide Complet pour Étudiants Master et Ingénieurs

**Classification**: Documentation Technique  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Documentation Disponible

### 1. Technologies et Outils

**📄 `TECHNOLOGIES_CLUSTER.md`**

Documentation complète sur tous les outils installés dans le cluster :

- **Stack d'Authentification** : LDAP, Kerberos, FreeIPA
- **Gestion des Packages** : Nexus, Spack
- **Remote Graphics** : Exceed TurboX
- **Scheduler** : Slurm
- **Stockage** : GPFS
- **Monitoring** : Prometheus, Grafana, Telegraf
- **Provisioning** : TrinityX, Warewulf

**Public** : Étudiants Master / Ingénieurs  
**Niveau** : Intermédiaire à Avancé

---

### 2. Authentification

**📄 `GUIDE_AUTHENTIFICATION.md`**

Guide détaillé sur l'authentification centralisée :

- **LDAP (389 Directory Server)** : Installation, configuration, opérations
- **Kerberos** : KDC, tickets, SSO
- **Intégration LDAP + Kerberos** : Synchronisation
- **FreeIPA** : Alternative tout-en-un
- **Configuration Clients** : SSSD, PAM, NSS
- **Dépannage** : Problèmes courants et solutions

**Public** : Étudiants Master / Ingénieurs  
**Niveau** : Intermédiaire

---

### 3. Lancement de Jobs

**📄 `GUIDE_LANCEMENT_JOBS.md`**

Guide pratique pour lancer des jobs sur le cluster :

- **Prérequis** : Authentification, environnement
- **Jobs Slurm** : Simple, MPI, GPU
- **Jobs MATLAB** : Batch, Parallel, DCS
- **Jobs OpenM++** : Simple, multi-nœuds
- **Applications Graphiques** : Exceed TurboX
- **Monitoring** : Suivi des jobs
- **Dépannage** : Problèmes courants

**Public** : Utilisateurs du cluster  
**Niveau** : Débutant à Intermédiaire

---

### 4. Maintenance

**📄 `GUIDE_MAINTENANCE.md`**

Procédures opérationnelles pour les administrateurs :

- **Maintenance Préventive** : Vérifications quotidiennes/hebdomadaires/mensuelles
- **Maintenance des Services** : Slurm, LDAP, Kerberos, GPFS, Monitoring
- **Monitoring et Alertes** : Configuration, métriques
- **Sauvegardes** : LDAP, Kerberos, GPFS, Slurm
- **Mises à Jour** : Procédures de mise à jour
- **Dépannage** : Problèmes courants
- **Procédures d'Urgence** : Panne, perte de données

**Public** : Administrateurs Système  
**Niveau** : Avancé

---

### 5. État d'Installation

**📄 `STATUT_INSTALLATION.md`**

Vérification de l'état des composants installés :

- **Composants Installés** : Tableau récapitulatif
- **Capacité de Lancement de Jobs** : Vérification fonctionnelle
- **Script de Vérification** : Script automatisé
- **Notes Importantes** : Limitations, prérequis

**Public** : Tous  
**Niveau** : Tous niveaux

---

## 🎯 Parcours d'Apprentissage

### Pour un Étudiant Master

1. **Commencer par** : `STATUT_INSTALLATION.md`
   - Comprendre ce qui est installé
   - Vérifier l'état du cluster

2. **Ensuite** : `GUIDE_LANCEMENT_JOBS.md`
   - Apprendre à lancer des jobs
   - Exemples pratiques

3. **Puis** : `TECHNOLOGIES_CLUSTER.md`
   - Comprendre les outils utilisés
   - Architecture générale

4. **Enfin** : `GUIDE_AUTHENTIFICATION.md`
   - Comprendre l'authentification
   - Configuration avancée

### Pour un Ingénieur

1. **Commencer par** : `TECHNOLOGIES_CLUSTER.md`
   - Vue d'ensemble technique
   - Architecture détaillée

2. **Ensuite** : `GUIDE_AUTHENTIFICATION.md`
   - Configuration et intégration
   - Dépannage avancé

3. **Puis** : `GUIDE_MAINTENANCE.md`
   - Procédures opérationnelles
   - Maintenance préventive

4. **Enfin** : `STATUT_INSTALLATION.md`
   - Vérification de l'état
   - Scripts de vérification

### Pour un Administrateur

1. **Commencer par** : `GUIDE_MAINTENANCE.md`
   - Procédures opérationnelles
   - Maintenance préventive

2. **Ensuite** : `GUIDE_AUTHENTIFICATION.md`
   - Configuration avancée
   - Intégration des services

3. **Puis** : `TECHNOLOGIES_CLUSTER.md`
   - Architecture détaillée
   - Comprendre les interactions

4. **Enfin** : `STATUT_INSTALLATION.md`
   - Vérification complète
   - Scripts automatisés

---

## 📖 Résumé des Technologies

### Authentification
- ✅ **LDAP (389 Directory Server)** : Annuaire centralisé
- ✅ **Kerberos** : Authentification sécurisée avec tickets
- ⚠️ **FreeIPA** : Alternative tout-en-un (optionnel)

### Gestion des Packages
- ✅ **Nexus Repository** : Miroir PyPI privé
- ✅ **Spack** : Gestionnaire packages scientifiques

### Remote Graphics
- ✅ **Exceed TurboX** : Applications graphiques distantes

### Scheduler
- ✅ **Slurm** : Gestionnaire de jobs et ressources

### Stockage
- ✅ **GPFS** : Système de fichiers parallèle

### Monitoring
- ✅ **Prometheus** : Collecte métriques
- ✅ **Grafana** : Visualisation
- ✅ **InfluxDB** : Base séries temporelles
- ✅ **Telegraf** : Agents de collecte

### Provisioning
- ✅ **TrinityX** : Interface web de gestion
- ✅ **Warewulf** : Provisioning PXE

---

## ✅ Vérification : Peut-on Lancer des Jobs ?

### Réponse : ✅ OUI

**Tous les composants nécessaires sont installés et fonctionnels** :

1. ✅ **Authentification** : LDAP + Kerberos opérationnels
2. ✅ **Scheduler** : Slurm fonctionnel
3. ✅ **Stockage** : GPFS monté et accessible
4. ✅ **Monitoring** : Stack complète opérationnelle

**Prérequis pour lancer des jobs** :
- Compte LDAP/Kerberos valide
- Accès SSH aux nœuds
- Quota GPFS disponible
- Applications installées (MATLAB, OpenM++, etc. si nécessaire)

**Voir** : `STATUT_INSTALLATION.md` pour les détails

---

## 🔗 Liens Utiles

- **Documentation Slurm** : https://slurm.schedmd.com/documentation.html
- **Documentation LDAP** : https://directory.fedoraproject.org/docs/
- **Documentation Kerberos** : https://web.mit.edu/kerberos/krb5-latest/doc/
- **Documentation GPFS** : IBM Spectrum Scale Administration Guide
- **Documentation Spack** : https://spack.readthedocs.io/

---

## 📝 Notes

- Tous les documents sont en français
- Niveau adapté pour étudiants Master et ingénieurs
- Exemples pratiques inclus
- Scripts de vérification fournis

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
