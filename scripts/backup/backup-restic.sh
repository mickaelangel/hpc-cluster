#!/bin/bash
# ============================================================================
# Script de Backup Restic - Cluster HPC
# Backup automatisé vers disque USB ou stockage secondaire (Air-Gapped)
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
RESTIC_REPO="${RESTIC_REPO:-/backup/restic-repo}"
BACKUP_PATHS=(
    "/gpfs/home"
    "/home"
    "/etc"
    "/var/lib/slurm"
)
EXCLUDE_FILE="${EXCLUDE_FILE:-/etc/restic/excludes}"
RESTIC_PASSWORD="${RESTIC_PASSWORD:-}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BACKUP RESTIC - CLUSTER HPC${NC}"
echo -e "${GREEN}Repository: $RESTIC_REPO${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION RESTIC
# ============================================================================
echo -e "\n${YELLOW}[1/5] Installation Restic...${NC}"

if ! command -v restic > /dev/null 2>&1; then
    # Installation depuis repo ou binaire
    if zypper search restic 2>/dev/null | grep -q restic; then
        zypper install -y restic
    else
        # Installation depuis binaire
        cd /tmp
        wget https://github.com/restic/restic/releases/download/v0.16.4/restic_0.16.4_linux_amd64.bz2
        bunzip2 restic_0.16.4_linux_amd64.bz2
        chmod +x restic_0.16.4_linux_amd64
        mv restic_0.16.4_linux_amd64 /usr/local/bin/restic
    fi
    echo -e "${GREEN}  ✅ Restic installé${NC}"
else
    echo -e "${GREEN}  ✅ Restic déjà installé${NC}"
fi

# ============================================================================
# 2. INITIALISATION REPOSITORY
# ============================================================================
echo -e "\n${YELLOW}[2/5] Initialisation repository...${NC}"

if [ ! -d "$RESTIC_REPO" ]; then
    mkdir -p "$RESTIC_REPO"
    echo -e "${GREEN}  ✅ Répertoire créé${NC}"
fi

# Initialiser le repository si nécessaire
if [ ! -f "$RESTIC_REPO/config" ]; then
    if [ -z "$RESTIC_PASSWORD" ]; then
        echo -e "${YELLOW}  ⚠️  Mot de passe Restic requis${NC}"
        echo -e "${YELLOW}  Définir RESTIC_PASSWORD ou entrer interactivement${NC}"
    fi
    
    RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO" init || {
        echo -e "${RED}  ❌ Initialisation repository échouée${NC}"
        exit 1
    }
    echo -e "${GREEN}  ✅ Repository initialisé${NC}"
else
    echo -e "${GREEN}  ✅ Repository existe déjà${NC}"
fi

# ============================================================================
# 3. CONFIGURATION EXCLUDES
# ============================================================================
echo -e "\n${YELLOW}[3/5] Configuration excludes...${NC}"

mkdir -p "$(dirname $EXCLUDE_FILE)"
cat > "$EXCLUDE_FILE" <<'EOF'
# Exclusions Restic
*.tmp
*.log
*.cache
/tmp/*
/var/tmp/*
/proc/*
/sys/*
/dev/*
/run/*
/var/run/*
*.swp
*.bak
EOF

echo -e "${GREEN}  ✅ Excludes configurés${NC}"

# ============================================================================
# 4. BACKUP
# ============================================================================
echo -e "\n${YELLOW}[4/5] Backup en cours...${NC}"

BACKUP_PATHS_STR=$(IFS=' '; echo "${BACKUP_PATHS[*]}")

RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO" \
    backup $BACKUP_PATHS_STR \
    --exclude-file="$EXCLUDE_FILE" \
    --verbose || {
    echo -e "${RED}  ❌ Backup échoué${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Backup terminé${NC}"

# ============================================================================
# 5. VÉRIFICATION ET NETTOYAGE
# ============================================================================
echo -e "\n${YELLOW}[5/5] Vérification et nettoyage...${NC}"

# Vérifier l'intégrité
RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO" check || {
    echo -e "${RED}  ❌ Vérification intégrité échouée${NC}"
}

# Nettoyer les anciens snapshots (garder 30 jours)
RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO" \
    forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 \
    --prune || {
    echo -e "${YELLOW}  ⚠️  Nettoyage échoué${NC}"
}

# Statistiques
RESTIC_PASSWORD="$RESTIC_PASSWORD" restic -r "$RESTIC_REPO" stats

echo -e "${GREEN}  ✅ Vérification terminée${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== BACKUP RESTIC TERMINÉ ===${NC}"
echo "Repository: $RESTIC_REPO"
echo "Paths sauvegardés:"
for path in "${BACKUP_PATHS[@]}"; do
    echo "  - $path"
done
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Sauvegarder le mot de passe Restic de manière sécurisée"
echo "  - Tester la restauration régulièrement"
echo "  - Copier le repository sur support externe"
echo ""
echo -e "${GREEN}Backup terminé!${NC}"
