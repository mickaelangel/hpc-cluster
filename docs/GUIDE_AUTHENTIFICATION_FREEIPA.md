# Guide d'Authentification - FreeIPA
## Configuration et Utilisation Complète

**Classification**: Documentation Technique  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 2.0 (FreeIPA)

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Installation FreeIPA](#installation-freeipa)
3. [Configuration Initiale](#configuration-initiale)
4. [Gestion des Utilisateurs](#gestion-des-utilisateurs)
5. [Gestion des Groupes](#gestion-des-groupes)
6. [Gestion des Politiques](#gestion-des-politiques)
7. [Configuration des Clients](#configuration-des-clients)
8. [DNS Intégré](#dns-intégré)
9. [PKI et Certificats](#pki-et-certificats)
10. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

FreeIPA fournit une solution d'authentification unifiée qui combine :
- **LDAP** : Annuaire centralisé
- **Kerberos** : Authentification sécurisée
- **DNS** : Résolution de noms
- **PKI** : Infrastructure à clés publiques
- **Politiques** : Contrôle d'accès

### Architecture FreeIPA

```
┌─────────────────────────────────────────┐
│      FREEIPA SERVER (frontal-01)        │
│  ┌──────────┐  ┌──────────┐            │
│  │   LDAP   │◄─┤ Kerberos │            │
│  │  (389DS) │  │   KDC    │            │
│  └──────────┘  └──────────┘            │
│  ┌──────────┐  ┌──────────┐            │
│  │   DNS    │  │   PKI    │            │
│  │  Server  │  │    CA    │            │
│  └──────────┘  └──────────┘            │
│  ┌──────────────────────────────────┐   │
│  │      Web UI (Port 443)           │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│Client │  │Client │  │Client │
│Node-01│  │Node-02│  │Node-06│
│(IPA   │  │(IPA   │  │(IPA   │
│Client)│  │Client)│  │Client)│
└───────┘  └───────┘  └───────┘
```

---

## 🚀 Installation FreeIPA

### Prérequis

- **OS** : openSUSE 15.6 / CentOS 8+ / RHEL 8+
- **Réseau** : Nom de domaine configuré (cluster.local)
- **DNS** : Résolution de noms fonctionnelle
- **Ports** : 80, 443, 389, 636, 88, 464, 53

### Installation sur Serveur (frontal-01)

#### Méthode 1 : Docker (Recommandé pour simulation)

```bash
# Créer le conteneur FreeIPA
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
    --ds-password 'DSPassword123!' \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --no-ntp
```

#### Méthode 2 : Installation Native

```bash
# Sur openSUSE 15.6
zypper addrepo https://download.opensuse.org/repositories/security:/SELinux/openSUSE_Leap_15.6/security:SELinux.repo
zypper refresh
zypper install -y freeipa-server freeipa-server-dns

# Installation interactive
ipa-server-install

# Ou installation non-interactive
ipa-server-install \
    --realm=CLUSTER.LOCAL \
    --domain=cluster.local \
    --ds-password='DSPassword123!' \
    --admin-password='AdminPassword123!' \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --no-ntp \
    --unattended
```

### Vérification de l'Installation

```bash
# Vérifier l'état
systemctl status ipa

# Test de connectivité
ipa ping

# Vérifier la configuration
ipa env
```

---

## ⚙️ Configuration Initiale

### Accès à l'Interface Web

1. **URL** : `https://ipa.cluster.local` ou `https://frontal-01`
2. **Login** : `admin`
3. **Password** : Mot de passe défini lors de l'installation
4. **Certificat** : Accepter le certificat auto-signé

### Configuration via CLI

```bash
# Se connecter en tant qu'admin
kinit admin@CLUSTER.LOCAL
# Entrer le mot de passe admin

# Vérifier la connexion
ipa user-find admin
```

---

## 👥 Gestion des Utilisateurs

### Création d'Utilisateur via Interface Web

1. Se connecter à `https://ipa.cluster.local`
2. **Identity** > **Users** > **Add**
3. Remplir :
   - **Username** : jdoe
   - **First name** : John
   - **Last name** : Doe
   - **Email** : jdoe@cluster.local
   - **Password** : Définir ou générer
4. **Add**

### Création d'Utilisateur via CLI

```bash
# Créer un utilisateur
ipa user-add jdoe \
    --first=John \
    --last=Doe \
    --email=jdoe@cluster.local \
    --password

# Créer avec mot de passe temporaire
ipa user-add jdoe \
    --first=John \
    --last=Doe \
    --random

# Afficher le mot de passe généré
ipa user-show jdoe --all
```

### Modification d'Utilisateur

```bash
# Modifier les informations
ipa user-mod jdoe \
    --email=john.doe@cluster.local \
    --title="Research Scientist"

# Changer le mot de passe
ipa user-mod jdoe --password

# Réinitialiser le mot de passe
ipa user-mod jdoe --random
```

### Suppression d'Utilisateur

```bash
# Supprimer un utilisateur
ipa user-del jdoe

# Supprimer avec confirmation
ipa user-del jdoe --continue
```

### Recherche d'Utilisateurs

```bash
# Lister tous les utilisateurs
ipa user-find

# Rechercher un utilisateur spécifique
ipa user-find jdoe

# Recherche avancée
ipa user-find --email=*@cluster.local
```

---

## 👨‍👩‍👧‍👦 Gestion des Groupes

### Création de Groupe

```bash
# Créer un groupe
ipa group-add hpc-users \
    --desc="HPC Users Group"

# Créer un groupe avec GID spécifique
ipa group-add admins \
    --desc="Administrators" \
    --gid=1000
```

### Ajout d'Utilisateurs à un Groupe

```bash
# Ajouter un utilisateur
ipa group-add-member hpc-users --users=jdoe

# Ajouter plusieurs utilisateurs
ipa group-add-member hpc-users \
    --users=jdoe,asmith,mgarcia

# Ajouter un groupe à un autre groupe
ipa group-add-member admins --groups=hpc-users
```

### Gestion des Permissions

```bash
# Créer une permission
ipa permission-add "Manage Users" \
    --permissions=write \
    --attrs=userPassword,uid,mail

# Créer un rôle
ipa role-add "User Administrator" \
    --desc="Can manage users"

# Ajouter une permission à un rôle
ipa role-add-permission "User Administrator" \
    --permissions="Manage Users"
```

---

## 🔒 Gestion des Politiques

### Politiques de Mot de Passe

```bash
# Créer une politique globale
ipa pwpolicy-add global_policy \
    --maxlife=90 \
    --minlife=1 \
    --history=12 \
    --minclasses=4 \
    --minlength=12

# Créer une politique pour un groupe
ipa pwpolicy-add hpc-users \
    --maxlife=180 \
    --minlife=1 \
    --history=6 \
    --minclasses=3 \
    --minlength=8

# Afficher les politiques
ipa pwpolicy-show global_policy
```

### Politiques d'Accès

```bash
# Créer une règle d'accès SSH
ipa hbacrule-add "Allow HPC Users SSH" \
    --desc="Allow HPC users to SSH"

# Ajouter des utilisateurs
ipa hbacrule-add-user "Allow HPC Users SSH" \
    --groups=hpc-users

# Ajouter des services
ipa hbacrule-add-service "Allow HPC Users SSH" \
    --hbacsvcs=sshd
```

---

## 💻 Configuration des Clients

### Installation Client sur Nœuds de Calcul

```bash
# Installation
zypper install -y freeipa-client

# Configuration interactive
ipa-client-install

# Configuration non-interactive
ipa-client-install \
    --domain=cluster.local \
    --server=ipa.cluster.local \
    --realm=CLUSTER.LOCAL \
    --principal=admin \
    --password='AdminPassword123!' \
    --enable-dns-updates \
    --mkhomedir \
    --no-ntp \
    --unattended
```

### Vérification Client

```bash
# Vérifier l'état
ipa-client-status

# Test d'authentification
kinit jdoe@CLUSTER.LOCAL
klist

# Test SSH
ssh jdoe@node-01
```

### Désenregistrement Client

```bash
# Désenregistrer un client
ipa-client-install --uninstall
```

---

## 🌐 DNS Intégré

### Gestion DNS via CLI

```bash
# Ajouter un enregistrement A
ipa dnsrecord-add cluster.local node-01 \
    --a-rec=192.168.100.101

# Ajouter un enregistrement CNAME
ipa dnsrecord-add cluster.local www \
    --cname-rec=frontal-01.cluster.local

# Ajouter un enregistrement MX
ipa dnsrecord-add cluster.local @ \
    --mx-rec="10 mail.cluster.local"

# Lister les enregistrements
ipa dnsrecord-find cluster.local
```

### Gestion DNS via Interface Web

1. **Network Services** > **DNS** > **DNS Zones**
2. Sélectionner `cluster.local`
3. **Add Record**
4. Choisir le type (A, CNAME, MX, etc.)
5. Remplir les informations

---

## 🔐 PKI et Certificats

### Génération de Certificat

```bash
# Créer un certificat pour un service
ipa cert-request --principal=HTTP/frontal-01.cluster.local \
    /tmp/cert.csr

# Afficher les certificats
ipa cert-find

# Révoquer un certificat
ipa cert-revoke <cert_id> --reason=key_compromise
```

### Configuration SSL/TLS

Les certificats sont automatiquement générés pour :
- Interface web FreeIPA
- Services LDAP (LDAPS)
- Services Kerberos

---

## 🔧 Dépannage

### Problèmes de Connexion

```bash
# Vérifier l'état du service
systemctl status ipa

# Test de connectivité
ipa ping

# Vérifier les logs
tail -f /var/log/ipaserver-install.log
tail -f /var/log/ipaclient-install.log
```

### Problèmes d'Authentification

```bash
# Vérifier le ticket Kerberos
klist

# Obtenir un nouveau ticket
kdestroy
kinit admin@CLUSTER.LOCAL

# Vérifier l'utilisateur dans LDAP
ipa user-find jdoe

# Vérifier le principal Kerberos
ipa user-show jdoe --all
```

### Problèmes DNS

```bash
# Vérifier la résolution
nslookup ipa.cluster.local
dig ipa.cluster.local

# Vérifier les enregistrements
ipa dnsrecord-find cluster.local
```

### Réinitialisation

```bash
# Réinitialiser le mot de passe admin
kinit admin@CLUSTER.LOCAL
ipa user-mod admin --password

# Réinitialiser un utilisateur
ipa user-mod jdoe --random
```

---

## 📚 Commandes Utiles

### Utilisateurs

```bash
ipa user-find              # Lister tous les utilisateurs
ipa user-show jdoe          # Afficher un utilisateur
ipa user-add ...            # Créer un utilisateur
ipa user-mod ...            # Modifier un utilisateur
ipa user-del jdoe           # Supprimer un utilisateur
```

### Groupes

```bash
ipa group-find              # Lister tous les groupes
ipa group-show hpc-users     # Afficher un groupe
ipa group-add ...           # Créer un groupe
ipa group-add-member ...    # Ajouter membre
ipa group-remove-member ... # Retirer membre
```

### Services

```bash
ipa service-find            # Lister les services
ipa service-add HTTP/frontal-01  # Ajouter un service
```

### Politiques

```bash
ipa pwpolicy-show           # Afficher les politiques
ipa hbacrule-find           # Lister les règles d'accès
```

---

## 📚 Ressources

- **FreeIPA Documentation** : https://www.freeipa.org/page/Documentation
- **FreeIPA User Guide** : https://www.freeipa.org/page/Documentation
- **FreeIPA API** : https://www.freeipa.org/page/API

---

**Version**: 2.0 (FreeIPA)  
**Dernière mise à jour**: 2024
