#!/bin/bash
# ============================================================================
# Installation Automatique de Toutes les Améliorations - COMPLÈTE
# Script Master pour Installer Toutes les 24 Améliorations
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
echo -e "${BLUE}INSTALLATION AUTOMATIQUE COMPLÈTE${NC}"
echo -e "${BLUE}TOUTES LES 24 AMÉLIORATIONS${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================================
# FONCTION INSTALLATION
# ============================================================================
install_improvement() {
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

TOTAL=24
SUCCESS=0
FAILED=0
COUNT=0

# Tests
((COUNT++)); install_improvement "Tests Infrastructure" "scripts/tests/test-infrastructure.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Tests Applications" "scripts/tests/test-applications.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Tests Intégration" "scripts/tests/test-integration.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Backup
((COUNT++)); install_improvement "Backup BorgBackup" "scripts/backup/backup-borg.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Sécurité
((COUNT++)); install_improvement "Suricata IDS" "scripts/security/install-suricata.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Wazuh SIEM" "scripts/security/install-wazuh.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "OSSEC HIDS" "scripts/security/install-ossec.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "LUKS Chiffrement" "scripts/security/configure-luks.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "EncFS Chiffrement" "scripts/security/configure-encfs.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "GPG Chiffrement" "scripts/security/configure-gpg.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Monitoring
((COUNT++)); install_improvement "Jaeger Tracing" "scripts/monitoring/install-jaeger.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "OpenTelemetry" "scripts/monitoring/install-opentelemetry.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Elasticsearch" "scripts/monitoring/install-elasticsearch.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Kibana" "scripts/monitoring/install-kibana.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "VictoriaMetrics" "scripts/monitoring/install-victoriametrics.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Performance
((COUNT++)); install_improvement "Redis Cache" "scripts/performance/install-redis.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Tuned Performance" "scripts/performance/configure-tuned.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "DPDK" "scripts/performance/install-dpdk.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Automatisation
((COUNT++)); install_improvement "GitLab CI" "scripts/ci-cd/install-gitlab-ci.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Terraform IaC" "scripts/iac/install-terraform.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Intégration
((COUNT++)); install_improvement "Kong API Gateway" "scripts/api/install-kong.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "RabbitMQ" "scripts/messaging/install-rabbitmq.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Kafka" "scripts/messaging/install-kafka.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

# Avancé
((COUNT++)); install_improvement "Kubernetes" "scripts/automation/install-kubernetes.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))
((COUNT++)); install_improvement "Istio Service Mesh" "scripts/service-mesh/install-istio.sh" $COUNT && ((SUCCESS++)) || ((FAILED++))

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
else
    echo -e "\n${YELLOW}⚠️  Certaines installations nécessitent une configuration manuelle${NC}"
    echo -e "${YELLOW}Consulter la documentation pour les détails${NC}"
fi

echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
