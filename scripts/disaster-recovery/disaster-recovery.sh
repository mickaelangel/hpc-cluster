#!/bin/bash
# ============================================================================
# Script de Disaster Recovery - Cluster HPC
# Procédures de récupération en cas de catastrophe
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}DISASTER RECOVERY - CLUSTER HPC${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${YELLOW}ATTENTION: Ce script est pour les situations d'urgence${NC}"
echo -e "${YELLOW}Voulez-vous continuer? (yes/no)${NC}"
read -r response

if [ "$response" != "yes" ]; then
    echo "Annulé"
    exit 0
fi

# ============================================================================
# MENU DE RÉCUPÉRATION
# ============================================================================
echo ""
echo "Options de récupération:"
echo "  1) Restauration complète depuis backup"
echo "  2) Restauration LDAP uniquement"
echo "  3) Restauration Kerberos uniquement"
echo "  4) Restauration Slurm uniquement"
echo "  5) Restauration GPFS uniquement"
echo "  6) Vérification état actuel"
echo "  7) Quitter"
echo ""
echo -e "${YELLOW}Choisir une option (1-7):${NC}"
read -r option

case "$option" in
    1)
        echo -e "\n${YELLOW}Restauration complète...${NC}"
        echo -e "${YELLOW}Entrer le chemin de l'archive de backup:${NC}"
        read -r backup_path
        
        RESTORE_SCRIPT="$(dirname "$0")/../backup/restore-cluster.sh"
        if [ -f "$RESTORE_SCRIPT" ]; then
            "$RESTORE_SCRIPT" "$backup_path" || {
                echo -e "${RED}Erreur lors de la restauration${NC}"
                exit 1
            }
        else
            echo -e "${RED}Script de restauration non trouvé${NC}"
            exit 1
        fi
        ;;
    2)
        echo -e "\n${YELLOW}Restauration LDAP...${NC}"
        echo -e "${YELLOW}Entrer le chemin de l'archive de backup:${NC}"
        read -r backup_path
        
        RESTORE_SCRIPT="$(dirname "$0")/../backup/restore-cluster.sh"
        if [ -f "$RESTORE_SCRIPT" ]; then
            "$RESTORE_SCRIPT" "$backup_path" --selective ldap || {
                echo -e "${RED}Erreur lors de la restauration LDAP${NC}"
                exit 1
            }
        else
            echo -e "${RED}Script de restauration non trouvé${NC}"
            exit 1
        fi
        ;;
    3)
        echo -e "\n${YELLOW}Restauration Kerberos...${NC}"
        echo -e "${YELLOW}Entrer le chemin de l'archive de backup:${NC}"
        read -r backup_path
        
        RESTORE_SCRIPT="$(dirname "$0")/../backup/restore-cluster.sh"
        if [ -f "$RESTORE_SCRIPT" ]; then
            "$RESTORE_SCRIPT" "$backup_path" --selective kerberos || {
                echo -e "${RED}Erreur lors de la restauration Kerberos${NC}"
                exit 1
            }
        else
            echo -e "${RED}Script de restauration non trouvé${NC}"
            exit 1
        fi
        ;;
    4)
        echo -e "\n${YELLOW}Restauration Slurm...${NC}"
        echo -e "${YELLOW}Entrer le chemin de l'archive de backup:${NC}"
        read -r backup_path
        
        RESTORE_SCRIPT="$(dirname "$0")/../backup/restore-cluster.sh"
        if [ -f "$RESTORE_SCRIPT" ]; then
            "$RESTORE_SCRIPT" "$backup_path" --selective slurm || {
                echo -e "${RED}Erreur lors de la restauration Slurm${NC}"
                exit 1
            }
        else
            echo -e "${RED}Script de restauration non trouvé${NC}"
            exit 1
        fi
        ;;
    5)
        echo -e "\n${YELLOW}Restauration GPFS...${NC}"
        echo -e "${YELLOW}Entrer le chemin de l'archive de backup:${NC}"
        read -r backup_path
        
        RESTORE_SCRIPT="$(dirname "$0")/../backup/restore-cluster.sh"
        if [ -f "$RESTORE_SCRIPT" ]; then
            "$RESTORE_SCRIPT" "$backup_path" --selective gpfs || {
                echo -e "${RED}Erreur lors de la restauration GPFS${NC}"
                exit 1
            }
        else
            echo -e "${RED}Script de restauration non trouvé${NC}"
            exit 1
        fi
        ;;
    6)
        echo -e "\n${YELLOW}Vérification état actuel...${NC}"
        
        DIAGNOSE_SCRIPT="$(dirname "$0")/../troubleshooting/diagnose-cluster.sh"
        if [ -f "$DIAGNOSE_SCRIPT" ]; then
            "$DIAGNOSE_SCRIPT"
        else
            echo -e "${RED}Script de diagnostic non trouvé${NC}"
        fi
        ;;
    7)
        echo "Quitter"
        exit 0
        ;;
    *)
        echo -e "${RED}Option invalide${NC}"
        exit 1
        ;;
esac

# ============================================================================
# VÉRIFICATION POST-RÉCUPÉRATION
# ============================================================================
echo -e "\n${YELLOW}Vérification post-récupération...${NC}"

HEALTH_SCRIPT="$(dirname "$0")/../tests/test-cluster-health.sh"
if [ -f "$HEALTH_SCRIPT" ]; then
    "$HEALTH_SCRIPT" || {
        echo -e "${RED}Des problèmes détectés après récupération${NC}"
        echo -e "${YELLOW}Vérifier manuellement les services${NC}"
    }
fi

echo -e "\n${GREEN}=== RÉCUPÉRATION TERMINÉE ===${NC}"
echo -e "${YELLOW}Vérifier que tous les services fonctionnent correctement${NC}"
