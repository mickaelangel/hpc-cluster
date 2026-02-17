# Guide Dashboards Sécurité - Cluster HPC
## Visualisation Complète de la Sécurité

**Classification**: Documentation Monitoring Sécurité  
**Public**: Administrateurs / Ingénieurs Sécurité  
**Version**: 1.0  
**Date**: 2024

---

## 📊 Dashboards Disponibles

### 1. Security Advanced Dashboard

**Fichier** : `grafana-dashboards/security-advanced.json`

**Contenu** :
- Security Events Overview
- Failed Login Attempts (SSH, Slurm)
- Banned IPs (Fail2ban)
- IDS Alerts (Suricata, Wazuh, OSSEC)
- Firewall Drops
- Audit Events by Type
- Falco Container Alerts
- Vulnerability Scan Results
- Compliance Score
- Top Security Threats
- Network Security Events

**Accès** : Grafana → Dashboards → Security Advanced

---

### 2. Compliance Dashboard

**Fichier** : `grafana-dashboards/compliance.json`

**Contenu** :
- Overall Compliance Score (gauge)
- DISA STIG Compliance
- CIS Level 2 Compliance
- ANSSI BP-028 Compliance
- Compliance Checks by Category
- Failed Compliance Checks (table)
- Compliance Trend (timeline)

**Accès** : Grafana → Dashboards → Compliance

---

### 3. Vulnerabilities Dashboard

**Fichier** : `grafana-dashboards/vulnerabilities.json`

**Contenu** :
- Critical/High/Medium Vulnerabilities (stats)
- Total Vulnerabilities
- Vulnerabilities by Severity (pie)
- Vulnerabilities by Component (bar)
- Top Vulnerable Images (table)
- Vulnerability Trend (timeline)
- Package Updates Available
- Security Updates Available

**Accès** : Grafana → Dashboards → Vulnerabilities

---

### 4. Network Security Dashboard

**Fichier** : `grafana-dashboards/network-security.json`

**Contenu** :
- Firewall Drops/Accepts (graphs)
- Top Blocked IPs (table)
- Top Blocked Ports (bar)
- Network Traffic by Protocol (pie)
- Suspicious Network Activity
- Connection States (stats)
- Network Security Events Timeline

**Accès** : Grafana → Dashboards → Network Security

---

### 5. Container Security Dashboard

**Fichier** : `grafana-dashboards/container-security.json`

**Contenu** :
- Falco Alerts (graph)
- Container Vulnerabilities (stat)
- Falco Alerts by Priority (pie)
- Falco Alerts by Rule (bar)
- Top Vulnerable Containers (table)
- Container Security Events (timeline)
- Running Containers
- Containers with Root Access
- Containers with Privileged Mode

**Accès** : Grafana → Dashboards → Container Security

---

### 6. Audit Trail Dashboard

**Fichier** : `grafana-dashboards/audit-trail.json`

**Contenu** :
- Audit Events Rate (graph)
- Audit Events by Type (pie)
- Failed Authentication Attempts
- File Access Events
- Recent Audit Events (table)
- Top Users by Audit Events
- Top Commands Executed
- AIDE Integrity Checks/Violations
- Audit Trail Timeline

**Accès** : Grafana → Dashboards → Audit Trail

---

## 🔧 Configuration

### Installation Dashboards

Les dashboards sont automatiquement provisionnés via Grafana :
- Répertoire : `grafana-dashboards/`
- Provisioning : `configs/grafana/provisioning/dashboards/`

### Métriques Requises

Pour que les dashboards fonctionnent, exporter les métriques :
```bash
./scripts/security/export-metrics-prometheus.sh
```

### Prometheus Configuration

Ajouter dans `prometheus.yml` :
```yaml
scrape_configs:
  - job_name: 'security'
    static_configs:
      - targets: ['localhost:9100']
    file_sd_configs:
      - files:
          - '/var/lib/prometheus/node-exporter/security.prom'
```

---

## 📈 Utilisation

### Accès Dashboards

1. Ouvrir Grafana : http://frontal-01:3000
2. Login : admin / admin
3. Naviguer : Dashboards → Browse
4. Sélectionner dashboard souhaité

### Personnalisation

1. Ouvrir dashboard
2. Cliquer sur ⚙️ (Settings)
3. Modifier panels selon besoins
4. Sauvegarder

---

## 🚨 Alertes

### Configuration Alertes

Créer alertes basées sur les dashboards :
- Compliance score < 90%
- Critical vulnerabilities > 0
- Falco alerts > 10/min
- Firewall drops > 100/min

---

## 📚 Documentation Complémentaire

- `GUIDE_SECURITE_AVANCEE.md` - Sécurité avancée
- `GUIDE_DASHBOARDS_GRAFANA.md` - Dashboards généraux
- `GUIDE_MONITORING_AVANCE.md` - Monitoring avancé

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
