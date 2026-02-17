#!/bin/bash
# ============================================================================
# Restauration depuis BorgBackup - Cluster HPC
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BORG_REPO="${BORG_REPO:-/backup/borg-repo}"
RESTORE_PATH="${RESTORE_PATH:-/tmp/restore}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}RESTAURATION BORGBACKUP${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. LISTE DES BACKUPS
# ============================================================================
echo -e "\n${YELLOW}[1/3] Liste des backups disponibles...${NC}"

export BORG_PASSPHRASE
borg list "$BORG_REPO" || {
    echo -e "${RED}Erreur: Repository non accessible${NC}"
    exit 1
}

# ============================================================================
# 2. SÉLECTION BACKUP
# ============================================================================
echo -e "\n${YELLOW}[2/3] Sélection du backup...${NC}"

if [ -z "${ARCHIVE_NAME:-}" ]; then
    echo "Entrez le nom de l'archive à restaurer (ou 'latest' pour la dernière):"
    read -r ARCHIVE_NAME
fi

if [ "$ARCHIVE_NAME" = "latest" ]; then
    ARCHIVE_NAME=$(borg list --short "$BORG_REPO" | tail -1)
fi

echo -e "${GREEN}  ✅ Archive sélectionnée: $ARCHIVE_NAME${NC}"

# ============================================================================
# 3. RESTAURATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Restauration...${NC}"

mkdir -p "$RESTORE_PATH"

echo "Restauration dans: $RESTORE_PATH"
borg extract \
    --progress \
    "$BORG_REPO::$ARCHIVE_NAME" || {
    echo -e "${RED}Erreur: Restauration échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Restauration terminée${NC}"
echo -e "${YELLOW}Contenu restauré dans: $RESTORE_PATH${NC}"
