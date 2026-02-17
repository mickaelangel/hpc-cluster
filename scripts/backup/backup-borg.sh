#!/bin/bash
# ============================================================================
# Backup Automatisé avec BorgBackup - Cluster HPC
# Backup dédupliqué et incrémental
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BORG_REPO="${BORG_REPO:-/backup/borg-repo}"
BORG_PASSPHRASE="${BORG_PASSPHRASE:-}"
BACKUP_PATHS=(
    "/etc"
    "/mnt/beegfs/home"
    "/opt"
    "/var/lib/ldap"
    "/var/kerberos/krb5kdc"
)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BACKUP BORGBACKUP${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION BORGBACKUP
# ============================================================================
echo -e "\n${YELLOW}[1/4] Installation BorgBackup...${NC}"

if ! command -v borg &> /dev/null; then
    zypper install -y borgbackup || {
        # Alternative: installation depuis pip
        pip3 install borgbackup || {
            echo -e "${RED}Erreur: Installation BorgBackup échouée${NC}"
            exit 1
        }
    }
fi

echo -e "${GREEN}  ✅ BorgBackup installé${NC}"

# ============================================================================
# 2. INITIALISATION REPOSITORY
# ============================================================================
echo -e "\n${YELLOW}[2/4] Initialisation repository...${NC}"

mkdir -p "$(dirname "$BORG_REPO")"

if [ ! -d "$BORG_REPO" ]; then
    export BORG_PASSPHRASE
    borg init --encryption=repokey "$BORG_REPO" || {
        echo -e "${YELLOW}  ⚠️  Repository existe déjà${NC}"
    }
fi

echo -e "${GREEN}  ✅ Repository initialisé${NC}"

# ============================================================================
# 3. BACKUP
# ============================================================================
echo -e "\n${YELLOW}[3/4] Création backup...${NC}"

ARCHIVE_NAME="cluster-$(hostname)-$(date +%Y%m%d-%H%M%S)"
export BORG_PASSPHRASE

for path in "${BACKUP_PATHS[@]}"; do
    if [ -d "$path" ] || [ -f "$path" ]; then
        echo -e "  Backup: $path"
        borg create \
            --stats \
            --progress \
            "$BORG_REPO::$ARCHIVE_NAME" \
            "$path" || {
            echo -e "${YELLOW}  ⚠️  Backup $path échoué${NC}"
        }
    else
        echo -e "${YELLOW}  ⚠️  $path n'existe pas${NC}"
    fi
done

echo -e "${GREEN}  ✅ Backup créé: $ARCHIVE_NAME${NC}"

# ============================================================================
# 4. NETTOYAGE ANCIENS BACKUPS
# ============================================================================
echo -e "\n${YELLOW}[4/4] Nettoyage anciens backups...${NC}"

# Garder: 7 backups quotidiens, 4 backups hebdomadaires, 12 backups mensuels
borg prune \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=12 \
    "$BORG_REPO" || {
    echo -e "${YELLOW}  ⚠️  Nettoyage échoué${NC}"
}

echo -e "${GREEN}  ✅ Nettoyage terminé${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== BACKUP TERMINÉ ===${NC}"
echo "Repository: $BORG_REPO"
echo "Archive: $ARCHIVE_NAME"
echo ""
echo -e "${YELLOW}LISTE DES BACKUPS:${NC}"
borg list "$BORG_REPO"
