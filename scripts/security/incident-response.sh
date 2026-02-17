#!/bin/bash
# ============================================================================
# Incident Response Automatisé - Cluster HPC
# Collection d'Évidences et Analyse
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INCIDENT_DIR="/var/log/incidents/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$INCIDENT_DIR/logs"

echo -e "${RED}========================================${NC}"
echo -e "${RED}INCIDENT RESPONSE${NC}"
echo -e "${RED}========================================${NC}"

# 1. Collection Logs
echo -e "\n${YELLOW}[1/5] Collection Logs...${NC}"
cp -r /var/log/* "$INCIDENT_DIR/logs/" 2>/dev/null || true
journalctl --since "24 hours ago" > "$INCIDENT_DIR/systemd.log" 2>/dev/null || true

# 2. Collection Processus
echo -e "\n${YELLOW}[2/5] Collection Processus...${NC}"
ps aux > "$INCIDENT_DIR/processes.txt"
netstat -tulpn > "$INCIDENT_DIR/network.txt" 2>/dev/null || ss -tulpn > "$INCIDENT_DIR/network.txt"

# 3. Collection Fichiers Système
echo -e "\n${YELLOW}[3/5] Collection Fichiers Système...${NC}"
cp /etc/passwd "$INCIDENT_DIR/"
cp /etc/shadow "$INCIDENT_DIR/" 2>/dev/null || true
cp /etc/group "$INCIDENT_DIR/"
cp /etc/sudoers "$INCIDENT_DIR/"

# 4. Collection Sécurité
echo -e "\n${YELLOW}[4/5] Collection Sécurité...${NC}"
if [ -f /var/log/fail2ban.log ]; then
    tail -1000 /var/log/fail2ban.log > "$INCIDENT_DIR/fail2ban.log"
fi
if [ -f /var/log/audit/audit.log ]; then
    tail -1000 /var/log/audit/audit.log > "$INCIDENT_DIR/audit.log"
fi

# 5. Hash des Fichiers Critiques
echo -e "\n${YELLOW}[5/5] Hash Fichiers Critiques...${NC}"
find /etc -type f -exec sha256sum {} \; > "$INCIDENT_DIR/hashes.txt" 2>/dev/null

# Créer archive
echo -e "\n${YELLOW}Création archive...${NC}"
tar -czf "$INCIDENT_DIR/../incident-$(date +%Y%m%d_%H%M%S).tar.gz" -C "$INCIDENT_DIR" .

echo -e "\n${GREEN}✅ Incident response terminé${NC}"
echo -e "${YELLOW}Archive: $INCIDENT_DIR/../incident-*.tar.gz${NC}"
