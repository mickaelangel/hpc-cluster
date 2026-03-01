# Technologies et Outils du Cluster HPC avec FreeIPA
## Documentation Technique Complète - Version FreeIPA

**Classification**: Documentation Technique  
**Public**: Étudiants Master / Ingénieurs  
**Version**: 2.0 (FreeIPA)  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [FreeIPA - Solution d'Authentification Unifiée](#freeipa---solution-dauthentification-unifiée)
3. [Gestion des Packages](#gestion-des-packages)
4. [Remote Graphics](#remote-graphics)
5. [Scheduler et Jobs](#scheduler-et-jobs)
6. [Stockage](#stockage)
7. [Monitoring](#monitoring)
8. [Provisioning](#provisioning)

---

## 🎯 Vue d'ensemble

Le cluster HPC utilise **FreeIPA** comme solution d'authentification unifiée, remplaçant la configuration LDAP + Kerberos séparés par une solution enterprise intégrée.

### Architecture Générale avec FreeIPA

```
┌─────────────────────────────────────────────────────────────┐
│                    NŒUDS FRONTAUX                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           FREEIPA SERVER (Intégré)                   │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │   LDAP   │  │ Kerberos │  │   DNS    │          │   │
│  │  │ (389DS)  │  │   KDC    │  │  Server  │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │   PKI    │  │ Policies │  │  Web UI │          │   │
│  │  │ (CA)     │  │          │  │         │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Nexus   │  │  X2Go    │  │  Slurm  │  │  BeeGFS  │   │
│  │ (PyPI)   │  │ (Remote) │  │  CTLD   │  │   MGMtd  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌───────▼──────┐  ┌───────▼──────┐
│  Compute-01  │  │  Compute-02  │  │  Compute-06  │
│  (FreeIPA    │  │  (FreeIPA    │  │  (FreeIPA    │
│   Client)    │  │   Client)    │  │   Client)    │
│  + SlurmD    │  │  + SlurmD    │  │  + SlurmD    │
│  + BeeGFS    │  │  + BeeGFS    │  │  + BeeGFS    │
│  + Spack     │  │  + Spack     │  │  + Spack     │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🔐 FreeIPA - Solution d'Authentification Unifiée

### Qu'est-ce que FreeIPA ?

**FreeIPA** (Identity, Policy, and Audit) est une solution open-source qui intègre :
- **LDAP** (389 Directory Server) : Annuaire centralisé
- **Kerberos** : Authentification sécurisée
- **DNS** : Résolution de noms intégrée
- **PKI** : Infrastructure à clés publiques (certificats)
- **Gestion des politiques** : Contrôle d'accès centralisé
- **Interface Web** : Administration graphique

### Pourquoi FreeIPA au lieu de LDAP + Kerberos séparés ?

**Avantages** :
- ✅ **Solution unifiée** : Tout-en-un au lieu de configurer séparément
- ✅ **Interface web** : Administration via navigateur
- ✅ **Enterprise-ready** : Solution robuste pour production
- ✅ **Gestion automatique** : Synchronisation LDAP ↔ Kerberos automatique
- ✅ **DNS intégré** : Résolution de noms pour le domaine
- ✅ **PKI intégrée** : Certificats SSL/TLS automatiques
- ✅ **Gestion des politiques** : Contrôle d'accès granulaire
- ✅ **Support** : Communauté active et documentation complète

**Comparaison** :

| Fonctionnalité | LDAP + Kerberos séparés | FreeIPA |
|---------------|------------------------|---------|
| Configuration | Complexe (2 services) | Simple (1 service) |
| Interface Web | Non (CLI uniquement) | Oui (Web UI) |
| Synchronisation | Manuelle | Automatique |
| DNS | Séparé | Intégré |
| PKI | Séparé | Intégré |
| Gestion politiques | Limitée | Avancée |

### Comment ça fonctionne ?

```
Utilisateur
    │
    │ Connexion (SSH, Web, etc.)
    ▼
FreeIPA Server
    │
    ├─► LDAP : Vérifie l'identité
    ├─► Kerberos : Émet un ticket
    ├─► DNS : Résout le nom
    └─► PKI : Fournit certificat (si nécessaire)
    │
    └─► Authentification réussie
```

**Composants FreeIPA** :
- **IPA Server** : Serveur principal (frontal-01)
- **IPA Replica** : Serveur de réplication (frontal-02, optionnel)
- **IPA Client** : Sur chaque nœud de calcul
- **Web UI** : Interface d'administration (port 443)
- **CLI** : Outils en ligne de commande (`ipa`)

### Installation

#### Sur le Nœud Frontal (Server)

**Méthode 1 : Docker (Recommandé pour simulation)**

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
    --no-ntp
```

**Méthode 2 : Installation Native (Production)**

```bash
# Sur openSUSE 15.6
zypper addrepo https://download.opensuse.org/repositories/security:/SELinux/openSUSE_Leap_15.6/security:SELinux.repo
zypper refresh
zypper install -y freeipa-server freeipa-server-dns

# Installation
ipa-server-install \
    --realm=CLUSTER.LOCAL \
    --domain=cluster.local \
    --ds-password='DSPassword123!' \
    --admin-password='AdminPassword123!' \
    --setup-dns \
    --forwarder=8.8.8.8 \
    --no-ntp
```

#### Sur les Nœuds de Calcul (Clients)

```bash
# Installation client
zypper install -y freeipa-client

# Configuration
ipa-client-install \
    --domain=cluster.local \
    --server=ipa.cluster.local \
    --realm=CLUSTER.LOCAL \
    --principal=admin \
    --password='AdminPassword123!' \
    --enable-dns-updates \
    --mkhomedir \
    --no-ntp
```

### Configuration

#### Accès à l'Interface Web

1. **URL** : `https://ipa.cluster.local` ou `https://frontal-01`
2. **Login** : `admin`
3. **Password** : Mot de passe défini lors de l'installation

#### Création d'Utilisateur via Interface Web

1. Se connecter à l'interface web
2. **Identity** > **Users** > **Add**
3. Remplir les informations :
   - **Username** : jdoe
   - **First name** : John
   - **Last name** : Doe
   - **Email** : jdoe@cluster.local
   - **Password** : (définir ou générer)
4. L'utilisateur est automatiquement créé dans :
   - LDAP
   - Kerberos
   - DNS (si configuré)

#### Création d'Utilisateur via CLI

```bash
# Se connecter en tant qu'admin
kinit admin@CLUSTER.LOCAL

# Créer un utilisateur
ipa user-add jdoe \
    --first=John \
    --last=Doe \
    --email=jdoe@cluster.local \
    --password

# Créer un groupe
ipa group-add hpc-users \
    --desc="HPC Users Group"

# Ajouter l'utilisateur au groupe
ipa group-add-member hpc-users --users=jdoe
```

### Utilisation

#### Authentification Utilisateur

```bash
# Connexion SSH (SSO automatique si ticket valide)
ssh jdoe@node-01

# Obtenir un ticket Kerberos
kinit jdoe@CLUSTER.LOCAL
# Entrer le mot de passe

# Vérifier le ticket
klist

# Connexion SSH sans mot de passe (si ticket valide)
ssh jdoe@node-02
```

#### Gestion des Politiques

```bash
# Créer une politique de mot de passe
ipa pwpolicy-add global_policy \
    --maxlife=90 \
    --minlife=1 \
    --history=12 \
    --minclasses=4

# Appliquer à un groupe
ipa pwpolicy-add hpc-users \
    --maxlife=180 \
    --minlife=1
```

#### Gestion DNS

```bash
# Ajouter un enregistrement A
ipa dnsrecord-add cluster.local node-01 --a-rec=192.168.100.101

# Ajouter un enregistrement CNAME
ipa dnsrecord-add cluster.local www --cname-rec=frontal-01
```

### Maintenance

#### Vérification du Service

```bash
# État du service
systemctl status ipa

# Vérifier la connectivité
ipa ping

# Vérifier la réplication (si replica configuré)
ipa-replica-manage list
```

#### Sauvegarde

```bash
# Export LDAP
ipa-backup --online --data

# Restauration
ipa-restore /var/lib/ipa/backup/ipa-data-YYYYMMDD-HHMMSS.tar.gz
```

#### Logs

```bash
# Logs FreeIPA
tail -f /var/log/ipaserver-install.log
tail -f /var/log/ipaclient-install.log

# Logs LDAP
tail -f /var/log/dirsrv/slapd-*/errors

# Logs Kerberos
tail -f /var/log/krb5kdc.log
```

---

## 📦 Gestion des Packages

### Nexus Repository

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

### Spack

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

---

## 🖥️ Remote Graphics

### X2Go (Open-Source)

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

**Intégration FreeIPA** :
- Authentification via FreeIPA (LDAP/Kerberos)
- SSO automatique si ticket valide

**Alternative** : NoMachine également disponible

---

## ⚡ Scheduler et Jobs

### Slurm

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

**Intégration FreeIPA** :
- Authentification utilisateurs via FreeIPA
- Tickets Kerberos pour SSO
- Gestion des quotas via groupes FreeIPA

---

## 💾 Stockage

### BeeGFS (Système de Fichiers Parallèle Open-Source)

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

**Alternative** : Lustre également disponible

---

## 📊 Monitoring

### Prometheus + Grafana + Telegraf

Voir documentation dans `TECHNOLOGIES_CLUSTER.md` - identique avec FreeIPA.

---

## 🔧 Provisioning

### TrinityX + Warewulf

Voir documentation dans `trinityx/GUIDE_INSTALLATION_TRINITYX.md`.

**Intégration FreeIPA** :
- Images système avec client FreeIPA pré-configuré
- Authentification automatique lors du boot

---

## 🔄 Migration depuis LDAP + Kerberos séparés

### Étapes de Migration

1. **Sauvegarder les données existantes** :
   ```bash
   # Export LDAP
   ldapsearch -x -b "dc=cluster,dc=local" > ldap_backup.ldif
   
   # Export Kerberos
   kdb5_util dump krb5_backup
   ```

2. **Installer FreeIPA** :
   ```bash
   # Voir section Installation ci-dessus
   ```

3. **Importer les utilisateurs** :
   ```bash
   # Via interface web ou CLI
   # Les utilisateurs doivent être recréés dans FreeIPA
   ```

4. **Configurer les clients** :
   ```bash
   # Sur chaque nœud
   ipa-client-install ...
   ```

5. **Vérifier** :
   ```bash
   # Test d'authentification
   kinit jdoe@CLUSTER.LOCAL
   ssh jdoe@node-01
   ```

---

## 📚 Ressources

- **FreeIPA Documentation** : https://www.freeipa.org/page/Documentation
- **FreeIPA Wiki** : https://www.freeipa.org/page/Main_Page
- **FreeIPA GitHub** : https://github.com/freeipa/freeipa

---

## ✅ Avantages de FreeIPA

1. **Simplicité** : Une seule solution au lieu de deux
2. **Interface Web** : Administration facile
3. **Automatisation** : Synchronisation automatique
4. **Enterprise** : Solution robuste et maintenue
5. **Intégration** : DNS et PKI intégrés
6. **Politiques** : Gestion avancée des politiques

---

**Version**: 2.0 (FreeIPA)  
**Dernière mise à jour**: 2024
