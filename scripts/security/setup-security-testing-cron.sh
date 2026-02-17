#!/bin/bash
# ============================================================================
# Configuration Tests de Sécurité Automatisés (Cron)
# Exécution régulière des tests de sécurité
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION TESTS SÉCURITÉ AUTOMATISÉS${NC}"
echo -e "${BLUE}========================================${NC}"

# Créer script cron pour tests quotidiens
cat > /usr/local/bin/security-daily-tests.sh <<'EOF'
#!/bin/bash
# Tests de sécurité quotidiens
REPORT_DIR="/var/log/security-tests/$(date +%Y%m%d)"
mkdir -p "$REPORT_DIR"

# Scan vulnérabilités
/opt/hpc-cluster/scripts/security/scan-vulnerabilities.sh > "$REPORT_DIR/vulnerabilities.log" 2>&1

# Test de pénétration (léger)
/opt/hpc-cluster/scripts/security/penetration-test.sh > "$REPORT_DIR/penetration.log" 2>&1

# Compliance check
/opt/hpc-cluster/scripts/security/monitor-compliance.sh > "$REPORT_DIR/compliance.log" 2>&1

# Audit sécurité
/opt/hpc-cluster/scripts/security/audit-security-automated.sh > "$REPORT_DIR/audit.log" 2>&1
EOF

chmod +x /usr/local/bin/security-daily-tests.sh

# Ajouter au cron (quotidien à 2h du matin)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/security-daily-tests.sh") | crontab -

echo -e "${GREEN}✅ Tests de sécurité automatisés configurés${NC}"
echo -e "${YELLOW}Exécution quotidienne à 2h du matin${NC}"
echo -e "${YELLOW}Rapports: /var/log/security-tests/${NC}"
