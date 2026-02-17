#!/bin/bash
# ============================================================================
# Installation GNU Octave
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GNU OCTAVE${NC}"
echo -e "${GREEN}========================================${NC}"

# Installation
zypper install -y octave octave-devel

echo -e "${GREEN}✅ Octave installé${NC}"
echo "Test: octave --version"
