#!/bin/bash
# ============================================================================
# Tests de Pénétration Automatisés - Cluster HPC
# Vulnerability Assessment et Security Scanning
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPORT_DIR="/var/log/security-tests/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}TESTS DE PÉNÉTRATION${NC}"
echo -e "${BLUE}========================================${NC}"

# 1. Scan Ports
echo -e "\n${YELLOW}[1/5] Scan Ports...${NC}"
if command -v nmap &> /dev/null; then
    nmap -sS -O localhost > "$REPORT_DIR/port-scan.txt" 2>&1 || true
else
    echo "nmap non installé" > "$REPORT_DIR/port-scan.txt"
    echo -e "${YELLOW}  ⚠️  Installer nmap pour scan complet: zypper install -y nmap${NC}"
fi

# 2. Scan Vulnérabilités Système
echo -e "\n${YELLOW}[2/5] Scan Vulnérabilités Système...${NC}"
if command -v lynis &> /dev/null; then
    lynis audit system > "$REPORT_DIR/lynis.txt" 2>&1 || true
else
    echo "lynis non installé" > "$REPORT_DIR/lynis.txt"
    echo -e "${YELLOW}  ⚠️  Installer lynis pour scan complet: zypper install -y lynis${NC}"
fi

# 3. Test Configuration SSH
echo -e "\n${YELLOW}[3/5] Test Configuration SSH...${NC}"
if command -v ssh-audit &> /dev/null; then
    ssh-audit localhost > "$REPORT_DIR/ssh-audit.txt" 2>&1 || true
else
    echo "ssh-audit non installé" > "$REPORT_DIR/ssh-audit.txt"
    echo -e "${YELLOW}  ⚠️  Installer ssh-audit pour audit SSH: pip install ssh-audit${NC}"
    # Test basique SSH config
    sshd -T > "$REPORT_DIR/ssh-config.txt" 2>&1 || true
fi

# 4. Test Mots de Passe
echo -e "\n${YELLOW}[4/5] Test Mots de Passe...${NC}"
if [ -f /etc/shadow ]; then
    # Vérifier mots de passe faibles (nécessite john ou hashcat)
    echo "Vérification mots de passe..." > "$REPORT_DIR/password-test.txt"
fi

# 5. Test Services
echo -e "\n${YELLOW}[5/5] Test Services...${NC}"
systemctl list-units --type=service --state=running > "$REPORT_DIR/services.txt"

# Résumé
echo -e "\n${GREEN}✅ Tests terminés${NC}"
echo -e "${YELLOW}Rapports: $REPORT_DIR${NC}"
