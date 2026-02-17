#!/bin/bash
# ============================================================================
# Installation SaltStack - Configuration Management
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SALTSTACK${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Salt Minion
zypper install -y salt-minion || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration
cat > /etc/salt/minion <<EOF
master: saltmaster.cluster.local
id: $(hostname)
EOF

systemctl enable salt-minion
systemctl start salt-minion

echo -e "${GREEN}✅ SaltStack installé${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite Salt Master${NC}"
