#!/bin/bash
# ============================================================================
# Installation Puppet - Configuration Management
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION PUPPET${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation Puppet
zypper install -y puppet || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration basique
cat > /etc/puppet/puppet.conf <<EOF
[main]
server = puppetmaster.cluster.local
certname = $(hostname)
EOF

echo -e "${GREEN}✅ Puppet installé${NC}"
echo -e "${YELLOW}⚠️  Configuration nécessite Puppet Master${NC}"
