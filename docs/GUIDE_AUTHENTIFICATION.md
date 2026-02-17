# Guide d'Authentification - LDAP, Kerberos, FreeIPA
## Configuration et Utilisation

**Classification**: Documentation Technique  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 1.0

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [LDAP (389 Directory Server)](#ldap-389-directory-server)
3. [Kerberos](#kerberos)
4. [Intégration LDAP + Kerberos](#intégration-ldap--kerberos)
5. [FreeIPA (Alternative)](#freeipa-alternative)
6. [Configuration des Clients](#configuration-des-clients)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Le cluster utilise une authentification centralisée pour :
- **Sécurité** : Un seul point de contrôle
- **Simplicité** : Pas de gestion d'utilisateurs sur chaque nœud
- **SSO** : Authentification unique (Single Sign-On)
- **Audit** : Traçabilité centralisée

### Architecture d'Authentification

```
┌─────────────────────────────────────────┐
│         FRONTAL-01 (Primary)            │
│  ┌──────────┐      ┌──────────┐        │
│  │   LDAP   │◄────►│ Kerberos │        │
│  │  (389DS) │      │   KDC    │        │
│  └──────────┘      └──────────┘        │
│       │                  │             │
│       └────────┬─────────┘             │
│                │                        │
│         Intégration GSSAPI              │
└─────────────────────────────────────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│Client │  │Client │  │Client │
│Node-01│  │Node-02│  │Node-06│
└───────┘  └───────┘  └───────┘
```

---

## 📁 LDAP (389 Directory Server)

### Installation

```bash
# Installation
zypper install -y 389-ds 389-ds-base

# Configuration initiale
setup-ds.pl --silent --file /path/to/inf.conf
```

### Structure de l'Annuaire

```
dc=cluster,dc=local
│
├── ou=users
│   ├── uid=jdoe,ou=users,dc=cluster,dc=local
│   │   ├── uidNumber: 1001
│   │   ├── gidNumber: 1001
│   │   ├── homeDirectory: /home/jdoe
│   │   ├── loginShell: /bin/bash
│   │   └── userPassword: {SSHA}...
│   └── uid=asmith,ou=users,dc=cluster,dc=local
│
├── ou=groups
│   ├── cn=hpc-users,ou=groups,dc=cluster,dc=local
│   │   ├── memberUid: jdoe
│   │   └── memberUid: asmith
│   └── cn=admins,ou=groups,dc=cluster,dc=local
│
└── ou=computers
    ├── cn=node-01,ou=computers,dc=cluster,dc=local
    └── cn=node-02,ou=computers,dc=cluster,dc=local
```

### Opérations Courantes

#### Créer un Utilisateur

```bash
ldapadd -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: jdoe
cn: John Doe
sn: Doe
mail: jdoe@cluster.local
userPassword: {SSHA}encrypted_password
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
loginShell: /bin/bash
gecos: John Doe
EOF
```

#### Modifier un Utilisateur

```bash
ldapmodify -x -D "cn=Directory Manager" -w "password" <<EOF
dn: uid=jdoe,ou=users,dc=cluster,dc=local
changetype: modify
replace: mail
mail: john.doe@cluster.local
EOF
```

#### Supprimer un Utilisateur

```bash
ldapdelete -x -D "cn=Directory Manager" -w "password" \
    uid=jdoe,ou=users,dc=cluster,dc=local
```

#### Rechercher

```bash
# Rechercher un utilisateur
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Lister tous les utilisateurs
ldapsearch -x -b "ou=users,dc=cluster,dc=local"
```

### Configuration PAM pour LDAP

```bash
# Installation
zypper install -y pam_ldap nss_ldap

# Configuration /etc/ldap.conf
host frontal-01
base dc=cluster,dc=local
ldap_version 3
binddn cn=Directory Manager
bindpw password
```

---

## 🔐 Kerberos

### Installation

```bash
# Installation
zypper install -y krb5 krb5-server krb5-client

# Configuration /etc/krb5.conf
[libdefaults]
    default_realm = CLUSTER.LOCAL
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    CLUSTER.LOCAL = {
        kdc = frontal-01.cluster.local:88
        admin_server = frontal-01.cluster.local:749
        default_domain = cluster.local
    }

[domain_realm]
    .cluster.local = CLUSTER.LOCAL
    cluster.local = CLUSTER.LOCAL
```

### Initialisation KDC

```bash
# Créer la base de données
kdb5_util create -s

# Créer un principal admin
kadmin.local -q "addprinc admin/admin@CLUSTER.LOCAL"
```

### Opérations Courantes

#### Créer un Principal

```bash
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

#### Obtenir un Ticket

```bash
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe
```

#### Vérifier le Ticket

```bash
klist
```

#### Renouveler un Ticket

```bash
kinit -R
```

#### Détruire les Tickets

```bash
kdestroy
```

### Configuration SSH avec Kerberos

```bash
# /etc/ssh/sshd_config
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
GSSAPIKeyExchange yes

# Redémarrer SSH
systemctl restart sshd
```

---

## 🔗 Intégration LDAP + Kerberos

### Synchronisation LDAP ↔ Kerberos

Les utilisateurs peuvent être créés dans LDAP et synchronisés avec Kerberos, ou vice versa.

#### Méthode 1: LDAP comme Source de Vérité

```bash
# Créer utilisateur dans LDAP
ldapadd ... uid=jdoe ...

# Créer principal Kerberos correspondant
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
```

#### Méthode 2: Kerberos avec Backend LDAP

Configuration avancée avec `kdb5_ldap_plugin`.

### Authentification Unifiée

Avec l'intégration, un utilisateur peut :
1. Se connecter avec son mot de passe LDAP
2. Obtenir automatiquement un ticket Kerberos
3. Utiliser le ticket pour SSH, NFS, etc. sans mot de passe

---

## 🆓 FreeIPA (Alternative)

### Pourquoi FreeIPA ?

FreeIPA combine LDAP + Kerberos + DNS + PKI en une seule solution.

### Installation

```bash
# Via Docker (recommandé)
docker run -d --name freeipa \
    -h ipa.cluster.local \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --tmpfs /run --tmpfs /tmp \
    -v /var/lib/ipa-data:/data:Z \
    freeipa/freeipa-server:centos-8-stream \
    ipa-server-install -U \
    -r CLUSTER.LOCAL \
    -n cluster.local \
    -p 'AdminPassword' \
    --admin-password 'AdminPassword'
```

### Interface Web

Accès : `https://ipa.cluster.local`

### Création d'Utilisateur via Interface

1. Se connecter à l'interface web
2. Identity > Users > Add
3. Remplir les informations
4. L'utilisateur est automatiquement créé dans LDAP et Kerberos

---

## 💻 Configuration des Clients

### Configuration sur les Nœuds de Calcul

```bash
# Installation
zypper install -y sssd sssd-ldap sssd-krb5

# Configuration /etc/sssd/sssd.conf
[sssd]
domains = cluster.local
config_file_version = 2

[domain/cluster.local]
id_provider = ldap
auth_provider = krb5
ldap_uri = ldap://frontal-01
ldap_search_base = dc=cluster,dc=local
krb5_realm = CLUSTER.LOCAL
krb5_kdc = frontal-01.cluster.local:88
```

### Configuration PAM

```bash
# /etc/pam.d/common-auth
auth sufficient pam_sss.so
auth required pam_unix.so try_first_pass
```

### Configuration NSS

```bash
# /etc/nsswitch.conf
passwd: files sss
group: files sss
shadow: files sss
```

---

## 🔧 Dépannage

### Problèmes LDAP

**Test de connexion** :
```bash
ldapsearch -x -H ldap://frontal-01 -b "dc=cluster,dc=local" -s base
```

**Vérifier le service** :
```bash
systemctl status dirsrv@cluster
```

**Logs** :
```bash
tail -f /var/log/dirsrv/slapd-cluster/errors
```

### Problèmes Kerberos

**Test de connexion** :
```bash
kinit jdoe@CLUSTER.LOCAL
klist
```

**Vérifier le service** :
```bash
systemctl status krb5kdc
```

**Logs** :
```bash
tail -f /var/log/krb5kdc.log
```

### Problèmes d'Intégration

**Vérifier la synchronisation** :
```bash
# Utilisateur existe dans LDAP ?
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"

# Principal existe dans Kerberos ?
kadmin.local -q "getprinc jdoe@CLUSTER.LOCAL"
```

---

## 📚 Ressources

- **389 Directory Server**: https://directory.fedoraproject.org/docs/
- **Kerberos**: https://web.mit.edu/kerberos/krb5-latest/doc/
- **FreeIPA**: https://www.freeipa.org/page/Documentation

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
