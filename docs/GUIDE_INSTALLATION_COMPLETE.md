# Guide d'Installation Complète - Cluster HPC
## Installation Step-by-Step avec LDAP + Kerberos

**Classification**: Documentation Technique  
**Public**: Administrateurs Système / Ingénieurs  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Préparation](#préparation)
3. [Installation LDAP](#installation-ldap)
4. [Installation Kerberos](#installation-kerberos)
5. [Intégration LDAP + Kerberos](#intégration-ldap--kerberos)
6. [Configuration des Clients](#configuration-des-clients)
7. [Installation des Autres Services](#installation-des-autres-services)
8. [Vérification Complète](#vérification-complète)

---

## 🎯 Vue d'ensemble

Ce guide explique comment installer un cluster HPC complet sur openSUSE 15.6 avec :
- **LDAP (389 Directory Server)** : Authentification centralisée
- **Kerberos** : Authentification sécurisée
- **Slurm** : Scheduler de jobs
- **GPFS** : Stockage partagé
- **Monitoring** : Prometheus, Grafana, Telegraf
- **Nexus** : Repository PyPI
- **Spack** : Gestionnaire de packages
- **Exceed TurboX** : Remote graphics

---

## 📦 Préparation

### Prérequis Système

**Sur le nœud frontal (frontal-01)** :
- openSUSE 15.6 ou openSUSE Leap 15.6
- 4+ CPU, 16GB+ RAM, 100GB+ disque
- Accès root
- Connexion réseau configurée

**Sur les nœuds de calcul** :
- openSUSE 15.6 ou openSUSE Leap 15.6
- 2+ CPU, 8GB+ RAM, 50GB+ disque
- Accès root
- Connexion réseau vers frontal-01

### Configuration Réseau

```bash
# Sur frontal-01
hostname frontal-01.cluster.local
echo "192.168.100.10  frontal-01.cluster.local  frontal-01" >> /etc/hosts
echo "192.168.100.11  frontal-02.cluster.local  frontal-02" >> /etc/hosts

# Sur chaque nœud de calcul
hostname node-01.cluster.local
echo "192.168.100.10  frontal-01.cluster.local  frontal-01" >> /etc/hosts
```

---

## 🔐 Installation LDAP (389 Directory Server)

### Étape 1: Installation

```bash
# Sur openSUSE 15.6 : dépôts standards (pas de SUSEConnect)
# Installation
zypper refresh
zypper install -y 389-ds 389-ds-base
```

### Étape 2: Configuration Initiale

```bash
# Créer le fichier de configuration
cat > /tmp/ds.inf <<'EOF'
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

# Démarrage
systemctl enable dirsrv@cluster
systemctl start dirsrv@cluster
```

### Étape 3: Création de la Structure

```bash
# Créer la structure de base
cat > /tmp/base.ldif <<'EOF'
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

### Étape 4: Création d'Utilisateurs

```bash
# Générer le hash du mot de passe
PASSWORD_HASH=$(slappasswd -s "UserPassword123!" -h {SSHA})

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
userPassword: ${PASSWORD_HASH}
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jdoe
loginShell: /bin/bash
gecos: John Doe
EOF

ldapadd -x -D "cn=Directory Manager" -w "DSPassword123!" -f /tmp/user.ldif
```

### Étape 5: Vérification

```bash
# Test de connexion
ldapsearch -x -b "dc=cluster,dc=local" -s base

# Rechercher un utilisateur
ldapsearch -x -b "dc=cluster,dc=local" "(uid=jdoe)"
```

---

## 🔑 Installation Kerberos

### Étape 1: Installation

```bash
zypper install -y krb5 krb5-server krb5-client
```

### Étape 2: Configuration

```bash
# Configuration /etc/krb5.conf
cat > /etc/krb5.conf <<'EOF'
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

[logging]
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
EOF
```

### Étape 3: Initialisation KDC

```bash
# Créer la base de données
kdb5_util create -s -r CLUSTER.LOCAL
# Entrer le mot de passe de la base (garder précieusement)

# Créer le fichier ACL
cat > /var/kerberos/krb5kdc/kadm5.acl <<'EOF'
*/admin@CLUSTER.LOCAL    *
EOF

# Créer le principal admin
kadmin.local -q "addprinc admin/admin@CLUSTER.LOCAL"
# Entrer le mot de passe admin

# Créer le principal host
kadmin.local -q "addprinc -randkey host/frontal-01.cluster.local@CLUSTER.LOCAL"
kadmin.local -q "ktadd host/frontal-01.cluster.local@CLUSTER.LOCAL"
```

### Étape 4: Démarrage

```bash
systemctl enable krb5kdc
systemctl start krb5kdc

systemctl enable kadmin
systemctl start kadmin
```

### Étape 5: Création d'Utilisateur Kerberos

```bash
# Créer un principal (même mot de passe que LDAP)
kadmin.local -q "addprinc jdoe@CLUSTER.LOCAL"
# Entrer le mot de passe (identique à celui de LDAP)

# Vérifier
kadmin.local -q "listprincs"
```

---

## 🔗 Intégration LDAP + Kerberos

### Synchronisation des Utilisateurs

**Important** : Les utilisateurs doivent être créés dans **les deux systèmes**.

```bash
#!/bin/bash
# Script de synchronisation LDAP → Kerberos

LDAP_BASE="dc=cluster,dc=local"
LDAP_DN="cn=Directory Manager"
LDAP_PW="DSPassword123!"
REALM="CLUSTER.LOCAL"

# Obtenir un ticket admin
echo "AdminPassword123!" | kinit admin/admin@${REALM}

# Lister les utilisateurs LDAP
USERS=$(ldapsearch -x -D "${LDAP_DN}" -w "${LDAP_PW}" \
    -b "ou=users,${LDAP_BASE}" "(objectClass=posixAccount)" \
    uid | grep "^uid:" | awk '{print $2}')

# Créer les principaux Kerberos
for USER in $USERS; do
    if ! kadmin.local -q "getprinc ${USER}@${REALM}" 2>/dev/null; then
        echo "Création du principal ${USER}@${REALM}"
        kadmin.local -q "addprinc ${USER}@${REALM}"
    fi
done
```

### Configuration PAM

```bash
# Installation
zypper install -y pam_ldap pam_krb5

# Configuration /etc/pam.d/common-auth
cat >> /etc/pam.d/common-auth <<'EOF'
auth sufficient pam_krb5.so
auth sufficient pam_ldap.so
auth required pam_unix.so try_first_pass
EOF
```

---

## 💻 Configuration des Clients

### Installation SSSD

```bash
# Sur chaque nœud de calcul
zypper install -y sssd sssd-ldap sssd-krb5

# Configuration /etc/sssd/sssd.conf
cat > /etc/sssd/sssd.conf <<'EOF'
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
cat >> /etc/nsswitch.conf <<'EOF'
passwd: files sss
group: files sss
shadow: files sss
EOF
```

### Configuration SSH

```bash
# /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config <<'EOF'
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
GSSAPIKeyExchange yes
EOF

systemctl restart sshd
```

---

## ⚡ Installation des Autres Services

### Slurm

```bash
# Installation
zypper install -y slurm slurm-slurmctld slurm-slurmdbd slurm-slurmd munge

# Configuration (voir documentation Slurm)
# /etc/slurm/slurm.conf
# /etc/slurm/cgroup.conf

# Démarrage
systemctl enable slurmctld
systemctl start slurmctld
```

### GPFS

Voir documentation dans `gpfs/README.md`

### Monitoring

Voir documentation dans `monitoring/README.md`

### Nexus

```bash
# Installation via Docker
docker run -d --name nexus \
    -p 8081:8081 \
    -v nexus-data:/nexus-data \
    sonatype/nexus3
```

### Spack

```bash
git clone https://github.com/spack/spack.git /opt/spack
. /opt/spack/share/spack/setup-env.sh
spack compiler find
```

---

## ✅ Vérification Complète

### Script de Vérification

```bash
#!/bin/bash
echo "=== Vérification Cluster HPC ==="

# LDAP
echo "LDAP:"
ldapsearch -x -b "dc=cluster,dc=local" -s base > /dev/null 2>&1
[ $? -eq 0 ] && echo "  ✅ LDAP fonctionnel" || echo "  ❌ LDAP non accessible"

# Kerberos
echo "Kerberos:"
systemctl is-active krb5kdc > /dev/null 2>&1
[ $? -eq 0 ] && echo "  ✅ Kerberos actif" || echo "  ❌ Kerberos inactif"

# Test d'authentification
echo "Test authentification:"
echo "UserPassword123!" | kinit jdoe@CLUSTER.LOCAL > /dev/null 2>&1
[ $? -eq 0 ] && echo "  ✅ Authentification fonctionnelle" || echo "  ❌ Authentification échouée"

# Slurm
echo "Slurm:"
scontrol ping > /dev/null 2>&1
[ $? -eq 0 ] && echo "  ✅ Slurm fonctionnel" || echo "  ❌ Slurm non accessible"

# GPFS
echo "GPFS:"
mmgetstate -a > /dev/null 2>&1
[ $? -eq 0 ] && echo "  ✅ GPFS actif" || echo "  ❌ GPFS inactif"
```

---

## 📚 Documentation Complémentaire

- **Installation LDAP + Kerberos** : `docs/GUIDE_INSTALLATION_LDAP_KERBEROS.md`
- **Guide Authentification** : `docs/GUIDE_AUTHENTIFICATION.md`
- **Guide Lancement Jobs** : `docs/GUIDE_LANCEMENT_JOBS.md`
- **Guide Maintenance** : `docs/GUIDE_MAINTENANCE.md`

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
