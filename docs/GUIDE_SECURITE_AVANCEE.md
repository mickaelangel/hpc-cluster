# Guide Sécurité Avancée - Cluster HPC
## Sécurisation Complète et Monitoring

**Classification**: Documentation Sécurité Avancée  
**Public**: Administrateurs Sécurité / Ingénieurs  
**Version**: 2.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Firewall Avancé](#firewall-avancé)
3. [Gestion Secrets (Vault)](#gestion-secrets-vault)
4. [Certificats SSL/TLS (Certbot)](#certificats-ssltls-certbot)
5. [Sécurité Containers (Falco, Trivy)](#sécurité-containers-falco-trivy)
6. [Scan Vulnérabilités](#scan-vulnérabilités)
7. [Monitoring Compliance](#monitoring-compliance)
8. [Dashboards Sécurité](#dashboards-sécurité)
9. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

Ce guide couvre les améliorations de sécurité avancées pour le cluster HPC :
- **Firewall** : nftables, firewalld, iptables avec règles strictes
- **Vault** : Gestion centralisée des secrets
- **Certbot** : Certificats SSL/TLS automatiques
- **Falco** : Runtime security monitoring containers
- **Trivy** : Scan vulnérabilités images Docker
- **Compliance** : Monitoring DISA STIG, CIS Level 2, ANSSI BP-028
- **MFA** : Authentification multi-facteur (TOTP, YubiKey)
- **RBAC Avancé** : Gestion permissions granulaire
- **Incident Response** : Collection d'évidences automatisée
- **Security Testing** : Tests de pénétration automatisés
- **Zero Trust** : Architecture Zero Trust avec micro-segmentation
- **Chiffrement InfiniBand** : Protection données HPC en transit

---

## 🔥 Firewall Avancé

### Installation

```bash
./scripts/security/configure-firewall.sh
```

### Configuration

**nftables** (moderne) :
- Règles strictes par défaut (DROP)
- Rate limiting SSH
- Accès interne uniquement pour services
- Logging des paquets bloqués

**firewalld** (alternative) :
- Zones cluster-internal / cluster-external
- Services autorisés par zone
- Politique restrictive

**iptables** (compatibilité) :
- Règles compatibles
- Logging automatique

### Vérification

```bash
# nftables
nft list ruleset

# firewalld
firewall-cmd --list-all

# iptables
iptables -L -n -v
```

---

## 🔐 Gestion Secrets (Vault)

### Installation

```bash
./scripts/security/install-vault.sh
```

### Initialisation

```bash
# Initialiser Vault
vault operator init

# Déverrouiller (avec 3 clés)
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
```

### Utilisation

```bash
# Stocker secret
vault kv put secret/cluster/ldap password="secret123"

# Lire secret
vault kv get secret/cluster/ldap

# Interface Web
# http://localhost:8200
```

---

## 🔒 Certificats SSL/TLS (Certbot)

### Installation

```bash
./scripts/security/install-certbot.sh
```

### Obtenir Certificat

```bash
# Standalone
certbot certonly --standalone -d cluster.local

# Avec nginx
certbot --nginx -d cluster.local

# Avec apache
certbot --apache -d cluster.local
```

### Renouvellement Automatique

Renouvellement automatique configuré via timer systemd :
```bash
systemctl status certbot-renew.timer
```

---

## 🐳 Sécurité Containers

### Falco (Runtime Security)

**Installation** :
```bash
./scripts/security/install-falco.sh
```

**Fonctionnalités** :
- Détection activité suspecte containers
- Alertes en temps réel
- Règles personnalisables

**Logs** :
```bash
tail -f /var/log/falco.log
```

### Trivy (Scan Vulnérabilités)

**Installation** :
```bash
./scripts/security/install-trivy.sh
```

**Utilisation** :
```bash
# Scan image
trivy image prometheus:latest

# Scan automatique
/usr/local/bin/trivy-scan-images.sh
```

---

## 🔍 Scan Vulnérabilités

### Scan Complet

```bash
./scripts/security/scan-vulnerabilities.sh
```

**Scans effectués** :
- Packages système (zypper)
- Images Docker (Trivy)
- Configuration sécurité
- Services actifs

**Rapports** : `/var/log/security-scans/`

---

## 📊 Monitoring Compliance

### Vérification Compliance

```bash
./scripts/security/monitor-compliance.sh
```

**Standards vérifiés** :
- **DISA STIG** : 5+ vérifications
- **CIS Level 2** : 4+ vérifications
- **ANSSI BP-028** : 3+ vérifications

**Rapport** : `/var/log/compliance/compliance-YYYYMMDD-HHMMSS.txt`

---

## 📈 Dashboards Sécurité

### Dashboards Disponibles

1. **Security Advanced** (`security-advanced.json`)
   - Vue d'ensemble sécurité
   - IDS alerts
   - Firewall drops
   - Falco alerts

2. **Compliance** (`compliance.json`)
   - Score compliance global
   - Par standard (DISA STIG, CIS, ANSSI)
   - Checks échoués
   - Tendance

3. **Vulnerabilities** (`vulnerabilities.json`)
   - Vulnérabilités par sévérité
   - Par composant
   - Images vulnérables
   - Mises à jour disponibles

4. **Network Security** (`network-security.json`)
   - Firewall drops/accepts
   - IPs bloquées
   - Ports bloqués
   - Activité réseau suspecte

5. **Container Security** (`container-security.json`)
   - Falco alerts
   - Vulnérabilités containers
   - Containers root/privileged

6. **Audit Trail** (`audit-trail.json`)
   - Événements audit
   - Tentatives auth échouées
   - Accès fichiers
   - AIDE integrity

### Accès

**Grafana** : http://frontal-01:3000
- Dashboards → Security Advanced
- Dashboards → Compliance
- Dashboards → Vulnerabilities

---

## 🔧 Dépannage

### Firewall bloque tout

```bash
# Vérifier règles
nft list ruleset
firewall-cmd --list-all

# Désactiver temporairement (test)
systemctl stop nftables
systemctl stop firewalld
```

### Vault ne démarre pas

```bash
# Vérifier logs
journalctl -u vault -f

# Vérifier permissions
ls -la /var/lib/vault
```

### Falco trop d'alertes

```bash
# Ajuster règles
vim /etc/falco/falco_rules.local.yaml

# Recharger
systemctl reload falco
```

---

## 📚 Documentation Complémentaire

- `GUIDE_SECURITE.md` - Sécurité de base
- `GUIDE_IDS_SECURITE.md` - IDS (Suricata, Wazuh, OSSEC)
- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé

---

**Version**: 2.0  
**Dernière mise à jour**: 2024
