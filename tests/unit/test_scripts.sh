#!/bin/bash
# ============================================================================
# Tests Unitaires - Scripts Cluster HPC
# Usage: bash tests/unit/test_scripts.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

test_script_syntax() {
    local script=$1
    if bash -n "$script" 2>/dev/null; then
        echo -e "${GREEN}  ✅ $script${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}  ❌ $script${NC}"
        ((FAILED++))
        return 1
    fi
}

echo -e "${YELLOW}Tests de syntaxe des scripts...${NC}"

# Tester les scripts principaux
for script in install-all.sh cluster-start.sh cluster-stop.sh; do
    if [ -f "$script" ]; then
        test_script_syntax "$script"
    fi
done

# Tester les scripts dans scripts/
find scripts -name "*.sh" -type f | while read -r script; do
    test_script_syntax "$script"
done

echo ""
echo -e "${YELLOW}Résultats:${NC}"
echo -e "${GREEN}Passés: $PASSED${NC}"
echo -e "${RED}Échoués: $FAILED${NC}"

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
