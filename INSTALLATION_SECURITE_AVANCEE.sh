#!/bin/bash
# ============================================================================
# Installation Automatique Sécurité Avancée - Cluster HPC
# Script Master pour Installer Toutes les Améliorations de Sécurité
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION SÉCURITÉ AVANCÉE${NC}"
echo -e "${BLUE}CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================================
# FONCTION INSTALLATION
# ============================================================================
install_security() {
    local name=$1
    local script=$2
    local num=$3
    
    echo -e "\n${YELLOW}[$num/$TOTAL] Installation: $name${NC}"
    
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

TOTAL=6
SUCCESS=0
FAILED=0
COUNT=0

# 1. Firewall
((COUNT++)); install_security "Firewall Avancé" "scripts/security/configure-firewall.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 2. Vault
((COUNT++)); install_security "Vault (Gestion Secrets)" "scripts/security/install-vault.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 3. Certbot
((COUNT++)); install_security "Certbot (Certificats SSL/TLS)" "scripts/security/install-certbot.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 4. Falco
((COUNT++)); install_security "Falco (Sécurité Containers)" "scripts/security/install-falco.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 5. Trivy
((COUNT++)); install_security "Trivy (Scan Vulnérabilités)" "scripts/security/install-trivy.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# 6. Export métriques
((COUNT++)); install_security "Export Métriques Prometheus" "scripts/security/export-metrics-prometheus.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

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
    echo -e "${YELLOW}Consulter la documentation pour les détails${NC}"
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
echo -e "${YELLOW}3. Scanner vulnérabilités:${NC}"
echo -e "   ./scripts/security/scan-vulnerabilities.sh"
echo -e ""
echo -e "${YELLOW}4. Vérifier compliance:${NC}"
echo -e "   ./scripts/security/monitor-compliance.sh"
echo -e ""
echo -e "${YELLOW}5. Accéder dashboards:${NC}"
echo -e "   http://frontal-01:3000 (Grafana)"
echo -e "   Dashboards → Security Advanced"

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
