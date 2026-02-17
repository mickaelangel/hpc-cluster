# Guide d'Installation - LDAP + Kerberos Séparés
## Installation Complète sur SUSE 15 SP7

**Classification**: Documentation Technique  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 1.0 (LDAP + Kerberos)  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Installation LDAP (389 Directory Server)](#installation-ldap-389-directory-server)
4. [Installation Kerberos](#installation-kerberos)
5. [Intégration LDAP + Kerberos](#intégration-ldap--kerberos)
6. [Configuration des Clients](#configuration-des-clients)
7. [Vérification](#vérification)
8. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Ce guide explique comment installer et configurer **LDAP (389 Directory Server)** et **Kerberos** séparément sur un cluster HPC SUSE 15 SP7.

### Architecture

```
┌─────────────────────────────────────────┐
│      FRONTAL-01 (Primary)               │
│  ┌──────────┐      ┌──────────┐        │
│  │   LDAP   │      │ Kerberos │        │
│  │  (389DS) │      │   KDC    │        │
│  └──────────┘      └──────────┘        │
│       │                  │             │
│       └────────┬─────────┘             │
│         Synchronisation Manuelle        │
└─────────────────────────────────────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│Client │  │Client │  │Client │
│Node-01│  │Node-02│  │Node-06│
│(SSSD) │  │(SSSD) │  │(SSSD) │
└───────┘  └───────┘  └───────┘
```

---

## 📦 Prérequis

### Sur le Nœud Frontal (frontal-01)

- **OS** : SUSE 15 SP7 / openSUSE Leap 15.4
- **Réseau** : Nom de domaine configuré (cluster.local)
- **DNS** : Résolution de noms fonctionnelle
- **Ports** : 389 (LDAP), 636 (LDAPS), 88 (Kerberos), 749 (Kadmin)
- **Accès root** : Nécessaire pour l'installation

### Sur les Nœuds Clients

- **OS** : SUSE 15 SP7 / openSUSE Leap 15.4
- **Réseau** : Accès au serveur LDAP et Kerberos
- **SSSD** : Pour l'intégration

---

## 🔐 Installation LDAP (389 Directory Server)

### Étape 1: Installation des Packages

```bash
# Activation des modules SUSE
SUSEConnect -p PackageHub/15.7/x86_64

# Installation 389 Directory Server
zypper refresh
zypper install -y 389-ds 389-ds-base
```

### Étape 2: Configuration Initiale

```bash
# Créer le fichier de configuration
cat > /tmp/ds.inf <<EOF
[General]
FullMachineName = frontal-01.cluster.local
SuiteSpotUserID = dirsrv
SuiteSpotGroup = dirsrv
AdminDomain = cluster.local
ConfigDirectoryAdminID = admin
ConfigDirectoryAdminPwd = DSPassword123!
ConfigDirectoryLdapURL = ldap://frontal-01.cluster.local:389/o=NetscapeRoot

[slapd]
ServerPort = 389
ServerIdentifier = cluster
Suffix = dc=cluster,dc=local
RootDN = cn=Directory Manager
RootDNPwd = DSPassword123!
EOF

# Installation silencieuse
setup-ds.pl --silent --file /tmp/ds.inf

# Vérification
systemctl status dirsrv@cluster
```

### Étape 3: Configuration de Base

```bash
# Créer la structure de base
cat > /tmp/base.ldif <<EOF
dn: dc=cluster,dc=local
objectClass: top
objectClass: domain
dc: cluster

dn: ou=users,dc=cluster,dc=local
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=cluster,dc=local
objectClass: organizationalUnit
ou: groups

dn: ou=computers,dc=cluster,dc=local
objectClass: organizationalUnit
ou: computers
EOF

# Ajouter la structure
ldapadd -x -D "cn=Directory Manager" -w "DSPassword123!" -f /tmp/base.ldif
```

### Étape 4: Création d'Utilisateur Test

```bash
# Créer un utilisateur
cat > /tmp/user.ldif <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: jdoe
cn: John Doe
sn: Doe
mail: jdoe@cluster.local
userPassword: {SSHA}encrypted_password_here
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
loginShell: /bin/bash
gecos: John Doe
EOF

# Générer le hash du mot de passe
slappasswd -s "Password123!" -h {SSHA} > /tmp/password.hash
# Remplacer encrypted_password_here dans user.ldif

# Ajouter l'utilisateur
ldapadd -x -D "cn=Directory Manager" -w "DSPassword123!" -f /tmp/user.ldif
```

### Étape 5: Vérification

```bash
# Test de connexion
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Rechercher un utilisateur
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Vérifier le service
systemctl status dirsrv@cluster
```

---

## 🔑 Installation Kerberos

### Étape 1: Installation des Packages

```bash
# Installation Kerberos
zypper install -y krb5 krb5-server krb5-client
```

### Étape 2: Configuration Kerberos

```bash
# Configuration /etc/krb5.conf
cat > /etc/krb5.conf <<EOF
[libdefaults]
    default_realm = CLUSTER.LOCAL
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    default_tgs_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96
    default_tkt_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96
    permitted_enctypes = aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96

[realms]
    CLUSTER.LOCAL = {
        kdc = frontal-01.cluster.local:88
        admin_server = frontal-01.cluster.local:749
        default_domain = cluster.local
    }

[domain_realm]
    .cluster.local = CLUSTER.LOCAL
    cluster.local = CLUSTER.LOCAL

[logging]
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
EOF
```

### Étape 3: Initialisation de la Base de Données Kerberos

```bash
# Créer la base de données
kdb5_util create -s -r CLUSTER.LOCAL
# Entrer le mot de passe de la base de données (garder précieusement)

# Créer le fichier de politique par défaut
cat > /var/kerberos/krb5kdc/kadm5.acl <<EOF
*/admin@CLUSTER.LOCAL    *
EOF

# Créer le principal admin
kadmin.local -q "addprinc admin/admin@CLUSTER.LOCAL"
# Entrer le mot de passe admin

# Créer le principal pour le service KDC
kadmin.local -q "addprinc -randkey host/frontal-01.cluster.local@CLUSTER.LOCAL"
kadmin.local -q "ktadd host/frontal-01.cluster.local@CLUSTER.LOCAL"
```

### Étape 4: Démarrage des Services

```bash
# Démarrer KDC
systemctl enable krb5kdc
systemctl start krb5kdc

# Démarrer Kadmin
systemctl enable kadmin
systemctl start kadmin

# Vérification
systemctl status krb5kdc
systemctl status kadmin
```

### Étape 5: Création d'Utilisateur Kerberos

```bash
# Créer un principal utilisateur
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
# Entrer le mot de passe (doit correspondre au mot de passe LDAP)

# Vérifier
kadmin.local -q "listprincs"
```

---

## 🔗 Intégration LDAP + Kerberos

### Synchronisation des Utilisateurs

**Important** : Les utilisateurs doivent être créés dans **les deux systèmes** (LDAP et Kerberos).

#### Méthode 1: Script de Synchronisation

```bash
#!/bin/bash
# Script de synchronisation LDAP → Kerberos

LDAP_BASE="dc=cluster,dc=local"
LDAP_DN="cn=Directory Manager"
LDAP_PW="DSPassword123!"
REALM="CLUSTER.LOCAL"

# Obtenir un ticket admin
echo "AdminPassword" | kinit admin/admin@${REALM}

# Lister les utilisateurs LDAP
USERS=$(ldapsearch -x -D "${LDAP_DN}" -w "${LDAP_PW}" \
    -b "ou=users,${LDAP_BASE}" "(objectClass=posixAccount)" \
    uid | grep "^uid:" | awk '{print $2}')

# Créer les principaux Kerberos
for USER in $USERS; do
    # Vérifier si le principal existe
    if ! kadmin.local -q "getprinc ${USER}@${REALM}" 2>/dev/null; then
        echo "Création du principal ${USER}@${REALM}"
        kadmin.local -q "addprinc ${USER}@${REALM}"
    fi
done
```

#### Méthode 2: Backend LDAP pour Kerberos (Avancé)

```bash
# Installation du plugin LDAP pour Kerberos
zypper install -y krb5-kdc-ldap

# Configuration avancée (nécessite expertise)
# Voir documentation : https://web.mit.edu/kerberos/krb5-latest/doc/admin/conf_ldap.html
```

### Configuration PAM pour Authentification Unifiée

```bash
# Installation
zypper install -y pam_ldap pam_krb5

# Configuration /etc/pam.d/common-auth
cat >> /etc/pam.d/common-auth <<EOF
auth sufficient pam_krb5.so
auth sufficient pam_ldap.so
auth required pam_unix.so try_first_pass
EOF

# Configuration /etc/pam.d/common-session
cat >> /etc/pam.d/common-session <<EOF
session optional pam_krb5.so
session optional pam_ldap.so
session required pam_unix.so
EOF
```

---

## 💻 Configuration des Clients

### Installation sur les Nœuds de Calcul

```bash
# Installation SSSD (recommandé)
zypper install -y sssd sssd-ldap sssd-krb5

# Configuration /etc/sssd/sssd.conf
cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = cluster.local
config_file_version = 2
services = nss, pam, ssh

[domain/cluster.local]
id_provider = ldap
auth_provider = krb5
chpass_provider = krb5
access_provider = ldap

ldap_uri = ldap://frontal-01.cluster.local
ldap_search_base = dc=cluster,dc=local
ldap_schema = rfc2307bis
ldap_user_search_base = ou=users,dc=cluster,dc=local
ldap_group_search_base = ou=groups,dc=cluster,dc=local

krb5_realm = CLUSTER.LOCAL
krb5_server = frontal-01.cluster.local:88
krb5_kdc = frontal-01.cluster.local:88

cache_credentials = true
enumerate = false
EOF

# Permissions
chmod 600 /etc/sssd/sssd.conf

# Démarrage
systemctl enable sssd
systemctl start sssd
```

### Configuration NSS

```bash
# /etc/nsswitch.conf
cat >> /etc/nsswitch.conf <<EOF
passwd: files sss
group: files sss
shadow: files sss
EOF
```

### Configuration SSH avec Kerberos

```bash
# /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config <<EOF
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
GSSAPIKeyExchange yes
EOF

# Redémarrer SSH
systemctl restart sshd
```

---

## ✅ Vérification

### Test LDAP

```bash
# Test de connexion
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Rechercher un utilisateur
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Test d'authentification
ldapwhoami -x -D "uid=jdoe,ou=users,dc=cluster,dc=local" -w "Password123!"
```

### Test Kerberos

```bash
# Obtenir un ticket
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe

# Vérifier le ticket
klist

# Test SSH avec Kerberos
ssh jdoe@node-01
# Pas de mot de passe si ticket valide
```

### Test Intégration

```bash
# Vérifier que l'utilisateur existe dans les deux
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"
kadmin.local -q "getprinc jdoe@CLUSTER.LOCAL"

# Test d'authentification unifiée
su - jdoe
# Devrait fonctionner avec le mot de passe LDAP/Kerberos
```

---

## 🔧 Dépannage

### Problèmes LDAP

```bash
# Vérifier le service
systemctl status dirsrv@cluster

# Vérifier les logs
tail -f /var/log/dirsrv/slapd-cluster/errors
tail -f /var/log/dirsrv/slapd-cluster/access

# Test de connexion
ldapsearch -x -H ldap://frontal-01 -b "dc=cluster,dc=local" -s base
```

### Problèmes Kerberos

```bash
# Vérifier les services
systemctl status krb5kdc
systemctl status kadmin

# Vérifier les logs
tail -f /var/log/krb5kdc.log
tail -f /var/log/kadmin.log

# Test de connexion
kinit admin/admin@CLUSTER.LOCAL
klist
```

### Problèmes de Synchronisation

```bash
# Vérifier que l'utilisateur existe dans LDAP
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Vérifier que le principal existe dans Kerberos
kadmin.local -q "getprinc jdoe@CLUSTER.LOCAL"

# Si manquant, créer manuellement
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

### Problèmes Clients

```bash
# Vérifier SSSD
systemctl status sssd
sssctl user-checks jdoe

# Vérifier la configuration
sssctl config-check

# Redémarrer SSSD
systemctl restart sssd
```

---

## 📚 Commandes Utiles

### LDAP

```bash
# Rechercher
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Ajouter
ldapadd -x -D "cn=Directory Manager" -w "password" -f file.ldif

# Modifier
ldapmodify -x -D "cn=Directory Manager" -w "password" -f file.ldif

# Supprimer
ldapdelete -x -D "cn=Directory Manager" -w "password" "dn=..."
```

### Kerberos

```bash
# Obtenir un ticket
kinit jdoe@CLUSTER.LOCAL

# Vérifier
klist

# Renouveler
kinit -R

# Détruire
kdestroy

# Créer un principal
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"

# Lister les principaux
kadmin.local -q "listprincs"
```

---

## 📝 Notes Importantes

1. **Synchronisation** : Les utilisateurs doivent être créés dans LDAP ET Kerberos
2. **Mots de passe** : Doivent être identiques dans les deux systèmes
3. **UID/GID** : Doivent être identiques dans LDAP et sur les systèmes locaux
4. **Sauvegardes** : Sauvegarder régulièrement LDAP et la base Kerberos
5. **Sécurité** : Changer tous les mots de passe par défaut

---

## 📚 Ressources

- **389 Directory Server** : https://directory.fedoraproject.org/docs/
- **Kerberos** : https://web.mit.edu/kerberos/krb5-latest/doc/
- **SSSD** : https://sssd.io/

---

**Version**: 1.0 (LDAP + Kerberos)  
**Dernière mise à jour**: 2024
