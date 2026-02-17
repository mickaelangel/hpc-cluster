#!/bin/bash
# ============================================================================
# Installation Nagios - Monitoring Infrastructure
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION NAGIOS${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y nagios nagios-plugins-all || {
    echo -e "${YELLOW}⚠️  Installation échouée${NC}"
}

# Configuration basique
systemctl enable nagios
systemctl start nagios

echo -e "${GREEN}✅ Nagios installé${NC}"
echo "URL: http://localhost/nagios"
echo "Login: nagiosadmin / password"
