# Guide IDS (Intrusion Detection System) - Cluster HPC
## Suricata, Wazuh, OSSEC

**Classification**: Documentation Sécurité  
**Public**: Administrateurs Système / Ingénieurs Sécurité  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Suricata (NIDS)](#suricata-nids)
3. [Wazuh (SIEM)](#wazuh-siem)
4. [OSSEC (HIDS)](#ossec-hids)
5. [Configuration](#configuration)
6. [Utilisation](#utilisation)
7. [Alertes et Monitoring](#alertes-et-monitoring)
8. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**IDS (Intrusion Detection System)** : Système de détection d'intrusions qui surveille le réseau et les hôtes pour détecter des activités suspectes ou malveillantes.

### Types d'IDS

1. **NIDS (Network IDS)** : Suricata
   - Surveille le trafic réseau
   - Détecte attaques réseau
   - Analyse paquets en temps réel

2. **SIEM (Security Information and Event Management)** : Wazuh
   - Collecte et analyse logs
   - Corrélation d'événements
   - Alertes centralisées

3. **HIDS (Host-based IDS)** : OSSEC
   - Surveille fichiers système
   - Détecte modifications
   - Intégrité fichiers

---

## 🔍 Suricata (NIDS)

### Qu'est-ce que Suricata ?

**Suricata** est un système de détection d'intrusions réseau (NIDS) open-source qui analyse le trafic réseau en temps réel pour détecter des attaques.

### Installation

```bash
./scripts/security/install-suricata.sh
```

### Configuration

**Fichier** : `/etc/suricata/suricata.yaml`

```yaml
vars:
  address-groups:
    HOME_NET: "[172.20.0.0/24,10.0.0.0/24,10.10.10.0/24]"
    EXTERNAL_NET: "!$HOME_NET"

default-log-dir: /var/log/suricata/
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
  - alert:
      enabled: yes
      filename: alert.json
```

### Utilisation

```bash
# Démarrer Suricata
systemctl start suricata

# Voir les alertes
tail -f /var/log/suricata/alert.json

# Mettre à jour les règles
suricata-update
```

### Alertes

Suricata génère des alertes pour :
- Tentatives d'intrusion
- Scans de ports
- Attaques réseau
- Trafic suspect

---

## 🛡️ Wazuh (SIEM)

### Qu'est-ce que Wazuh ?

**Wazuh** est une plateforme SIEM open-source qui collecte, analyse et corrèle les logs de sécurité pour détecter les menaces.

### Installation

```bash
./scripts/security/install-wazuh.sh
```

### Architecture

```
Wazuh Server (frontal-01)
    │
    ├─► Wazuh Agent (frontal-01)
    ├─► Wazuh Agent (frontal-02)
    ├─► Wazuh Agent (compute-01)
    └─► Wazuh Agent (compute-02)
```

### Configuration Agent

**Fichier** : `/var/ossec/etc/ossec.conf`

```xml
<ossec_config>
  <client>
    <server>
      <address>frontal-01</address>
      <port>1514</port>
    </server>
  </client>
</ossec_config>
```

### Utilisation

```bash
# Démarrer Wazuh
systemctl start wazuh-manager
systemctl start wazuh-agent

# Voir les alertes
tail -f /var/ossec/logs/alerts/alerts.log

# Interface Web
# http://frontal-01:5601 (Kibana avec Wazuh)
```

### Fonctionnalités

- **Détection d'intrusions** : Analyse comportementale
- **Intégrité fichiers** : Surveillance modifications
- **Logs centralisés** : Collecte tous les logs
- **Alertes** : Notifications automatiques

---

## 🔐 OSSEC (HIDS)

### Qu'est-ce qu'OSSEC ?

**OSSEC** est un système de détection d'intrusions basé sur l'hôte (HIDS) qui surveille les fichiers système et détecte les modifications.

### Installation

```bash
./scripts/security/install-ossec.sh
```

### Configuration

**Fichier** : `/var/ossec/etc/ossec.conf`

```xml
<ossec_config>
  <global>
    <email_notification>no</email_notification>
  </global>
  
  <rules>
    <include>rules_config.xml</include>
    <include>pam_rules.xml</include>
    <include>sshd_rules.xml</include>
    <include>slurm_rules.xml</include>
  </rules>
</ossec_config>
```

### Utilisation

```bash
# Démarrer OSSEC
/opt/ossec/bin/ossec-control start

# Voir les alertes
tail -f /var/ossec/logs/alerts/alerts.log

# Vérifier l'intégrité
/opt/ossec/bin/syscheck_control -s
```

### Surveillance

OSSEC surveille :
- **Fichiers système** : Modifications, suppressions
- **Logs système** : Événements suspects
- **Processus** : Activités anormales
- **Réseau** : Connexions suspectes

---

## ⚙️ Configuration

### Intégration avec Monitoring

**Prometheus** :
```yaml
scrape_configs:
  - job_name: 'suricata'
    static_configs:
      - targets: ['localhost:8125']
```

**Grafana Dashboard** :
- Alertes Suricata
- Événements Wazuh
- Intégrité OSSEC

---

## 📊 Utilisation

### Vérification État

```bash
# Suricata
systemctl status suricata
suricatasc -c "version"

# Wazuh
systemctl status wazuh-manager
systemctl status wazuh-agent

# OSSEC
/opt/ossec/bin/ossec-control status
```

### Consultation Alertes

```bash
# Suricata
cat /var/log/suricata/alert.json | jq

# Wazuh
tail -f /var/ossec/logs/alerts/alerts.log

# OSSEC
tail -f /var/ossec/logs/alerts/alerts.log
```

---

## 🚨 Alertes et Monitoring

### Types d'Alertes

1. **Critique** : Intrusion confirmée
2. **Haute** : Activité suspecte
3. **Moyenne** : Anomalie détectée
4. **Basse** : Information

### Intégration Grafana

Dashboards disponibles :
- Alertes par type
- Événements par source
- Tendances temporelles
- Top menaces

---

## 🔧 Dépannage

### Problèmes Courants

**Suricata ne démarre pas** :
```bash
# Vérifier interface réseau
suricata -c /etc/suricata/suricata.yaml -i eth0 --list-runmodes

# Vérifier règles
suricata -T -c /etc/suricata/suricata.yaml
```

**Wazuh agent ne se connecte pas** :
```bash
# Vérifier configuration
/var/ossec/bin/agent_control -l

# Vérifier connexion
telnet frontal-01 1514
```

**OSSEC alertes manquantes** :
```bash
# Vérifier règles
/opt/ossec/bin/verify-agent-conf

# Vérifier logs
tail -f /var/ossec/logs/ossec.log
```

---

## 📚 Documentation Complémentaire

- `GUIDE_SECURITE.md` - Guide sécurité complet
- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
