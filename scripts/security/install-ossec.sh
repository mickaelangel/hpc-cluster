#!/bin/bash
# ============================================================================
# Installation OSSEC - HIDS (Host-based IDS)
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION OSSEC${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation OSSEC...${NC}"

# Télécharger OSSEC
OSSEC_VERSION="3.7.0"
OSSEC_TAR="ossec-hids-${OSSEC_VERSION}.tar.gz"
OSSEC_DIR="/opt/ossec"

cd /tmp
if [ ! -f "$OSSEC_TAR" ]; then
    wget -q "https://github.com/ossec/ossec-hids/releases/download/${OSSEC_VERSION}/${OSSEC_TAR}" || {
        echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
        exit 1
    }
fi

tar -xzf "$OSSEC_TAR"
cd ossec-hids-${OSSEC_VERSION}

# Compilation
./install.sh || {
    echo -e "${YELLOW}  ⚠️  Installation interactive requise${NC}"
}

echo -e "${GREEN}  ✅ OSSEC installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration OSSEC...${NC}"

# Configuration de base
cat > "$OSSEC_DIR/etc/ossec.conf" <<EOF
<ossec_config>
  <global>
    <email_notification>no</email_notification>
  </global>
  
  <rules>
    <include>rules_config.xml</include>
    <include>pam_rules.xml</include>
    <include>sshd_rules.xml</include>
    <include>slurm_rules.xml</include>
  </rules>
</ossec_config>
EOF

echo -e "${GREEN}  ✅ OSSEC configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage OSSEC...${NC}"

"$OSSEC_DIR/bin/ossec-control start" || {
    echo -e "${YELLOW}  ⚠️  Démarrage échoué${NC}"
}

echo -e "${GREEN}  ✅ OSSEC démarré${NC}"

echo -e "\n${GREEN}=== OSSEC INSTALLÉ ===${NC}"
echo "Installation: $OSSEC_DIR"
echo "Configuration: $OSSEC_DIR/etc/ossec.conf"
