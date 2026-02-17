# Documentation Cluster HPC avec FreeIPA
## Guide Complet - Version FreeIPA

**Classification**: Documentation Technique  
**Version**: 2.0 (FreeIPA)  
**Date**: 2024

---

## 🎯 Vue d'ensemble

Cette documentation couvre le cluster HPC avec **FreeIPA** comme solution d'authentification unifiée. FreeIPA remplace la configuration LDAP + Kerberos séparés par une solution enterprise intégrée.

---

## 📚 Documentation Disponible

### Documentation Principale

1. **`TECHNOLOGIES_CLUSTER_FREEIPA.md`**
   - Vue d'ensemble de toutes les technologies
   - FreeIPA : Installation, configuration, utilisation
   - Nexus, Spack, Exceed TurboX, Slurm, GPFS, Monitoring

2. **`GUIDE_AUTHENTIFICATION_FREEIPA.md`**
   - Guide complet FreeIPA
   - Installation serveur et clients
   - Gestion utilisateurs, groupes, politiques
   - DNS intégré, PKI, dépannage

3. **`GUIDE_LANCEMENT_JOBS_FREEIPA.md`**
   - Guide pratique pour lancer des jobs
   - Authentification FreeIPA
   - Jobs Slurm, MATLAB, OpenM++
   - Applications graphiques avec Exceed TurboX

4. **`GUIDE_MAINTENANCE_FREEIPA.md`**
   - Procédures de maintenance
   - Maintenance FreeIPA spécifique
   - Sauvegardes, mises à jour, dépannage

5. **`STATUT_INSTALLATION_FREEIPA.md`**
   - État des composants installés
   - Vérification fonctionnelle
   - Comparaison LDAP+Kerberos vs FreeIPA

6. **`INDEX_DOCUMENTATION_FREEIPA.md`**
   - Index complet de la documentation
   - Parcours d'apprentissage
   - Liens utiles

---

## 🔐 FreeIPA - Solution d'Authentification Unifiée

### Qu'est-ce que FreeIPA ?

FreeIPA combine :
- **LDAP** (389 Directory Server) : Annuaire centralisé
- **Kerberos** : Authentification sécurisée
- **DNS** : Résolution de noms intégrée
- **PKI** : Infrastructure à clés publiques
- **Gestion des politiques** : Contrôle d'accès centralisé
- **Interface Web** : Administration graphique

### Avantages

✅ **Solution unifiée** : 1 service au lieu de 2 (LDAP + Kerberos)  
✅ **Interface web** : Administration facile  
✅ **Synchronisation automatique** : LDAP ↔ Kerberos  
✅ **DNS intégré** : Résolution de noms automatique  
✅ **PKI intégrée** : Certificats SSL/TLS automatiques  
✅ **Enterprise-ready** : Solution robuste pour production

### Installation Rapide

```bash
# Script d'installation automatisé
cd cluster\ hpc/scripts
sudo ./install-freeipa.sh
```

Ou via Docker :
```bash
docker run -d --name freeipa-server \
    -h ipa.cluster.local \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --tmpfs /run --tmpfs /tmp \
    -v /var/lib/ipa-data:/data:Z \
    -p 80:80 -p 443:443 \
    -p 389:389 -p 636:636 \
    -p 88:88 -p 464:464 \
    -p 53:53/udp -p 53:53 \
    freeipa/freeipa-server:centos-8-stream \
    ipa-server-install -U \
    -r CLUSTER.LOCAL \
    -n cluster.local \
    -p 'AdminPassword123!' \
    --admin-password 'AdminPassword123!' \
    --setup-dns \
    --no-ntp
```

### Accès Interface Web

- **URL** : `https://ipa.cluster.local` ou `https://frontal-01`
- **Login** : `admin`
- **Password** : Mot de passe défini lors de l'installation

---

## ✅ État d'Installation

### Composants Installés

| Composant | Statut | Notes |
|----------|--------|-------|
| **FreeIPA Server** | ✅ Installé | Sur frontal-01 |
| **FreeIPA Clients** | ✅ Installé | Sur tous les nœuds |
| **Nexus Repository** | ✅ Installé | PyPI mirror |
| **Spack** | ✅ Installé | Packages scientifiques |
| **Exceed TurboX** | ✅ Installé | Remote graphics |
| **Slurm** | ✅ Installé | Scheduler |
| **GPFS** | ✅ Installé | Stockage partagé |
| **Monitoring** | ✅ Installé | Prometheus, Grafana, etc. |

### Peut-on Lancer des Jobs ?

**✅ OUI** - Tous les composants sont fonctionnels avec FreeIPA.

**Prérequis** :
1. Compte FreeIPA valide
2. Ticket Kerberos (obtenu via `kinit`)
3. Accès SSH aux nœuds (SSO automatique si ticket valide)
4. Quota GPFS disponible
5. Applications installées (MATLAB, OpenM++, etc.)

---

## 🚀 Démarrage Rapide

### 1. Authentification

```bash
# Obtenir un ticket FreeIPA
kinit jdoe@CLUSTER.LOCAL
# Entrer votre mot de passe

# Vérifier
klist
```

### 2. Connexion SSH (SSO)

```bash
# Connexion sans mot de passe (si ticket valide)
ssh jdoe@node-01
```

### 3. Soumission de Job

```bash
# Créer un script job
cat > myjob.sh <<EOF
#!/bin/bash
#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00

echo "Hello from job \$SLURM_JOB_ID"
EOF

# Soumettre
sbatch myjob.sh

# Vérifier
squeue -u $USER
```

---

## 📖 Parcours d'Apprentissage

### Pour un Étudiant Master

1. `STATUT_INSTALLATION_FREEIPA.md` - Comprendre ce qui est installé
2. `GUIDE_LANCEMENT_JOBS_FREEIPA.md` - Apprendre à lancer des jobs
3. `TECHNOLOGIES_CLUSTER_FREEIPA.md` - Comprendre les outils
4. `GUIDE_AUTHENTIFICATION_FREEIPA.md` - Comprendre FreeIPA

### Pour un Ingénieur

1. `TECHNOLOGIES_CLUSTER_FREEIPA.md` - Vue d'ensemble technique
2. `GUIDE_AUTHENTIFICATION_FREEIPA.md` - Configuration FreeIPA
3. `GUIDE_MAINTENANCE_FREEIPA.md` - Maintenance opérationnelle
4. `STATUT_INSTALLATION_FREEIPA.md` - Vérification complète

### Pour un Administrateur

1. `GUIDE_MAINTENANCE_FREEIPA.md` - Procédures opérationnelles
2. `GUIDE_AUTHENTIFICATION_FREEIPA.md` - Configuration avancée
3. `TECHNOLOGIES_CLUSTER_FREEIPA.md` - Architecture détaillée
4. `STATUT_INSTALLATION_FREEIPA.md` - Scripts de vérification

---

## 🔗 Liens Utiles

- **FreeIPA Documentation** : https://www.freeipa.org/page/Documentation
- **FreeIPA User Guide** : https://www.freeipa.org/page/Documentation
- **FreeIPA API** : https://www.freeipa.org/page/API
- **Slurm** : https://slurm.schedmd.com/documentation.html
- **GPFS** : IBM Spectrum Scale Administration Guide

---

## 📝 Notes Importantes

1. **FreeIPA remplace LDAP + Kerberos séparés** pour une solution plus simple
2. **Interface web** : Administration via navigateur
3. **SSO automatique** : Pas besoin de mot de passe pour SSH si ticket valide
4. **Synchronisation automatique** : LDAP ↔ Kerberos géré automatiquement
5. **DNS intégré** : Résolution de noms pour le domaine
6. **PKI intégrée** : Certificats SSL/TLS automatiques

---

**Version**: 2.0 (FreeIPA)  
**Dernière mise à jour**: 2024
