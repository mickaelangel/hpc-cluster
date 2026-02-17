#!/bin/bash
# ============================================================================
# Installation Sécurité Niveau Maximum (10/10) - Cluster HPC
# Script Master pour Installer Toutes les Améliorations Sécurité
# ============================================================================

set -euo pipefail

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
echo -e "${BLUE}INSTALLATION SÉCURITÉ NIVEAU MAXIMUM${NC}"
echo -e "${BLUE}10/10 - TOUTES LES AMÉLIORATIONS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Vérification prérequis
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Ce script doit être exécuté en tant que root (sudo)${NC}"
    exit 1
fi

# Installation complète sécurité
echo -e "${CYAN}Installation de toutes les améliorations sécurité...${NC}"
echo ""

bash scripts/security/install-all-security.sh

# Résumé final
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}INSTALLATION TERMINÉE${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Le cluster est maintenant sécurisé au niveau MAXIMUM (10/10) !${NC}"
echo ""
echo -e "${CYAN}Améliorations installées:${NC}"
echo -e "  ✅ Hardening complet (DISA STIG, CIS Level 2, ANSSI BP-028)"
echo -e "  ✅ Firewall multi-technologies (nftables, firewalld, iptables)"
echo -e "  ✅ IDS/SIEM (Suricata, Wazuh, OSSEC)"
echo -e "  ✅ Chiffrement (LUKS, EncFS, GPG, TLS)"
echo -e "  ✅ Gestion secrets (Vault)"
echo -e "  ✅ Sécurité containers (Falco, Trivy)"
echo -e "  ✅ Compliance monitoring"
echo -e "  ✅ VPN (WireGuard, IPSec)"
echo -e "  ✅ MFA (Multi-Factor Authentication)"
echo -e "  ✅ RBAC Avancé"
echo -e "  ✅ Incident Response automatisé"
echo -e "  ✅ Security Testing automatisé"
echo -e "  ✅ Zero Trust Architecture"
echo -e "  ✅ Chiffrement InfiniBand"
echo ""
echo -e "${CYAN}Documentation:${NC}"
echo -e "  - docs/GUIDE_SECURITE_AVANCEE.md"
echo -e "  - docs/GUIDE_SECURITE_UTILISATEURS.md"
echo -e "  - docs/THREAT_MODEL.md"
echo -e "  - SECURITE_NIVEAU_MAXIMUM.md"
echo ""
echo -e "${GREEN}Le cluster est prêt pour les environnements les plus critiques !${NC}"
