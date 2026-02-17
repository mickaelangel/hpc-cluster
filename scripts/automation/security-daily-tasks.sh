#!/bin/bash
# ============================================================================
# Tâches Sécurité Quotidiennes Automatisées
# Script à exécuter quotidiennement pour maintenir la sécurité
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

LOG_DIR="/var/log/security-daily"
DATE=$(date +%Y%m%d)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}TÂCHES SÉCURITÉ QUOTIDIENNES${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$LOG_DIR"

# ============================================================================
# 1. SCAN VULNÉRABILITÉS
# ============================================================================
echo -e "\n${YELLOW}[1/5] Scan vulnérabilités...${NC}"

if [ -f "scripts/security/scan-vulnerabilities.sh" ]; then
    bash scripts/security/scan-vulnerabilities.sh >> "$LOG_DIR/scan-$DATE.log" 2>&1
    echo -e "${GREEN}  ✅ Scan terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script scan non trouvé${NC}"
fi

# ============================================================================
# 2. MONITORING COMPLIANCE
# ============================================================================
echo -e "\n${YELLOW}[2/5] Monitoring compliance...${NC}"

if [ -f "scripts/security/monitor-compliance.sh" ]; then
    bash scripts/security/monitor-compliance.sh >> "$LOG_DIR/compliance-$DATE.log" 2>&1
    echo -e "${GREEN}  ✅ Compliance vérifiée${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script compliance non trouvé${NC}"
fi

# ============================================================================
# 3. SCAN TRIVY IMAGES
# ============================================================================
echo -e "\n${YELLOW}[3/5] Scan Trivy images Docker...${NC}"

if command -v trivy &> /dev/null; then
    /usr/local/bin/trivy-scan-images.sh >> "$LOG_DIR/trivy-$DATE.log" 2>&1 || true
    echo -e "${GREEN}  ✅ Scan Trivy terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  Trivy non installé${NC}"
fi

# ============================================================================
# 4. VÉRIFICATION AIDE
# ============================================================================
echo -e "\n${YELLOW}[4/5] Vérification intégrité AIDE...${NC}"

if [ -f /var/lib/aide/aide.db ]; then
    aide --check >> "$LOG_DIR/aide-$DATE.log" 2>&1 || {
        echo -e "${RED}  ⚠️  Violations d'intégrité détectées !${NC}"
    }
    echo -e "${GREEN}  ✅ Vérification AIDE terminée${NC}"
else
    echo -e "${YELLOW}  ⚠️  AIDE non configuré${NC}"
fi

# ============================================================================
# 5. EXPORT MÉTRIQUES
# ============================================================================
echo -e "\n${YELLOW}[5/5] Export métriques sécurité...${NC}"

if [ -f /usr/local/bin/export-security-metrics.sh ]; then
    /usr/local/bin/export-security-metrics.sh >> "$LOG_DIR/metrics-$DATE.log" 2>&1
    echo -e "${GREEN}  ✅ Métriques exportées${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script export non trouvé${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== TÂCHES QUOTIDIENNES TERMINÉES ===${NC}"
echo "Logs: $LOG_DIR/"
echo "Date: $DATE"

# Nettoyer logs anciens (garder 30 jours)
find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null || true
