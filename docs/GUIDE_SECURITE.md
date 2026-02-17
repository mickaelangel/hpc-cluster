# Guide de Sécurité - Cluster HPC
## Hardening et Protection

**Classification**: Documentation Technique  
**Public**: Administrateurs Système / Ingénieurs Sécurité  
**Version**: 1.0  
**Date**: 2024

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Hardening Système](#hardening-système)
3. [Protection SSH](#protection-ssh)
4. [Fail2ban](#fail2ban)
5. [Auditd](#auditd)
6. [AIDE](#aide)
7. [AppArmor/SELinux](#apparmorselinux)
8. [Firewall Avancé](#firewall-avancé)
9. [Gestion Secrets (Vault)](#gestion-secrets-vault)
10. [Certificats SSL/TLS](#certificats-ssltls)
11. [Sécurité Containers](#sécurité-containers)
12. [Scan Vulnérabilités](#scan-vulnérabilités)
13. [Monitoring Compliance](#monitoring-compliance)
14. [Dashboards Sécurité](#dashboards-sécurité)
15. [Vérification](#vérification)

---

## 🎯 Vue d'ensemble

Ce guide explique comment sécuriser un cluster HPC selon les standards :
- **DISA STIG** : Security Technical Implementation Guide
- **CIS Level 2** : Center for Internet Security
- **ANSSI BP-028** : Guide d'hygiène informatique

---

## 🔒 Hardening Système

### Script Automatisé

```bash
# Installation complète
cd cluster\ hpc/scripts/security
sudo ./hardening.sh
```

### Configuration Kernel (sysctl)

Voir `scripts/security/hardening.sh` pour la configuration complète.

**Protections activées** :
- Désactivation IP forwarding
- Protection contre attaques réseau
- Protection Spectre/Meltdown
- Restriction accès mémoire

---

## 🔐 Protection SSH

### Configuration SSH Sécurisée

**Algorithmes sécurisés** :
- KexAlgorithms : curve25519-sha256, diffie-hellman-group-exchange-sha256
- Ciphers : chacha20-poly1305, aes256-gcm, aes128-gcm
- MACs : hmac-sha2-256-etm, hmac-sha2-512-etm

**Restrictions** :
- PermitRootLogin : no
- MaxAuthTries : 3
- MaxSessions : 10
- ClientAliveInterval : 300

---

## 🛡️ Fail2ban

### Installation

```bash
zypper install -y fail2ban
```

### Configuration

Voir `scripts/security/hardening.sh` pour la configuration complète.

**Protection** :
- SSH : 3 tentatives, ban 1h
- Slurm : 5 tentatives, ban 2h

---

## 📊 Auditd

### Installation

```bash
zypper install -y audit
```

### Configuration

**Surveillance** :
- Modifications fichiers critiques (/etc/passwd, /etc/shadow)
- Accès privilégiés
- Modifications réseau
- Montages système

---

## 🔍 AIDE

### Installation

```bash
zypper install -y aide
```

### Configuration

**Vérification quotidienne** :
- Base de données initialisée
- Cron quotidien configuré
- Logs dans `/var/log/aide/`

---

## 🔐 AppArmor/SELinux

### AppArmor (SUSE)

```bash
zypper install -y apparmor apparmor-utils
systemctl enable apparmor
systemctl start apparmor
```

### Profils Recommandés

- SlurmCTLD
- Slurmd
- SSH
- LDAP

---

## ✅ Vérification

### Script de Vérification

```bash
cd cluster\ hpc/scripts/tests
sudo ./test-cluster-health.sh
```

### Vérification Manuelle

```bash
# Vérifier Fail2ban
fail2ban-client status sshd

# Vérifier Auditd
systemctl status auditd
ausearch -k identity

# Vérifier AIDE
aide --check
```

---

## 📚 Ressources

- **DISA STIG** : https://public.cyber.mil/stigs/
- **CIS Benchmarks** : https://www.cisecurity.org/benchmarks/
- **ANSSI BP-028** : https://www.ssi.gouv.fr/

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
