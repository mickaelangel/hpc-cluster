#!/bin/bash
# ============================================================================
# Script de Configuration Chrony + PTP - Cluster HPC
# Synchronisation temps précise pour benchmarks et logs corrélés
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
CHRONY_SERVER="${CHRONY_SERVER:-frontal-01}"
NTP_SERVERS="${NTP_SERVERS:-}"
ENABLE_PTP="${ENABLE_PTP:-false}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION CHRONY + PTP${NC}"
echo -e "${GREEN}Serveur: $CHRONY_SERVER${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION CHRONY
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Chrony...${NC}"

zypper install -y chrony || {
    echo -e "${RED}Erreur: Installation Chrony échouée${NC}"
    exit 1
}

# ============================================================================
# 2. CONFIGURATION CHRONY
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Chrony...${NC}"

# Backup configuration existante
if [ -f /etc/chrony.conf ]; then
    cp /etc/chrony.conf /etc/chrony.conf.backup.$(date +%Y%m%d)
fi

# Configuration Chrony
cat > /etc/chrony.conf <<EOF
# Configuration Chrony - Cluster HPC
# Serveur de temps local (frontal-01)
server ${CHRONY_SERVER} iburst

# Serveurs NTP externes (si disponibles)
${NTP_SERVERS}

# Autoriser les clients du cluster
allow 192.168.100.0/24
allow 10.0.0.0/24
allow 10.10.10.0/24
allow 172.20.0.0/24
allow 172.16.0.0/24

# Stratum local
local stratum 10

# Logs
logdir /var/log/chrony
log measurements statistics tracking

# Drift file
driftfile /var/lib/chrony/drift

# Key file
keyfile /etc/chrony.keys

# Command key
commandkey 1

# Generate command key if missing
generatecommandkey

# RTConly
rtconutc

# Makestep
makestep 1.0 3
EOF

# ============================================================================
# 3. CONFIGURATION PTP (si activé)
# ============================================================================
if [ "$ENABLE_PTP" == "true" ]; then
    echo -e "\n${YELLOW}[3/3] Configuration PTP...${NC}"
    
    # Installation PTP
    zypper install -y linuxptp || {
        echo -e "${YELLOW}  ⚠️  PTP non disponible, ignoré${NC}"
    }
    
    # Configuration PTP (si interface réseau supporte)
    if [ -f /usr/sbin/ptp4l ]; then
        cat > /etc/ptp4l.conf <<EOF
# Configuration PTP4L
[global]
serverOnly 0
clockClass 248
clockAccuracy 0xFE
offsetScaledLogVariance 0xFFFF
priority1 128
priority2 128
domainNumber 0
EOF
        echo -e "${GREEN}  ✅ PTP configuré${NC}"
    fi
else
    echo -e "\n${YELLOW}[3/3] PTP désactivé${NC}"
fi

# ============================================================================
# DÉMARRAGE SERVICES
# ============================================================================
echo -e "\n${YELLOW}Démarrage services...${NC}"

systemctl enable chronyd
systemctl restart chronyd

if [ "$ENABLE_PTP" == "true" ] && systemctl list-unit-files | grep -q ptp4l; then
    systemctl enable ptp4l
    systemctl start ptp4l
fi

# ============================================================================
# VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}Vérification...${NC}"

# Vérifier Chrony
if chronyc sources > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Chrony fonctionnel${NC}"
    chronyc sources
    chronyc tracking
else
    echo -e "${RED}  ❌ Chrony non fonctionnel${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== CHRONY + PTP CONFIGURÉ ===${NC}"
echo "Serveur Chrony: $CHRONY_SERVER"
echo "PTP: $ENABLE_PTP"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Sur le serveur frontal, configurer comme serveur NTP"
echo "  - Vérifier la synchronisation: chronyc tracking"
echo ""
echo -e "${GREEN}Configuration terminée!${NC}"
