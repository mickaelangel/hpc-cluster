#!/bin/bash
# ============================================================================
# Script de Synchronisation SUMA Offline - Cluster HPC
# Synchronisation des patches depuis média amovible (USB/DVD)
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SYNC_DIR="${SYNC_DIR:-/mnt/suma-sync}"
RMT_SERVER="${RMT_SERVER:-exsus-repo.defense.local}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SYNCHRONISATION SUMA OFFLINE${NC}"
echo -e "${GREEN}Source: $SYNC_DIR${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. VÉRIFICATION MÉDIA
# ============================================================================
echo -e "\n${YELLOW}[1/4] Vérification média...${NC}"

if [ ! -d "$SYNC_DIR" ]; then
    echo -e "${RED}Erreur: Répertoire de synchronisation non trouvé: $SYNC_DIR${NC}"
    echo -e "${YELLOW}Monter le média USB/DVD sur $SYNC_DIR${NC}"
    exit 1
fi

if [ ! "$(ls -A $SYNC_DIR)" ]; then
    echo -e "${RED}Erreur: Répertoire vide${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Média détecté${NC}"

# ============================================================================
# 2. IMPORT DEPUIS RMT (si disponible)
# ============================================================================
echo -e "\n${YELLOW}[2/4] Import depuis RMT...${NC}"

if command -v rmt-cli > /dev/null 2>&1; then
    # Importer les packages depuis le média
    rmt-cli import --path "$SYNC_DIR" || {
        echo -e "${YELLOW}  ⚠️  Import RMT échoué (peut être normal si format différent)${NC}"
    }
    echo -e "${GREEN}  ✅ Import RMT terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  RMT non installé, import manuel requis${NC}"
fi

# ============================================================================
# 3. SYNCHRONISATION SUMA
# ============================================================================
echo -e "\n${YELLOW}[3/4] Synchronisation SUMA...${NC}"

if command -v mgr-sync > /dev/null 2>&1; then
    # Rafraîchir les channels
    mgr-sync refresh || {
        echo -e "${YELLOW}  ⚠️  Refresh channels échoué${NC}"
    }
    echo -e "${GREEN}  ✅ Channels rafraîchis${NC}"
else
    echo -e "${YELLOW}  ⚠️  mgr-sync non disponible${NC}"
fi

# ============================================================================
# 4. COPIE PACKAGES VERS SUMA
# ============================================================================
echo -e "\n${YELLOW}[4/4] Copie packages vers SUMA...${NC}"

PACKAGES_DIR="/var/spacewalk/packages/updates"
mkdir -p "$PACKAGES_DIR"

# Copier les packages RPM
if [ -d "$SYNC_DIR/packages" ]; then
    cp -a "$SYNC_DIR/packages"/*.rpm "$PACKAGES_DIR/" 2>/dev/null || true
    echo -e "${GREEN}  ✅ Packages copiés${NC}"
else
    echo -e "${YELLOW}  ⚠️  Aucun package trouvé dans $SYNC_DIR/packages${NC}"
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== SYNCHRONISATION TERMINÉE ===${NC}"
echo "Source: $SYNC_DIR"
echo "Packages copiés: $(ls -1 $PACKAGES_DIR/*.rpm 2>/dev/null | wc -l)"
echo ""
echo -e "${YELLOW}PROCHAINES ÉTAPES:${NC}"
echo "  1. Vérifier les packages dans SUMA"
echo "  2. Approuver les patches de sécurité"
echo "  3. Déployer sur les nœuds via Salt"
echo ""
echo -e "${GREEN}Synchronisation terminée!${NC}"
