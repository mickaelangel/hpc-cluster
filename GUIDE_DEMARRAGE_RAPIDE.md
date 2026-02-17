# Guide de Démarrage Rapide - Cluster HPC
## Installation et Utilisation

**Classification**: Documentation Utilisateur  
**Version**: 1.0  
**Date**: 2024

---

## 🎯 Choix de la Version

Le projet propose **deux versions** d'authentification :

### Version 1 : LDAP + Kerberos Séparés

**Pour qui** : Administrateurs expérimentés, besoin de contrôle total

**Installation** :
```bash
cd cluster\ hpc
sudo ./scripts/install-ldap-kerberos.sh
```

**Documentation** :
- `docs/GUIDE_INSTALLATION_LDAP_KERBEROS.md` - Guide d'installation
- `docs/GUIDE_AUTHENTIFICATION.md` - Guide d'utilisation
- `docs/TECHNOLOGIES_CLUSTER.md` - Technologies

### Version 2 : FreeIPA

**Pour qui** : Solution simple et unifiée, interface web

**Installation** :
```bash
cd cluster\ hpc
sudo ./scripts/install-freeipa.sh
```

**Documentation** :
- `docs/TECHNOLOGIES_CLUSTER_FREEIPA.md` - Guide d'installation
- `docs/GUIDE_AUTHENTIFICATION_FREEIPA.md` - Guide d'utilisation
- `docs/README_FREEIPA.md` - Guide rapide

---

## 🚀 Installation Rapide - LDAP + Kerberos

### Étape 1 : Installation Automatisée

```bash
# Sur le nœud frontal (frontal-01)
cd cluster\ hpc/scripts
sudo ./install-ldap-kerberos.sh
```

### Étape 2 : Vérification

```bash
# Vérifier LDAP
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Vérifier Kerberos
systemctl status krb5kdc
kinit jdoe@CLUSTER.LOCAL
klist
```

### Étape 3 : Configuration des Clients

```bash
# Sur chaque nœud de calcul
zypper install -y sssd sssd-ldap sssd-krb5

# Configuration (voir docs/GUIDE_AUTHENTIFICATION.md)
# /etc/sssd/sssd.conf

systemctl enable sssd
systemctl start sssd
```

---

## 📚 Documentation Complète

### Pour LDAP + Kerberos

1. **Installation** : `docs/GUIDE_INSTALLATION_LDAP_KERBEROS.md`
2. **Authentification** : `docs/GUIDE_AUTHENTIFICATION.md`
3. **Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS.md`
4. **Maintenance** : `docs/GUIDE_MAINTENANCE.md`
5. **Technologies** : `docs/TECHNOLOGIES_CLUSTER.md`

### Pour FreeIPA

1. **Installation** : `docs/TECHNOLOGIES_CLUSTER_FREEIPA.md`
2. **Authentification** : `docs/GUIDE_AUTHENTIFICATION_FREEIPA.md`
3. **Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS_FREEIPA.md`
4. **Maintenance** : `docs/GUIDE_MAINTENANCE_FREEIPA.md`
5. **Guide Rapide** : `docs/README_FREEIPA.md`

---

## ✅ Vérification : Peut-on Lancer des Jobs ?

### Avec LDAP + Kerberos : ✅ OUI

```bash
# 1. Authentification
kinit jdoe@CLUSTER.LOCAL

# 2. Connexion SSH (SSO)
ssh jdoe@node-01

# 3. Soumettre un job
sbatch myjob.sh
```

### Avec FreeIPA : ✅ OUI

```bash
# 1. Authentification
kinit jdoe@CLUSTER.LOCAL

# 2. Connexion SSH (SSO)
ssh jdoe@node-01

# 3. Soumettre un job
sbatch myjob.sh
```

**Les deux versions permettent de lancer des jobs !**

---

## 📖 Comparaison Rapide

| Aspect | LDAP + Kerberos | FreeIPA |
|--------|----------------|---------|
| **Installation** | 2 services | 1 service |
| **Interface Web** | ❌ Non | ✅ Oui |
| **Complexité** | ⚠️ Élevée | ✅ Faible |
| **Synchronisation** | ⚠️ Manuelle | ✅ Automatique |
| **Documentation** | ✅ Complète | ✅ Complète |

---

## 🔗 Liens Utiles

- **Guide des Versions** : `README_VERSIONS.md`
- **Index Documentation LDAP+Kerberos** : `docs/INDEX_DOCUMENTATION.md`
- **Index Documentation FreeIPA** : `docs/INDEX_DOCUMENTATION_FREEIPA.md`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
