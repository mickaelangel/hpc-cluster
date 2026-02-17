#!/bin/bash
# ============================================================================
# Export Métriques Sécurité vers Prometheus
# Script pour exporter métriques sécurité (Fail2ban, Auditd, Firewall, etc.)
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

EXPORTER_DIR="/opt/prometheus-exporters"
METRICS_FILE="/var/lib/prometheus/node-exporter/security.prom"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}EXPORT MÉTRIQUES SÉCURITÉ${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$(dirname "$METRICS_FILE")"

# ============================================================================
# FONCTION EXPORT MÉTRIQUE
# ============================================================================
export_metric() {
    local name=$1
    local value=$2
    local labels=${3:-}
    
    if [ -n "$labels" ]; then
        echo "# TYPE $name gauge" >> "$METRICS_FILE"
        echo "$name{$labels} $value" >> "$METRICS_FILE"
    else
        echo "# TYPE $name gauge" >> "$METRICS_FILE"
        echo "$name $value" >> "$METRICS_FILE"
    fi
}

# ============================================================================
# EXPORT MÉTRIQUES FAIL2BAN
# ============================================================================
echo -e "\n${YELLOW}[1/5] Export métriques Fail2ban...${NC}"

if systemctl is-active --quiet fail2ban; then
    BANNED_IPS=$(fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $NF}' || echo "0")
    FAILED_ATTEMPTS=$(grep -c "Failed password" /var/log/auth.log 2>/dev/null || echo "0")
    
    export_metric "fail2ban_banned_ips" "$BANNED_IPS"
    export_metric "fail2ban_ssh_failed_total" "$FAILED_ATTEMPTS"
    
    echo -e "${GREEN}  ✅ Métriques Fail2ban exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Fail2ban non actif${NC}"
fi

# ============================================================================
# EXPORT MÉTRIQUES FIREWALL
# ============================================================================
echo -e "\n${YELLOW}[2/5] Export métriques Firewall...${NC}"

if command -v nft &> /dev/null; then
    DROPS=$(nft list ruleset | grep -c "drop" || echo "0")
    ACCEPTS=$(nft list ruleset | grep -c "accept" || echo "0")
    
    export_metric "firewall_drops_total" "$DROPS"
    export_metric "firewall_accepts_total" "$ACCEPTS"
    
    echo -e "${GREEN}  ✅ Métriques Firewall exportées${NC}"
elif command -v iptables &> /dev/null; then
    DROPS=$(iptables -L -n -v | grep DROP | awk '{sum+=$1} END {print sum}' || echo "0")
    ACCEPTS=$(iptables -L -n -v | grep ACCEPT | awk '{sum+=$1} END {print sum}' || echo "0")
    
    export_metric "firewall_drops_total" "$DROPS"
    export_metric "firewall_accepts_total" "$ACCEPTS"
    
    echo -e "${GREEN}  ✅ Métriques Firewall exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Firewall non configuré${NC}"
fi

# ============================================================================
# EXPORT MÉTRIQUES AUDITD
# ============================================================================
echo -e "\n${YELLOW}[3/5] Export métriques Auditd...${NC}"

if systemctl is-active --quiet auditd; then
    AUDIT_EVENTS=$(ausearch --start today --raw 2>/dev/null | wc -l || echo "0")
    FAILED_AUTH=$(ausearch --start today --raw 2>/dev/null | grep -c "failed" || echo "0")
    
    export_metric "auditd_events_total" "$AUDIT_EVENTS"
    export_metric "auditd_events_total" "$FAILED_AUTH" "type=\"failed_auth\""
    
    echo -e "${GREEN}  ✅ Métriques Auditd exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Auditd non actif${NC}"
fi

# ============================================================================
# EXPORT MÉTRIQUES AIDE
# ============================================================================
echo -e "\n${YELLOW}[4/5] Export métriques AIDE...${NC}"

if [ -f /var/lib/aide/aide.db ]; then
    INTEGRITY_CHECKS=$(aide --check 2>/dev/null | grep -c "checked" || echo "0")
    INTEGRITY_VIOLATIONS=$(aide --check 2>/dev/null | grep -c "changed" || echo "0")
    
    export_metric "aide_integrity_checks_total" "$INTEGRITY_CHECKS"
    export_metric "aide_integrity_violations_total" "$INTEGRITY_VIOLATIONS"
    
    echo -e "${GREEN}  ✅ Métriques AIDE exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  AIDE non configuré${NC}"
fi

# ============================================================================
# EXPORT MÉTRIQUES COMPLIANCE
# ============================================================================
echo -e "\n${YELLOW}[5/5] Export métriques Compliance...${NC}"

# Exécuter script compliance
if [ -f "scripts/security/monitor-compliance.sh" ]; then
    COMPLIANCE_REPORT=$(bash scripts/security/monitor-compliance.sh 2>&1 | grep "Score:" | awk '{print $NF}' | tr -d '%' || echo "0")
    
    export_metric "compliance_score_overall" "$COMPLIANCE_REPORT"
    
    echo -e "${GREEN}  ✅ Métriques Compliance exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script compliance non trouvé${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== MÉTRIQUES EXPORTÉES ===${NC}"
echo "Fichier: $METRICS_FILE"
echo "Lignes: $(wc -l < "$METRICS_FILE")"

# Configurer Node Exporter pour lire ce fichier
# Ajouter dans node-exporter: --collector.textfile.directory=/var/lib/prometheus/node-exporter
