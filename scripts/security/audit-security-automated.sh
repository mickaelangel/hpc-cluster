#!/bin/bash
# ============================================================================
# Audit Sécurité Automatisé - Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

AUDIT_DIR="/var/log/security-audits"
DATE=$(date +%Y%m%d)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AUDIT SÉCURITÉ AUTOMATISÉ${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$AUDIT_DIR"

# Audit 1: Utilisateurs avec accès root
echo -e "\n${YELLOW}[1/5] Audit utilisateurs root...${NC}"
grep -E "^root:" /etc/passwd > "$AUDIT_DIR/users-root-$DATE.log"

# Audit 2: Services ouverts
echo -e "\n${YELLOW}[2/5] Audit services ouverts...${NC}"
netstat -tuln > "$AUDIT_DIR/services-open-$DATE.log"

# Audit 3: Permissions fichiers sensibles
echo -e "\n${YELLOW}[3/5] Audit permissions fichiers...${NC}"
find /etc -type f -perm -002 > "$AUDIT_DIR/files-world-writable-$DATE.log"

# Audit 4: Packages obsolètes
echo -e "\n${YELLOW}[4/5] Audit packages obsolètes...${NC}"
zypper list-updates > "$AUDIT_DIR/packages-updates-$DATE.log"

# Audit 5: Logs sécurité
echo -e "\n${YELLOW}[5/5] Audit logs sécurité...${NC}"
grep -i "failed\|denied\|unauthorized" /var/log/auth.log > "$AUDIT_DIR/auth-failures-$DATE.log" 2>/dev/null || true

echo -e "\n${GREEN}=== AUDIT TERMINÉ ===${NC}"
echo "Rapports: $AUDIT_DIR/"
