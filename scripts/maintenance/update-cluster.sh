#!/bin/bash
# ============================================================================
# Script de Mise à Jour - Cluster HPC
# Mise à jour sécurisée des services et packages
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MISE À JOUR CLUSTER HPC${NC}"
echo -e "${GREEN}Date: $(date)${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. BACKUP AVANT MISE À JOUR
# ============================================================================
echo -e "\n${YELLOW}[1/5] Backup avant mise à jour...${NC}"

BACKUP_SCRIPT="$(dirname "$0")/../backup/backup-cluster.sh"
if [ -f "$BACKUP_SCRIPT" ]; then
    "$BACKUP_SCRIPT" || {
        echo -e "${RED}  ⚠️  Backup échoué, continuer quand même? (y/n)${NC}"
        read -r response
        if [ "$response" != "y" ]; then
            exit 1
        fi
    }
    echo -e "${GREEN}  ✅ Backup terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  Script de backup non trouvé${NC}"
fi

# ============================================================================
# 2. MISE À JOUR PACKAGES SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[2/5] Mise à jour packages système...${NC}"

# Rafraîchir les dépôts
zypper refresh || {
    echo -e "${RED}  ❌ Erreur rafraîchissement dépôts${NC}"
    exit 1
}

# Mise à jour (sans installation automatique)
zypper update --no-recommends --dry-run > /tmp/zypper-update-dryrun.txt 2>&1
UPDATE_COUNT=$(grep -c "will be updated" /tmp/zypper-update-dryrun.txt || echo "0")

if [ "$UPDATE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}  ⚠️  $UPDATE_COUNT packages à mettre à jour${NC}"
    echo -e "${YELLOW}  Voulez-vous continuer? (y/n)${NC}"
    read -r response
    if [ "$response" == "y" ]; then
        zypper update --no-recommends -y || {
            echo -e "${RED}  ❌ Erreur mise à jour packages${NC}"
            exit 1
        }
        echo -e "${GREEN}  ✅ Packages mis à jour${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Mise à jour annulée${NC}"
    fi
else
    echo -e "${GREEN}  ✅ Aucune mise à jour nécessaire${NC}"
fi

# ============================================================================
# 3. MISE À JOUR SERVICES
# ============================================================================
echo -e "\n${YELLOW}[3/5] Mise à jour services...${NC}"

# Redémarrer les services critiques (après mise à jour)
SERVICES=("sshd" "dirsrv@cluster" "krb5kdc" "kadmin" "slurmctld" "munge")

for service in "${SERVICES[@]}"; do
    if systemctl is-enabled "$service" > /dev/null 2>&1; then
        echo -e "${YELLOW}  Redémarrer $service? (y/n)${NC}"
        read -r response
        if [ "$response" == "y" ]; then
            systemctl restart "$service" && \
                echo -e "${GREEN}  ✅ $service redémarré${NC}" || \
                echo -e "${RED}  ❌ Erreur redémarrage $service${NC}"
        fi
    fi
done

# ============================================================================
# 4. NETTOYAGE SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[4/5] Nettoyage système...${NC}"

# Nettoyage cache zypper
zypper clean --all || true
echo -e "${GREEN}  ✅ Cache zypper nettoyé${NC}"

# Nettoyage logs anciens (garder 30 jours)
find /var/log -name "*.log" -mtime +30 -delete 2>/dev/null || true
find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null || true
echo -e "${GREEN}  ✅ Logs anciens nettoyés${NC}"

# Nettoyage /tmp (fichiers > 7 jours)
find /tmp -type f -mtime +7 -delete 2>/dev/null || true
echo -e "${GREEN}  ✅ /tmp nettoyé${NC}"

# ============================================================================
# 5. VÉRIFICATION POST-MISE À JOUR
# ============================================================================
echo -e "\n${YELLOW}[5/5] Vérification post-mise à jour...${NC}"

# Vérifier les services
HEALTH_SCRIPT="$(dirname "$0")/../tests/test-cluster-health.sh"
if [ -f "$HEALTH_SCRIPT" ]; then
    "$HEALTH_SCRIPT" || {
        echo -e "${RED}  ⚠️  Des problèmes détectés après mise à jour${NC}"
    }
else
    echo -e "${YELLOW}  ⚠️  Script de vérification non trouvé${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== MISE À JOUR TERMINÉE ===${NC}"
echo "Date: $(date)"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Vérifier que tous les services fonctionnent"
echo "  - Tester l'authentification"
echo "  - Tester la soumission de jobs"
echo ""
echo -e "${GREEN}Mise à jour terminée!${NC}"
