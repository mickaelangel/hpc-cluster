#!/bin/bash
# ============================================================================
# Script d'Installation SUMA (SUSE Manager) - Cluster HPC
# Installation et configuration SUMA pour conformité et gestion des patches
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SUMA_SERVER="${SUMA_SERVER:-suma-internal.defense.local}"
RMT_SERVER="${RMT_SERVER:-exsus-repo.defense.local}"
MODE="${MODE:-server}"  # server ou client

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SUMA (SUSE Manager)${NC}"
echo -e "${GREEN}Mode: $MODE${NC}"
echo -e "${GREEN}Serveur: $SUMA_SERVER${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION SUMA SERVER
# ============================================================================
if [ "$MODE" == "server" ]; then
    echo -e "\n${YELLOW}[1/5] Installation SUMA Server...${NC}"
    
    # Installation SUSE Manager Server
    zypper install -y SUSE-Manager-Server || {
        echo -e "${RED}Erreur: Installation SUMA Server échouée${NC}"
        exit 1
    }
    
    # Configuration initiale
    echo -e "${YELLOW}Configuration SUMA Server...${NC}"
    echo -e "${YELLOW}Exécuter manuellement: mgr-setup${NC}"
    
    echo -e "${GREEN}  ✅ SUMA Server installé${NC}"
fi

# ============================================================================
# 2. INSTALLATION SUMA CLIENT (Salt Minion)
# ============================================================================
if [ "$MODE" == "client" ]; then
    echo -e "\n${YELLOW}[1/5] Installation SUMA Client (Salt Minion)...${NC}"
    
    # Installation Salt Minion
    zypper install -y salt-minion || {
        echo -e "${RED}Erreur: Installation Salt Minion échouée${NC}"
        exit 1
    }
    
    # Configuration Salt Minion
    cat > /etc/salt/minion.d/suma-defense.conf <<EOF
# Configuration Salt Minion pour SUMA Defense
master: ${SUMA_SERVER}
master_port: 4506

# Sécurité
verify_master_pubkey_sign: True
always_verify_signature: True

# Grains
grains:
  suma_server: ${SUMA_SERVER}
  cluster_role: $(hostname | cut -d- -f1)
EOF
    
    # Démarrage
    systemctl enable salt-minion
    systemctl start salt-minion
    
    echo -e "${GREEN}  ✅ Salt Minion installé et configuré${NC}"
fi

# ============================================================================
# 3. CONFIGURATION CHANNELS OFFLINE
# ============================================================================
echo -e "\n${YELLOW}[2/5] Configuration channels offline...${NC}"

# Créer répertoire pour patches
mkdir -p /var/spacewalk/packages/updates
mkdir -p /mnt/suma-sync

# Configuration pour synchronisation manuelle
cat > /etc/suma-sync.conf <<EOF
# Configuration SUMA Sync Offline
SUMA_SERVER=${SUMA_SERVER}
RMT_SERVER=${RMT_SERVER}
SYNC_DIR=/mnt/suma-sync
PACKAGES_DIR=/var/spacewalk/packages/updates
EOF

echo -e "${GREEN}  ✅ Channels offline configurés${NC}"

# ============================================================================
# 4. CONFIGURATION CONTENT LIFECYCLE MANAGEMENT
# ============================================================================
echo -e "\n${YELLOW}[3/5] Configuration Content Lifecycle Management...${NC}"

# Créer projet CLM pour validation patches
cat > /tmp/clm-project.yml <<EOF
project: HPC-Security-Updates
environments:
  - name: "dev"
    prior: null
  - name: "test"
    prior: "dev"
  - name: "prod"
    prior: "test"
filters:
  - name: "Security-Critical"
    rule: "cve"
    criteria: "severity >= 7"
EOF

echo -e "${GREEN}  ✅ CLM configuré${NC}"

# ============================================================================
# 5. CONFIGURATION AUDIT CVE
# ============================================================================
echo -e "\n${YELLOW}[4/5] Configuration audit CVE...${NC}"

# Cron pour audit CVE quotidien
cat > /etc/cron.d/suma-cve-audit <<EOF
# Audit CVE quotidien à 06:00
0 6 * * * root spacewalk-report cve-audit > /var/log/suma/cve-audit-\$(date +\%Y\%m\%d).log 2>&1
EOF

# Créer répertoire logs
mkdir -p /var/log/suma

echo -e "${GREEN}  ✅ Audit CVE configuré${NC}"

# ============================================================================
# 6. CONFIGURATION SALT STATES (si serveur)
# ============================================================================
if [ "$MODE" == "server" ]; then
    echo -e "\n${YELLOW}[5/5] Configuration Salt States...${NC}"
    
    # Créer structure Salt States
    mkdir -p /srv/salt/states/hpc-hardening
    mkdir -p /srv/salt/files
    
    # Salt State pour hardening HPC
    cat > /srv/salt/states/hpc-hardening/init.sls <<'EOF'
# Application DISA STIG via Salt
include:
  - stig.ssh-hardening
  - stig.audit-config
  - stig.file-permissions
  
hpc-specific:
  file.managed:
    - name: /etc/slurm/slurm.conf
    - source: salt://hpc/files/slurm.conf
    - user: slurm
    - group: slurm
    - mode: 644
    - check_cmd: slurmctld -t
EOF
    
    echo -e "${GREEN}  ✅ Salt States configurés${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== SUMA INSTALLÉ ===${NC}"
echo "Mode: $MODE"
echo "Serveur SUMA: $SUMA_SERVER"
echo ""
if [ "$MODE" == "server" ]; then
    echo -e "${YELLOW}PROCHAINES ÉTAPES:${NC}"
    echo "  1. Exécuter: mgr-setup"
    echo "  2. Configurer les channels"
    echo "  3. Synchroniser les patches depuis RMT"
    echo "  4. Configurer les clients"
elif [ "$MODE" == "client" ]; then
    echo -e "${YELLOW}PROCHAINES ÉTAPES:${NC}"
    echo "  1. Accepter la clé sur le serveur SUMA"
    echo "  2. Vérifier: salt-call test.ping"
    echo "  3. Appliquer les states: salt-call state.apply"
fi
echo ""
echo -e "${GREEN}Installation terminée!${NC}"
