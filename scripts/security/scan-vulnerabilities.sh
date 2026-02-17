#!/bin/bash
# ============================================================================
# Scan Vulnérabilités Complet - Cluster HPC
# Scan système, packages, containers
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPORT_DIR="/var/log/security-scans"
DATE=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SCAN VULNÉRABILITÉS COMPLET${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p "$REPORT_DIR"

# ============================================================================
# 1. SCAN PACKAGES SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[1/4] Scan packages système...${NC}"

# Scan avec zypper
zypper list-updates --security > "$REPORT_DIR/zypper-security-$DATE.txt" 2>&1 || true

# Scan avec rpm
rpm -qa --queryformat '%{NAME}-%{VERSION}-%{RELEASE}\n' | sort > "$REPORT_DIR/packages-$DATE.txt"

echo -e "${GREEN}  ✅ Scan packages terminé${NC}"

# ============================================================================
# 2. SCAN IMAGES DOCKER
# ============================================================================
echo -e "\n${YELLOW}[2/4] Scan images Docker...${NC}"

if command -v trivy &> /dev/null; then
    for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>"); do
        echo "  Scanning: $image"
        trivy image --format json --output "$REPORT_DIR/trivy-$(echo $image | tr '/:' '_')-$DATE.json" "$image" || true
    done
    echo -e "${GREEN}  ✅ Scan Docker terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  Trivy non installé${NC}"
fi

# ============================================================================
# 3. SCAN CONFIGURATION SÉCURITÉ
# ============================================================================
echo -e "\n${YELLOW}[3/4] Scan configuration sécurité...${NC}"

# Vérifier configuration SSH
sshd -T > "$REPORT_DIR/ssh-config-$DATE.txt" 2>&1 || true

# Vérifier firewall
if command -v nft &> /dev/null; then
    nft list ruleset > "$REPORT_DIR/nftables-$DATE.txt" 2>&1 || true
fi

if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --list-all > "$REPORT_DIR/firewalld-$DATE.txt" 2>&1 || true
fi

# Vérifier services
systemctl list-units --type=service --state=running > "$REPORT_DIR/services-$DATE.txt" 2>&1 || true

echo -e "${GREEN}  ✅ Scan configuration terminé${NC}"

# ============================================================================
# 4. RAPPORT FINAL
# ============================================================================
echo -e "\n${YELLOW}[4/4] Génération rapport final...${NC}"

cat > "$REPORT_DIR/scan-summary-$DATE.txt" <<EOF
# Scan Vulnérabilités - Résumé
Date: $(date)
Host: $(hostname)

## Packages à Mettre à Jour
$(cat "$REPORT_DIR/zypper-security-$DATE.txt" | grep -i security || echo "Aucune mise à jour de sécurité requise")

## Images Docker Scannées
$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | wc -l) images

## Fichiers Générés
$(ls -1 "$REPORT_DIR"/*-$DATE.* | wc -l) fichiers de rapport
EOF

echo -e "${GREEN}  ✅ Rapport généré${NC}"

echo -e "\n${GREEN}=== SCAN TERMINÉ ===${NC}"
echo "Rapports: $REPORT_DIR"
echo "Résumé: $REPORT_DIR/scan-summary-$DATE.txt"
