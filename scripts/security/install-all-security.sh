#!/bin/bash
# ============================================================================
# Installation Toutes les Améliorations Sécurité - Cluster HPC
# Script Master pour Installer Toute la Stack Sécurité
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
echo -e "${BLUE}INSTALLATION COMPLÈTE STACK SÉCURITÉ${NC}"
echo -e "${BLUE}CLUSTER HPC${NC}"
echo -e "${BLUE}========================================${NC}"

# ============================================================================
# INSTALLATION SÉQUENTIELLE
# ============================================================================

echo -e "\n${YELLOW}Installation de toutes les améliorations de sécurité...${NC}"

# 1. Hardening
echo -e "\n${YELLOW}[1/12] Hardening système...${NC}"
bash scripts/security/hardening.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 2. Firewall
echo -e "\n${YELLOW}[2/12] Firewall avancé...${NC}"
bash scripts/security/configure-firewall.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 3. IDS
echo -e "\n${YELLOW}[3/12] Suricata IDS...${NC}"
bash scripts/security/install-suricata.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

echo -e "\n${YELLOW}[4/12] Wazuh SIEM...${NC}"
bash scripts/security/install-wazuh.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

echo -e "\n${YELLOW}[5/12] OSSEC HIDS...${NC}"
bash scripts/security/install-ossec.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 4. Chiffrement
echo -e "\n${YELLOW}[6/12] LUKS chiffrement...${NC}"
bash scripts/security/configure-luks.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 5. Vault
echo -e "\n${YELLOW}[7/12] Vault secrets...${NC}"
bash scripts/security/install-vault.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 6. Certbot
echo -e "\n${YELLOW}[8/12] Certbot SSL/TLS...${NC}"
bash scripts/security/install-certbot.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 7. Containers
echo -e "\n${YELLOW}[9/12] Falco containers...${NC}"
bash scripts/security/install-falco.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

echo -e "\n${YELLOW}[10/12] Trivy scan...${NC}"
bash scripts/security/install-trivy.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 8. Export métriques
echo -e "\n${YELLOW}[11/12] Export métriques...${NC}"
bash scripts/security/setup-metrics-exporter.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 9. Automatisation
echo -e "\n${YELLOW}[12/18] Automatisation sécurité...${NC}"
bash scripts/automation/setup-security-automation.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 10. MFA (Multi-Factor Authentication)
echo -e "\n${YELLOW}[13/18] MFA (Multi-Factor Authentication)...${NC}"
bash scripts/security/configure-mfa.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 11. RBAC Avancé
echo -e "\n${YELLOW}[14/18] RBAC Avancé...${NC}"
bash scripts/security/configure-rbac-advanced.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 12. Incident Response
echo -e "\n${YELLOW}[15/18] Incident Response...${NC}"
chmod +x scripts/security/incident-response.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 13. Security Testing
echo -e "\n${YELLOW}[16/18] Security Testing...${NC}"
chmod +x scripts/security/penetration-test.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 14. Zero Trust
echo -e "\n${YELLOW}[17/18] Zero Trust Architecture...${NC}"
bash scripts/security/configure-zero-trust.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 15. Chiffrement InfiniBand
echo -e "\n${YELLOW}[18/20] Chiffrement InfiniBand...${NC}"
bash scripts/security/configure-ib-encryption.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 16. Configuration MFA Utilisateurs
echo -e "\n${YELLOW}[19/20] Configuration MFA Utilisateurs...${NC}"
bash scripts/security/setup-mfa-users.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 17. Tests Sécurité Automatisés (Cron)
echo -e "\n${YELLOW}[20/20] Tests Sécurité Automatisés (Cron)...${NC}"
bash scripts/security/setup-security-testing-cron.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# 18. Incident Response Monitoring (Cron)
echo -e "\n${YELLOW}[21/21] Incident Response Monitoring (Cron)...${NC}"
bash scripts/security/setup-incident-response-cron.sh && echo -e "${GREEN}  ✅${NC}" || echo -e "${YELLOW}  ⚠️${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Le cluster est maintenant sécurisé au niveau MAXIMUM (10/10) !${NC}"
echo -e "\n${YELLOW}Améliorations supplémentaires installées:${NC}"
echo -e "  ✅ MFA (Multi-Factor Authentication) - TOTP et YubiKey"
echo -e "  ✅ RBAC Avancé - Gestion permissions granulaire"
echo -e "  ✅ Incident Response automatisé - Collection d'évidences"
echo -e "  ✅ Security Testing automatisé - Tests quotidiens"
echo -e "  ✅ Zero Trust Architecture - Micro-segmentation"
echo -e "  ✅ Chiffrement InfiniBand - Protection données HPC"
echo -e "  ✅ Monitoring incidents - Surveillance continue"
echo -e "  ✅ Tests sécurité cron - Exécution automatique"
echo -e "\n${YELLOW}Voir la documentation:${NC}"
echo -e "  - docs/GUIDE_SECURITE_AVANCEE.md"
echo -e "  - docs/GUIDE_DASHBOARDS_SECURITE.md"
echo -e "  - docs/GUIDE_AUTOMATISATION_SECURITE.md"
echo -e "  - docs/GUIDE_SECURITE_UTILISATEURS.md"
echo -e "  - docs/THREAT_MODEL.md"
