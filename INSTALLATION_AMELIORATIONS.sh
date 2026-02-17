#!/bin/bash
# ============================================================================
# Installation Automatique de Toutes les Améliorations
# Script Master pour Installer Toutes les Améliorations en Une Fois
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION AUTOMATIQUE${NC}"
echo -e "${BLUE}TOUTES LES AMÉLIORATIONS${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================================
# FONCTION INSTALLATION
# ============================================================================
install_improvement() {
    local name=$1
    local script=$2
    
    echo -e "\n${YELLOW}[$3/$TOTAL] Installation: $name${NC}"
    
    if [ -f "$script" ]; then
        bash "$script" && {
            echo -e "${GREEN}  ✅ $name installé${NC}"
            return 0
        } || {
            echo -e "${YELLOW}  ⚠️  $name installation partielle (peut nécessiter configuration manuelle)${NC}"
            return 1
        }
    else
        echo -e "${RED}  ❌ Script non trouvé: $script${NC}"
        return 1
    fi
}

# ============================================================================
# INSTALLATION SÉQUENTIELLE
# ============================================================================

TOTAL=10
SUCCESS=0
FAILED=0

# 1. Tests
install_improvement "Tests Infrastructure" "scripts/tests/test-infrastructure.sh" 1 && ((SUCCESS++)) || ((FAILED++))
install_improvement "Tests Applications" "scripts/tests/test-applications.sh" 2 && ((SUCCESS++)) || ((FAILED++))
install_improvement "Tests Intégration" "scripts/tests/test-integration.sh" 3 && ((SUCCESS++)) || ((FAILED++))

# 2. Backup
install_improvement "Backup BorgBackup" "scripts/backup/backup-borg.sh" 4 && ((SUCCESS++)) || ((FAILED++))

# 3. Sécurité
install_improvement "Suricata IDS" "scripts/security/install-suricata.sh" 5 && ((SUCCESS++)) || ((FAILED++))
install_improvement "Wazuh SIEM" "scripts/security/install-wazuh.sh" 6 && ((SUCCESS++)) || ((FAILED++))
install_improvement "LUKS Chiffrement" "scripts/security/configure-luks.sh" 7 && ((SUCCESS++)) || ((FAILED++))

# 4. Monitoring
install_improvement "Jaeger Tracing" "scripts/monitoring/install-jaeger.sh" 8 && ((SUCCESS++)) || ((FAILED++))
install_improvement "OpenTelemetry" "scripts/monitoring/install-opentelemetry.sh" 9 && ((SUCCESS++)) || ((FAILED++))

# 5. CI/CD
install_improvement "GitLab CI" "scripts/ci-cd/install-gitlab-ci.sh" 10 && ((SUCCESS++)) || ((FAILED++))

# 6. IaC
install_improvement "Terraform" "scripts/iac/install-terraform.sh" 11 && ((SUCCESS++)) || ((FAILED++))

# 7. API Gateway
install_improvement "Kong API Gateway" "scripts/api/install-kong.sh" 12 && ((SUCCESS++)) || ((FAILED++))

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ INSTALLATION${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Réussies: $SUCCESS${NC}"
echo -e "${RED}❌ Échouées: $FAILED${NC}"
echo -e "${YELLOW}📊 Total: $((SUCCESS + FAILED))${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUTES LES INSTALLATIONS RÉUSSIES !${NC}"
else
    echo -e "\n${YELLOW}⚠️  Certaines installations nécessitent une configuration manuelle${NC}"
    echo -e "${YELLOW}Consulter la documentation pour les détails${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
