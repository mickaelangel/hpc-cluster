# Guide Automatisation Sécurité - Cluster HPC
## Tâches Automatisées et Monitoring Continu

**Classification**: Documentation Sécurité  
**Public**: Administrateurs Sécurité  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Export Métriques Automatique](#export-métriques-automatique)
3. [Tâches Quotidiennes](#tâches-quotidiennes)
4. [Alertes Prometheus](#alertes-prometheus)
5. [Configuration Prometheus](#configuration-prometheus)
6. [Monitoring Continu](#monitoring-continu)

---

## 🎯 Vue d'Ensemble

**Automatisation complète** de la sécurité avec :
- Export métriques automatique (toutes les 30s)
- Tâches sécurité quotidiennes
- Alertes Prometheus automatiques
- Monitoring continu

---

## 📊 Export Métriques Automatique

### Installation

```bash
./scripts/security/setup-metrics-exporter.sh
```

### Fonctionnement

**Timer systemd** : Exécute toutes les 30 secondes

**Métriques exportées** :
- Fail2ban (banned IPs, failed attempts)
- Firewall (drops, accepts)
- Auditd (events, failed auth)
- AIDE (checks, violations)
- Compliance (score)

**Fichier** : `/var/lib/prometheus/node-exporter/security.prom`

### Vérification

```bash
# Vérifier timer
systemctl status export-security-metrics.timer

# Vérifier métriques
cat /var/lib/prometheus/node-exporter/security.prom
```

---

## 🔄 Tâches Quotidiennes

### Installation

```bash
./scripts/automation/setup-security-automation.sh
```

### Tâches Exécutées

**Quotidiennement** :
1. Scan vulnérabilités (packages, images)
2. Monitoring compliance (DISA STIG, CIS, ANSSI)
3. Scan Trivy images Docker
4. Vérification intégrité AIDE
5. Export métriques sécurité

**Logs** : `/var/log/security-daily/`

### Vérification

```bash
# Vérifier timer
systemctl status security-daily-tasks.timer

# Voir prochaine exécution
systemctl list-timers security-daily-tasks.timer

# Voir logs
ls -lh /var/log/security-daily/
```

---

## 🚨 Alertes Prometheus

### Fichier Alertes

**Fichier** : `monitoring/prometheus/alerts-security.yml`

### Types d'Alertes

1. **Fail2ban** :
   - Tentatives connexion élevées
   - IPs bannies nombreuses

2. **Firewall** :
   - Taux paquets bloqués élevé
   - Activité suspecte

3. **IDS** :
   - Alertes Suricata
   - Alertes Wazuh
   - Alertes OSSEC

4. **Falco** :
   - Alertes critiques
   - Alertes élevées

5. **Vulnérabilités** :
   - Vulnérabilités critiques
   - Vulnérabilités HIGH nombreuses

6. **Compliance** :
   - Score compliance faible
   - Score compliance critique

7. **AIDE** :
   - Violations intégrité

8. **Auditd** :
   - Taux événements élevé
   - Tentatives auth échouées

9. **Containers** :
   - Containers root
   - Containers privilégiés

10. **Network** :
    - Activité réseau suspecte

---

## ⚙️ Configuration Prometheus

### Configuration

```bash
./scripts/security/configure-prometheus-security.sh
```

**Ajouts** :
- Scrape config node-exporter
- File SD pour métriques sécurité
- Rule files pour alertes

### Vérification

```bash
# Valider configuration
promtool check config /etc/prometheus/prometheus.yml

# Recharger Prometheus
systemctl reload prometheus
```

---

## 📈 Monitoring Continu

### Dashboards Grafana

**6 dashboards sécurité** disponibles :
1. Security Advanced
2. Compliance
3. Vulnerabilities
4. Network Security
5. Container Security
6. Audit Trail

**Accès** : http://frontal-01:3000

### Alertes

**Prometheus** : http://frontal-01:9090/alerts

**Notifications** :
- Email (configurable)
- Slack (configurable)
- PagerDuty (configurable)

---

## 🔧 Dépannage

### Métriques non exportées

```bash
# Vérifier timer
systemctl status export-security-metrics.timer

# Exécuter manuellement
/usr/local/bin/export-security-metrics.sh

# Vérifier fichier
cat /var/lib/prometheus/node-exporter/security.prom
```

### Tâches quotidiennes ne s'exécutent pas

```bash
# Vérifier timer
systemctl status security-daily-tasks.timer

# Exécuter manuellement
./scripts/automation/security-daily-tasks.sh

# Vérifier logs
journalctl -u security-daily-tasks.service
```

---

## 📚 Documentation Complémentaire

- `GUIDE_SECURITE_AVANCEE.md` - Sécurité avancée
- `GUIDE_DASHBOARDS_SECURITE.md` - Dashboards
- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
