#!/bin/bash
# ============================================================================
# Installation Complète Stack Sécurité - Cluster HPC
# Installe toutes les améliorations de sécurité en une fois
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
echo -e "${BLUE}INSTALLATION STACK SÉCURITÉ COMPLÈTE${NC}"
echo -e "${BLUE}CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================================
# FONCTION INSTALLATION
# ============================================================================
install_security_component() {
    local name=$1
    local script=$2
    local num=$3
    
    echo -e "\n${YELLOW}[$num/$TOTAL] Installation: $name${NC}"
    
    if [ -f "$script" ]; then
        bash "$script" && {
            echo -e "${GREEN}  ✅ $name installé${NC}"
            return 0
        } || {
            echo -e "${YELLOW}  ⚠️  $name installation partielle${NC}"
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
COUNT=0

# 1. Hardening de base
((COUNT++)); install_security_component "Hardening Système" "scripts/security/hardening.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 2. Firewall
((COUNT++)); install_security_component "Firewall Avancé" "scripts/security/configure-firewall.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 3. IDS
((COUNT++)); install_security_component "Suricata IDS" "scripts/security/install-suricata.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_security_component "Wazuh SIEM" "scripts/security/install-wazuh.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_security_component "OSSEC HIDS" "scripts/security/install-ossec.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 4. Chiffrement
((COUNT++)); install_security_component "LUKS Chiffrement" "scripts/security/configure-luks.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 5. Vault
((COUNT++)); install_security_component "Vault Secrets" "scripts/security/install-vault.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 6. Certbot
((COUNT++)); install_security_component "Certbot SSL/TLS" "scripts/security/install-certbot.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 7. Containers
((COUNT++)); install_security_component "Falco Containers" "scripts/security/install-falco.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_security_component "Trivy Scan" "scripts/security/install-trivy.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 8. Export métriques
((COUNT++)); install_security_component "Export Métriques" "scripts/security/setup-metrics-exporter.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 9. Configuration Prometheus
((COUNT++)); install_security_component "Prometheus Sécurité" "scripts/security/configure-prometheus-security.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ INSTALLATION${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Réussies: $SUCCESS${NC}"
echo -e "${RED}❌ Échouées: $FAILED${NC}"
echo -e "${YELLOW}📊 Total: $TOTAL${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 TOUTES LES INSTALLATIONS RÉUSSIES !${NC}"
    echo -e "${GREEN}Le cluster est maintenant sécurisé au niveau Enterprise !${NC}"
else
    echo -e "\n${YELLOW}⚠️  Certaines installations nécessitent une configuration manuelle${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}PROCHAINES ÉTAPES${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}1. Initialiser Vault:${NC}"
echo -e "   vault operator init"
echo -e ""
echo -e "${YELLOW}2. Obtenir certificats:${NC}"
echo -e "   certbot certonly --standalone -d cluster.local"
echo -e ""
echo -e "${YELLOW}3. Configurer tâches quotidiennes:${NC}"
echo -e "   systemctl enable security-daily-tasks.timer"
echo -e ""
echo -e "${YELLOW}4. Accéder dashboards:${NC}"
echo -e "   http://frontal-01:3000 (Grafana)"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
