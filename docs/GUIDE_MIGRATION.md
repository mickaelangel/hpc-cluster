# Guide de Migration - Cluster HPC
## Migration LDAP + Kerberos ↔ FreeIPA

**Classification**: Documentation Technique  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Migration vers FreeIPA](#migration-vers-freeipa)
3. [Migration depuis FreeIPA](#migration-depuis-freeipa)
4. [Synchronisation Utilisateurs](#synchronisation-utilisateurs)
5. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Ce guide explique comment migrer entre les deux solutions d'authentification :
- **LDAP + Kerberos** → **FreeIPA**
- **FreeIPA** → **LDAP + Kerberos**
- **Synchronisation** des utilisateurs

---

## 🔄 Migration vers FreeIPA

### Prérequis

1. **LDAP + Kerberos** installés et fonctionnels
2. **FreeIPA** installé et configuré
3. **Backup** complet effectué

### Étapes

#### 1. Backup Avant Migration

```bash
# Backup complet
cd cluster\ hpc/scripts/backup
sudo ./backup-cluster.sh
```

#### 2. Migration Automatisée

```bash
# Script de migration
cd cluster\ hpc/scripts/migration
sudo ./migrate-to-freeipa.sh
```

**Configuration** :
- `LDAP_PASSWORD` : Mot de passe LDAP
- `FREEIPA_SERVER` : Serveur FreeIPA (défaut: frontal-01.cluster.local)
- `FREEIPA_ADMIN` : Admin FreeIPA (défaut: admin)
- `FREEIPA_PASSWORD` : Mot de passe admin FreeIPA

#### 3. Vérification

```bash
# Vérifier les utilisateurs dans FreeIPA
ipa user-find

# Tester l'authentification
kinit jdoe@CLUSTER.LOCAL
klist
```

#### 4. Configuration des Clients

```bash
# Sur chaque nœud de calcul
zypper install -y freeipa-client
ipa-client-install \
    --domain=cluster.local \
    --server=frontal-01.cluster.local \
    --principal=admin \
    --password=AdminPassword123! \
    --unattended
```

---

## 🔄 Migration depuis FreeIPA

### Prérequis

1. **FreeIPA** installé et fonctionnel
2. **LDAP + Kerberos** prêts à être installés
3. **Backup** complet effectué

### Étapes

#### 1. Backup FreeIPA

```bash
# Export utilisateurs FreeIPA
ipa user-find --all --raw > /backup/freeipa-users.ldif
```

#### 2. Installation LDAP + Kerberos

```bash
# Installation
cd cluster\ hpc/scripts
sudo ./install-ldap-kerberos.sh
```

#### 3. Import Utilisateurs

```bash
# Importer les utilisateurs dans LDAP
ldapadd -x -D "cn=Directory Manager" -w "DSPassword123!" \
    -f /backup/freeipa-users.ldif
```

#### 4. Création Principaux Kerberos

```bash
# Pour chaque utilisateur
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

---

## 🔗 Synchronisation Utilisateurs

### Synchronisation LDAP → Kerberos

```bash
# Script de synchronisation
cd cluster\ hpc/scripts/migration
sudo ./sync-users.sh
```

**Fonctionnalités** :
- Extraction utilisateurs LDAP
- Extraction principaux Kerberos
- Création principaux manquants
- Rapport de synchronisation

### Synchronisation Manuelle

```bash
# Lister utilisateurs LDAP
ldapsearch -x -b "ou=users,dc=cluster,dc=local" "(objectClass=posixAccount)" uid

# Créer principal Kerberos
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

---

## 🔧 Dépannage

### Problèmes de Migration

**Erreur : Utilisateur existe déjà**
```bash
# Vérifier dans FreeIPA
ipa user-show jdoe

# Supprimer si nécessaire
ipa user-del jdoe
```

**Erreur : Ticket Kerberos invalide**
```bash
# Obtenir un nouveau ticket
kdestroy
kinit admin/admin@CLUSTER.LOCAL
```

**Erreur : LDAP non accessible**
```bash
# Vérifier le service
systemctl status dirsrv@cluster

# Vérifier la connexion
ldapsearch -x -b "dc=cluster,dc=local" -s base
```

### Problèmes de Synchronisation

**Utilisateurs non synchronisés**
```bash
# Vérifier les mots de passe
# Les mots de passe doivent être identiques dans LDAP et Kerberos

# Recréer le principal
kadmin.local -q "delprinc jdoe@CLUSTER.LOCAL"
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

---

## 📚 Commandes Utiles

### FreeIPA

```bash
# Lister utilisateurs
ipa user-find

# Créer utilisateur
ipa user-add jdoe --first=John --last=Doe

# Vérifier utilisateur
ipa user-show jdoe
```

### LDAP + Kerberos

```bash
# Lister utilisateurs LDAP
ldapsearch -x -b "ou=users,dc=cluster,dc=local" "(objectClass=posixAccount)" uid

# Lister principaux Kerberos
kadmin.local -q "listprincs"
```

---

## ⚠️ Notes Importantes

1. **Backup** : Toujours faire un backup avant migration
2. **Test** : Tester sur un environnement de test d'abord
3. **Mots de passe** : Les mots de passe doivent être identiques
4. **Services** : Arrêter les services pendant la migration
5. **Validation** : Valider après chaque étape

---

## 📚 Ressources

- **FreeIPA Documentation** : https://www.freeipa.org/page/Documentation
- **LDAP Documentation** : https://directory.fedoraproject.org/docs/
- **Kerberos Documentation** : https://web.mit.edu/kerberos/krb5-latest/doc/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
