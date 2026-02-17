#!/bin/bash
# ============================================================================
# Configuration Export Métriques Sécurité vers Prometheus
# Setup complet pour exporter toutes les métriques sécurité
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SETUP EXPORT MÉTRIQUES SÉCURITÉ${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. CRÉER RÉPERTOIRE MÉTRIQUES
# ============================================================================
echo -e "\n${YELLOW}[1/5] Création répertoire métriques...${NC}"

METRICS_DIR="/var/lib/prometheus/node-exporter"
mkdir -p "$METRICS_DIR"
chown prometheus:prometheus "$METRICS_DIR" 2>/dev/null || true

echo -e "${GREEN}  ✅ Répertoire créé${NC}"

# ============================================================================
# 2. CRÉER SCRIPT EXPORT AUTOMATIQUE
# ============================================================================
echo -e "\n${YELLOW}[2/5] Création script export automatique...${NC}"

cat > /usr/local/bin/export-security-metrics.sh <<'EOF'
#!/bin/bash
# Export automatique métriques sécurité

METRICS_FILE="/var/lib/prometheus/node-exporter/security.prom"
TMP_FILE="${METRICS_FILE}.tmp"

# Nettoyer fichier temporaire
> "$TMP_FILE"

# Export Fail2ban
if systemctl is-active --quiet fail2ban; then
    BANNED=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}' || echo "0")
    FAILED=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null | tail -1 || echo "0")
    
    echo "# TYPE fail2ban_banned_ips gauge" >> "$TMP_FILE"
    echo "fail2ban_banned_ips $BANNED" >> "$TMP_FILE"
    echo "# TYPE fail2ban_ssh_failed_total counter" >> "$TMP_FILE"
    echo "fail2ban_ssh_failed_total $FAILED" >> "$TMP_FILE"
fi

# Export Firewall
if command -v nft &> /dev/null; then
    DROPS=$(nft list counters 2>/dev/null | grep -c "packets" || echo "0")
    echo "# TYPE firewall_drops_total counter" >> "$TMP_FILE"
    echo "firewall_drops_total $DROPS" >> "$TMP_FILE"
fi

# Export Auditd
if systemctl is-active --quiet auditd; then
    EVENTS=$(ausearch --start today --raw 2>/dev/null | wc -l || echo "0")
    FAILED_AUTH=$(ausearch --start today --raw 2>/dev/null | grep -c "failed" || echo "0")
    
    echo "# TYPE auditd_events_total counter" >> "$TMP_FILE"
    echo "auditd_events_total $EVENTS" >> "$TMP_FILE"
    echo "auditd_events_total{type=\"failed_auth\"} $FAILED_AUTH" >> "$TMP_FILE"
fi

# Export AIDE
if [ -f /var/lib/aide/aide.db ]; then
    CHECKS=$(aide --check 2>/dev/null | grep -c "checked" || echo "0")
    VIOLATIONS=$(aide --check 2>/dev/null | grep -c "changed" || echo "0")
    
    echo "# TYPE aide_integrity_checks_total counter" >> "$TMP_FILE"
    echo "aide_integrity_checks_total $CHECKS" >> "$TMP_FILE"
    echo "# TYPE aide_integrity_violations_total counter" >> "$TMP_FILE"
    echo "aide_integrity_violations_total $VIOLATIONS" >> "$TMP_FILE"
fi

# Export Compliance
if [ -f "scripts/security/monitor-compliance.sh" ]; then
    SCORE=$(bash scripts/security/monitor-compliance.sh 2>&1 | grep "Score:" | awk '{print $NF}' | tr -d '%' || echo "0")
    echo "# TYPE compliance_score_overall gauge" >> "$TMP_FILE"
    echo "compliance_score_overall $SCORE" >> "$TMP_FILE"
fi

# Déplacer fichier temporaire vers final
mv "$TMP_FILE" "$METRICS_FILE"
EOF

chmod +x /usr/local/bin/export-security-metrics.sh

echo -e "${GREEN}  ✅ Script créé${NC}"

# ============================================================================
# 3. CRÉER TIMER SYSTEMD
# ============================================================================
echo -e "\n${YELLOW}[3/5] Création timer systemd...${NC}"

cat > /etc/systemd/system/export-security-metrics.service <<EOF
[Unit]
Description=Export Security Metrics to Prometheus
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/export-security-metrics.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/export-security-metrics.timer <<EOF
[Unit]
Description=Export Security Metrics Timer
Requires=export-security-metrics.service

[Timer]
OnBootSec=1min
OnUnitActiveSec=30s
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable export-security-metrics.timer
systemctl start export-security-metrics.timer

echo -e "${GREEN}  ✅ Timer créé et démarré${NC}"

# ============================================================================
# 4. CONFIGURER NODE EXPORTER
# ============================================================================
echo -e "\n${YELLOW}[4/5] Configuration Node Exporter...${NC}"

# Vérifier si node-exporter existe
if systemctl list-units | grep -q node-exporter; then
    # Ajouter option textfile
    NODE_EXPORTER_SERVICE="/etc/systemd/system/node-exporter.service"
    if [ -f "$NODE_EXPORTER_SERVICE" ]; then
        sed -i 's|ExecStart.*|& --collector.textfile.directory=/var/lib/prometheus/node-exporter|' "$NODE_EXPORTER_SERVICE" || true
        systemctl daemon-reload
        systemctl restart node-exporter || true
    fi
    echo -e "${GREEN}  ✅ Node Exporter configuré${NC}"
else
    echo -e "${YELLOW}  ⚠️  Node Exporter non trouvé${NC}"
fi

# ============================================================================
# 5. TEST EXPORT
# ============================================================================
echo -e "\n${YELLOW}[5/5] Test export métriques...${NC}"

/usr/local/bin/export-security-metrics.sh

if [ -f "$METRICS_DIR/security.prom" ]; then
    echo -e "${GREEN}  ✅ Métriques exportées${NC}"
    echo -e "${YELLOW}  Fichier: $METRICS_DIR/security.prom${NC}"
    echo -e "${YELLOW}  Lignes: $(wc -l < "$METRICS_DIR/security.prom")${NC}"
else
    echo -e "${YELLOW}  ⚠️  Export partiel${NC}"
fi

echo -e "\n${GREEN}=== SETUP TERMINÉ ===${NC}"
echo "Timer: systemctl status export-security-metrics.timer"
echo "Métriques: $METRICS_DIR/security.prom"
echo "Prometheus: Vérifier scrape_configs inclut node-exporter"
