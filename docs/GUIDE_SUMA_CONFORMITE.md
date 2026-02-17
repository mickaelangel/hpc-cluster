# Guide SUMA et Conformité - Cluster HPC
## SUSE Manager pour Gestion de Conformité et Patches

**Classification**: Documentation Technique  
**Public**: Administrateurs Système  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Installation SUMA](#installation-suma)
3. [Configuration Offline](#configuration-offline)
4. [Content Lifecycle Management](#content-lifecycle-management)
5. [Salt States](#salt-states)
6. [Conformité DISA STIG](#conformité-disa-stig)
7. [Audit CVE](#audit-cve)

---

## 🎯 Vue d'ensemble

**SUMA (SUSE Manager)** est utilisé pour :
- **Gestion des patches** : Validation et déploiement des patches de sécurité
- **Conformité** : Validation DISA STIG, CIS Level 2
- **Configuration** : Gestion centralisée via Salt States
- **Audit CVE** : Détection automatique des vulnérabilités
- **Environnement isolé** : Synchronisation offline via médias amovibles

---

## 🔧 Installation SUMA

### Serveur SUMA

```bash
cd cluster\ hpc/scripts/suma
sudo ./install-suma.sh
# Mode: server
```

**Étapes** :
1. Installation SUSE Manager Server
2. Configuration initiale (`mgr-setup`)
3. Configuration channels offline
4. Configuration Content Lifecycle Management
5. Configuration audit CVE

### Client SUMA (Salt Minion)

```bash
cd cluster\ hpc/scripts/suma
sudo ./install-suma.sh
# Mode: client
# SUMA_SERVER=suma-internal.defense.local
```

**Étapes** :
1. Installation Salt Minion
2. Configuration connexion au serveur SUMA
3. Démarrage du service

---

## 📦 Configuration Offline

### Synchronisation depuis Média Amovible

```bash
cd cluster\ hpc/scripts/suma
sudo ./sync-suma-offline.sh
# SYNC_DIR=/mnt/usb-suma-sync
```

**Processus** :
1. Monter le média USB/DVD sur `/mnt/suma-sync`
2. Import depuis RMT (si disponible)
3. Synchronisation SUMA
4. Copie des packages vers SUMA

### Workflow Offline

```
SI Extérieur
    │
    ├─► Export RMT: rmt-cli export
    │
    ├─► Média USB/DVD
    │
    ├─► EXSUS Server (exsus-repo.defense.local)
    │   └─► Import: rmt-cli import
    │
    └─► SUMA Server (suma-internal.defense.local)
        └─► Sync: mgr-sync refresh
```

---

## 🔄 Content Lifecycle Management

### Workflow de Validation

```
Dev → Test → Prod
```

**Configuration** :
- **Dev** : Patches bruts importés
- **Test** : Validation et tests
- **Prod** : Patches approuvés déployés

**Filtres** :
- Security-Critical : CVE severity >= 7
- Patches validés uniquement

---

## 🧂 Salt States

### Configuration Salt States

```bash
cd cluster\ hpc/scripts/suma
sudo ./configure-salt-states.sh
```

**States créés** :
- `hardening/sysctl.sls` - Hardening kernel
- `hardening/ssh.sls` - Hardening SSH
- `suma/minion-config.sls` - Configuration SUMA
- `hpc/` - Configurations HPC spécifiques

### Application des States

```bash
# Sur le serveur SUMA
salt '*' state.apply

# Hardening uniquement
salt '*' state.apply hardening

# SUMA uniquement
salt '*' state.apply suma
```

---

## ✅ Conformité DISA STIG

### Validation via SUMA

SUMA permet de :
1. **Déployer les configurations** : Via Salt States
2. **Valider la conformité** : Rapports automatiques
3. **Appliquer les patches** : Patches de sécurité validés
4. **Auditer** : Rapports de conformité

### Script de Validation

```bash
cd cluster\ hpc/scripts/compliance
sudo ./validate-compliance.sh
```

**Vérifications** :
- Hardening kernel (sysctl)
- Hardening SSH
- Fail2ban, Auditd, AIDE
- Permissions fichiers
- Services désactivés

---

## 🔍 Audit CVE

### Configuration Automatique

**Cron quotidien** :
```bash
0 6 * * * root spacewalk-report cve-audit > /var/log/suma/cve-audit-$(date +\%Y\%m\%d).log
```

### Rapports CVE

```bash
# Générer rapport CVE
spacewalk-report cve-audit > /var/log/suma/cve-audit-$(date +%Y%m%d).log

# Consulter les rapports
ls -lh /var/log/suma/cve-audit-*.log
```

---

## 📊 Architecture SUMA

### Composants

1. **SUMA Server** :
   - Gestion centralisée
   - Content Lifecycle Management
   - Salt Master

2. **Salt Minions** :
   - Sur chaque nœud
   - Connexion au serveur SUMA
   - Application des configurations

3. **EXSUS Server** :
   - Repository Mirror (RMT)
   - Synchronisation offline
   - Cache des packages

### Réseau

```
┌─────────────────┐
│  SUMA Server    │
│  (Salt Master)  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│Frontal│ │Compute│
│Minion │ │Minion │
└───────┘ └───────┘
```

---

## 🔐 Sécurité

### Configuration Sécurisée

- **Vérification des clés** : `verify_master_pubkey_sign: True`
- **Signature** : `always_verify_signature: True`
- **Chiffrement** : Communication chiffrée
- **Isolation** : Réseau de management séparé

---

## 📚 Commandes Utiles

### SUMA

```bash
# Synchronisation
mgr-sync refresh

# Gestion channels
mgr-sync list channels

# Rapports
spacewalk-report cve-audit
```

### Salt

```bash
# Test connexion
salt-call test.ping

# Appliquer states
salt '*' state.apply

# Vérifier grains
salt '*' grains.items
```

---

## 📚 Ressources

- **SUSE Manager Documentation** : https://documentation.suse.com/suma/
- **Salt Documentation** : https://docs.saltproject.io/
- **DISA STIG** : https://public.cyber.mil/stigs/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
