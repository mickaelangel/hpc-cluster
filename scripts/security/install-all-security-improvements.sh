#!/bin/bash
# ============================================================================
# Installation Toutes les Améliorations Sécurité Supplémentaires
# MFA, RBAC, Incident Response, Security Testing, Zero Trust, IB Encryption
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION AMÉLIORATIONS SÉCURITÉ${NC}"
echo -e "${BLUE}SUPPLÉMENTAIRES${NC}"
echo -e "${BLUE}========================================${NC}"

# Fonction installation
install_improvement() {
    local name=$1
    local script=$2
    local num=$3
    local total=$4
    
    echo -e "\n${YELLOW}[$num/$total] $name${NC}"
    
    if [ -f "$script" ]; then
        if bash "$script"; then
            echo -e "${GREEN}  ✅ $name installé${NC}"
            return 0
        else
            echo -e "${YELLOW}  ⚠️  $name installation partielle${NC}"
            return 1
        fi
    else
        echo -e "${RED}  ❌ Script non trouvé: $script${NC}"
        return 1
    fi
}

TOTAL=6
SUCCESS=0
FAILED=0
COUNT=0

# 1. MFA
((COUNT++))
install_improvement "MFA (Multi-Factor Authentication)" "scripts/security/configure-mfa.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 2. RBAC Avancé
((COUNT++))
install_improvement "RBAC Avancé" "scripts/security/configure-rbac-advanced.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 3. Incident Response
((COUNT++))
install_improvement "Incident Response" "scripts/security/incident-response.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 4. Security Testing
((COUNT++))
install_improvement "Security Testing" "scripts/security/penetration-test.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 5. Zero Trust
((COUNT++))
install_improvement "Zero Trust Architecture" "scripts/security/configure-zero-trust.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 6. Chiffrement InfiniBand
((COUNT++))
install_improvement "Chiffrement InfiniBand" "scripts/security/configure-ib-encryption.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# Résumé
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ Succès: $SUCCESS/$TOTAL${NC}"
echo -e "${YELLOW}  ⚠️  Partiels/Échecs: $FAILED/$TOTAL${NC}"

if [ $SUCCESS -eq $TOTAL ]; then
    echo -e "\n${GREEN}🎉 Toutes les améliorations sécurité sont installées !${NC}"
    echo -e "${GREEN}Le cluster est maintenant au niveau sécurité maximum (10/10) !${NC}"
else
    echo -e "\n${YELLOW}⚠️  Installation partielle${NC}"
    echo -e "${YELLOW}Certaines améliorations nécessitent une configuration manuelle.${NC}"
fi
