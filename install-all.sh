#!/bin/bash
# ============================================================================
# Installation Complète Cluster HPC - Script Master
# Orchestre l'installation de TOUT le cluster HPC
# ============================================================================

set -uo pipefail
# Note: pas de 'set -e' pour permettre à l'installation de continuer même si une étape échoue (report en fin)

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION COMPLÈTE CLUSTER HPC${NC}"
echo -e "${BLUE}Script Master - Orchestration Totale${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================================================
# FONCTION INSTALLATION
# ============================================================================
install_step() {
    local name=$1
    local script=$2
    local num=$3
    local total=$4
    
    echo -e "\n${CYAN}[$num/$total] $name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$script" ]; then
        if bash "$script" < /dev/null; then
            echo -e "${GREEN}  ✅ $name terminé${NC}"
            return 0
        else
            echo -e "${YELLOW}  ⚠️  $name partiel (peut nécessiter configuration manuelle)${NC}"
            return 1
        fi
    else
        echo -e "${RED}  ❌ Script non trouvé: $script${NC}"
        return 1
    fi
}

# ============================================================================
# VÉRIFICATION PRÉREQUIS
# ============================================================================
echo -e "${BLUE}[0/10] Vérification des prérequis...${NC}"

# Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}  ❌ Docker n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ Docker: $(docker --version)${NC}"

# Docker Compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    echo -e "${GREEN}  ✅ Docker Compose: $(docker-compose --version)${NC}"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
    echo -e "${GREEN}  ✅ Docker Compose: $(docker compose version)${NC}"
else
    echo -e "${RED}  ❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

# Permissions
if ! docker ps &> /dev/null; then
    echo -e "${RED}  ❌ Pas de permissions pour Docker (utilisez sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Prérequis OK${NC}"

# ============================================================================
# INSTALLATION SÉQUENTIELLE
# ============================================================================

TOTAL=10
SUCCESS=0
FAILED=0
COUNT=0

# 1. Base Docker
((COUNT++))
install_step "Installation Base Docker" "scripts/INSTALL.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 2. Authentification (FreeIPA par défaut en non-interactif)
echo -e "\n${CYAN}[$COUNT/$TOTAL] Configuration Authentification${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
AUTH_CHOICE="${AUTH_CHOICE:-2}"
if [ -t 0 ]; then
    echo -e "${YELLOW}Choisir l'authentification:${NC}"
    echo "  1) LDAP + Kerberos"
    echo "  2) FreeIPA (recommandé)"
    read -p "Votre choix (1 ou 2) [2]: " input
    AUTH_CHOICE="${input:-2}"
fi
echo -e "  Choix: $AUTH_CHOICE (1=LDAP+Kerberos, 2=FreeIPA)"

if [ "$AUTH_CHOICE" = "1" ]; then
    ((COUNT++))
    install_step "Installation LDAP + Kerberos" "scripts/install-ldap-kerberos.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))
elif [ "$AUTH_CHOICE" = "2" ]; then
    ((COUNT++))
    install_step "Installation FreeIPA" "scripts/install-freeipa.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))
else
    echo -e "${YELLOW}  ⚠️  Choix invalide, authentification ignorée${NC}"
    ((COUNT++))
    ((FAILED++))
fi

# 3. Applications Scientifiques
((COUNT++))
install_step "Installation Applications Scientifiques" "scripts/applications/install-all-scientific-apps.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 4. Bases de Données
((COUNT++))
install_step "Installation Bases de Données" "scripts/database/install-postgresql.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 5. Monitoring
((COUNT++))
install_step "Configuration Monitoring Complet" "scripts/automation/setup-all-monitoring.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 6. Sécurité
((COUNT++))
install_step "Installation Sécurité Enterprise" "scripts/security/install-all-security.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 6b. Améliorations Sécurité Supplémentaires (optionnel)
INSTALL_SEC_IMPROV="${INSTALL_SEC_IMPROV:-N}"
if [ -t 0 ]; then
    read -p "Installer les améliorations sécurité supplémentaires (MFA, RBAC, etc.) ? (y/N): " INSTALL_SEC_IMPROV
fi
if [[ "${INSTALL_SEC_IMPROV:-N}" =~ ^[Yy]$ ]]; then
    ((COUNT++))
    install_step "Améliorations Sécurité Supplémentaires" "scripts/security/install-all-security-improvements.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))
fi

# 7. Big Data & ML
((COUNT++))
install_step "Installation Big Data & ML" "scripts/bigdata/install-spark.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 8. Automatisation
((COUNT++))
install_step "Configuration Automatisation" "scripts/automation/setup-cron-all-monitoring.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 9. Tests
((COUNT++))
install_step "Tests de Validation" "scripts/tests/test-cluster-health.sh" $COUNT $TOTAL && ((SUCCESS++)) || ((FAILED++))

# 10. Vérification Finale
((COUNT++))
echo -e "\n${CYAN}[$COUNT/$TOTAL] Vérification Finale${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Vérifier services Docker
if docker ps | grep -q "prometheus\|grafana"; then
    echo -e "${GREEN}  ✅ Services Docker actifs${NC}"
    ((SUCCESS++))
else
    echo -e "${YELLOW}  ⚠️  Services Docker non détectés${NC}"
    ((FAILED++))
fi

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RÉSUMÉ INSTALLATION${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  ✅ Succès: $SUCCESS/$TOTAL${NC}"
echo -e "${YELLOW}  ⚠️  Partiels/Échecs: $FAILED/$TOTAL${NC}"
echo ""

if [ $SUCCESS -eq $TOTAL ]; then
    echo -e "${GREEN}🎉 INSTALLATION COMPLÈTE RÉUSSIE !${NC}"
    echo ""
    echo -e "${CYAN}Services disponibles:${NC}"
    echo -e "  - Prometheus: http://localhost:9090"
    echo -e "  - Grafana: http://localhost:3000 (admin / demo-hpc-2024)"
    echo -e "  - Frontaux: SSH sur ports 2222, 2223"
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo -e "  - Index complet: DOCUMENTATION_COMPLETE_INDEX_300_ETAPES.md"
    echo -e "  - Guide installation: docs/GUIDE_INSTALLATION_COMPLETE_300_ETAPES.md"
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️  Installation partielle${NC}"
    echo -e "${YELLOW}Certaines étapes nécessitent une configuration manuelle.${NC}"
    echo -e "${YELLOW}Consultez la documentation pour les détails.${NC}"
    echo ""
    exit 1
fi
