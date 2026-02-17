# Sécurité Finale - Cluster HPC
## Guide Rapide Installation Complète

**Date**: 2024

---

## 🚀 Installation Rapide

### Installation Automatique Complète

```bash
cd "cluster hpc"
chmod +x scripts/security/install-all-security.sh
sudo ./scripts/security/install-all-security.sh
```

**Ce script installe automatiquement** :
- Hardening système
- Firewall avancé (3 technologies)
- IDS (Suricata, Wazuh, OSSEC)
- Chiffrement (LUKS)
- Vault (secrets)
- Certbot (certificats)
- Falco + Trivy (containers)
- Export métriques
- Automatisation
- Configuration Prometheus

---

## 📊 Dashboards

**Grafana** : http://frontal-01:3000

**6 dashboards sécurité** :
1. Security Advanced
2. Compliance
3. Vulnerabilities
4. Network Security
5. Container Security
6. Audit Trail

**Total** : **59 panels**

---

## 🔄 Automatisation

### Tâches Quotidiennes

**Exécutées automatiquement** :
- Scan vulnérabilités
- Monitoring compliance
- Scan Trivy images
- Vérification AIDE
- Export métriques

**Timer** : `systemctl status security-daily-tasks.timer`

### Export Métriques

**Toutes les 30 secondes** :
- Fail2ban
- Firewall
- Auditd
- AIDE
- Compliance

**Timer** : `systemctl status export-security-metrics.timer`

---

## 🚨 Alertes

**Prometheus** : http://localhost:9090/alerts

**20+ règles d'alertes** :
- Fail2ban, Firewall
- IDS (Suricata, Wazuh, OSSEC)
- Falco, Vulnérabilités
- Compliance, AIDE, Auditd
- Containers, Network

---

## 📚 Documentation

**Guides complets** :
- `docs/GUIDE_SECURITE_AVANCEE.md`
- `docs/GUIDE_DASHBOARDS_SECURITE.md`
- `docs/GUIDE_AUTOMATISATION_SECURITE.md`

---

## ✅ Résultat

**Sécurité Enterprise Production avec automatisation complète !** 🔒

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
