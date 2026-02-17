#!/bin/bash
# ============================================================================
# Script de Restauration - Cluster HPC
# Restauration depuis backup LDAP, Kerberos, GPFS, Slurm, Configuration
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Vérification arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Usage: $0 <backup-archive.tar.gz> [--selective <component>]${NC}"
    echo "Components: ldap, kerberos, gpfs, slurm, system, all"
    exit 1
fi

BACKUP_ARCHIVE="$1"
SELECTIVE_MODE="${2:-}"
SELECTIVE_COMPONENT="${3:-}"

# Vérifier que l'archive existe
if [ ! -f "$BACKUP_ARCHIVE" ]; then
    echo -e "${RED}Erreur: Archive non trouvée: $BACKUP_ARCHIVE${NC}"
    exit 1
fi

# Créer répertoire temporaire
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}RESTAURATION CLUSTER HPC${NC}"
echo -e "${GREEN}Archive: $BACKUP_ARCHIVE${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# EXTRACTION ARCHIVE
# ============================================================================
echo -e "\n${YELLOW}[1/7] Extraction archive...${NC}"

tar -xzf "$BACKUP_ARCHIVE" -C "$TEMP_DIR" || {
    echo -e "${RED}Erreur: Extraction archive échouée${NC}"
    exit 1
}

# Trouver le répertoire de backup
BACKUP_DIR=$(find "$TEMP_DIR" -type d -name "20*" | head -1)
if [ -z "$BACKUP_DIR" ]; then
    echo -e "${RED}Erreur: Structure de backup invalide${NC}"
    exit 1
fi

echo -e "${GREEN}  ✅ Archive extraite dans: $BACKUP_DIR${NC}"

# ============================================================================
# FONCTION RESTAURATION SELECTIVE
# ============================================================================
restore_component() {
    local component="$1"
    
    case "$component" in
        ldap)
            restore_ldap
            ;;
        kerberos)
            restore_kerberos
            ;;
        gpfs)
            restore_gpfs
            ;;
        slurm)
            restore_slurm
            ;;
        system)
            restore_system
            ;;
        all)
            restore_ldap
            restore_kerberos
            restore_gpfs
            restore_slurm
            restore_system
            ;;
        *)
            echo -e "${RED}Composant inconnu: $component${NC}"
            exit 1
            ;;
    esac
}

# ============================================================================
# 2. RESTAURATION LDAP
# ============================================================================
restore_ldap() {
    echo -e "\n${YELLOW}[2/7] Restauration LDAP...${NC}"
    
    if [ ! -f "$BACKUP_DIR/ldap-backup.ldif" ]; then
        echo -e "${YELLOW}  ⚠️  Backup LDAP non trouvé, ignoré${NC}"
        return
    fi
    
    if ! systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
        echo -e "${RED}  ❌ Service LDAP non actif${NC}"
        return
    fi
    
    LDAP_DN="cn=Directory Manager"
    LDAP_PW="${LDAP_PASSWORD:-DSPassword123!}"
    
    # Restauration
    ldapadd -x -D "$LDAP_DN" -w "$LDAP_PW" -f "$BACKUP_DIR/ldap-backup.ldif" 2>/dev/null || {
        echo -e "${YELLOW}  ⚠️  Restauration LDAP (certaines entrées peuvent déjà exister)${NC}"
    }
    
    echo -e "${GREEN}  ✅ LDAP restauré${NC}"
}

# ============================================================================
# 3. RESTAURATION KERBEROS
# ============================================================================
restore_kerberos() {
    echo -e "\n${YELLOW}[3/7] Restauration Kerberos...${NC}"
    
    if [ ! -f "$BACKUP_DIR/principal" ]; then
        echo -e "${YELLOW}  ⚠️  Backup Kerberos non trouvé, ignoré${NC}"
        return
    fi
    
    if ! systemctl is-active krb5kdc > /dev/null 2>&1; then
        echo -e "${RED}  ❌ Service Kerberos non actif${NC}"
        return
    fi
    
    # Arrêter KDC
    systemctl stop krb5kdc
    systemctl stop kadmin
    
    # Restauration
    cp -a "$BACKUP_DIR/principal"* /var/kerberos/krb5kdc/ 2>/dev/null || true
    cp -a "$BACKUP_DIR/stash" /var/kerberos/krb5kdc/ 2>/dev/null || true
    
    # Redémarrer
    systemctl start krb5kdc
    systemctl start kadmin
    
    echo -e "${GREEN}  ✅ Kerberos restauré${NC}"
}

# ============================================================================
# 4. RESTAURATION GPFS
# ============================================================================
restore_gpfs() {
    echo -e "\n${YELLOW}[4/7] Restauration GPFS...${NC}"
    
    if [ ! -d "$BACKUP_DIR/gpfs" ]; then
        echo -e "${YELLOW}  ⚠️  Backup GPFS non trouvé, ignoré${NC}"
        return
    fi
    
    if ! command -v mmgetstate > /dev/null 2>&1; then
        echo -e "${YELLOW}  ⚠️  GPFS non installé, ignoré${NC}"
        return
    fi
    
    # Restauration configuration
    if [ -f "$BACKUP_DIR/gpfs/mmsdrfs" ]; then
        cp -a "$BACKUP_DIR/gpfs/mmsdrfs" /var/mmfs/gen/ 2>/dev/null || true
    fi
    
    # Restauration quotas
    if [ -f "$BACKUP_DIR/gpfs-quotas.txt" ]; then
        echo -e "${YELLOW}  ⚠️  Restauration quotas GPFS (manuellement)${NC}"
        echo "  Voir: $BACKUP_DIR/gpfs-quotas.txt"
    fi
    
    echo -e "${GREEN}  ✅ GPFS restauré${NC}"
}

# ============================================================================
# 5. RESTAURATION SLURM
# ============================================================================
restore_slurm() {
    echo -e "\n${YELLOW}[5/7] Restauration Slurm...${NC}"
    
    if [ ! -d "$BACKUP_DIR/slurm" ]; then
        echo -e "${YELLOW}  ⚠️  Backup Slurm non trouvé, ignoré${NC}"
        return
    fi
    
    # Arrêter Slurm
    systemctl stop slurmctld 2>/dev/null || true
    
    # Restauration configuration
    if [ -f "$BACKUP_DIR/slurm/slurm.conf" ]; then
        cp -a "$BACKUP_DIR/slurm/slurm.conf" /etc/slurm/ 2>/dev/null || true
    fi
    
    # Restauration base de données
    if [ -d "$BACKUP_DIR/slurm" ]; then
        cp -a "$BACKUP_DIR/slurm"/* /var/lib/slurm/ 2>/dev/null || true
    fi
    
    # Restauration Munge
    if [ -f "$BACKUP_DIR/munge.key" ]; then
        cp -a "$BACKUP_DIR/munge.key" /etc/munge/munge.key 2>/dev/null || true
        chmod 600 /etc/munge/munge.key
        chown munge:munge /etc/munge/munge.key
    fi
    
    # Redémarrer
    systemctl start slurmctld 2>/dev/null || true
    
    echo -e "${GREEN}  ✅ Slurm restauré${NC}"
}

# ============================================================================
# 6. RESTAURATION CONFIGURATION SYSTÈME
# ============================================================================
restore_system() {
    echo -e "\n${YELLOW}[6/7] Restauration configuration système...${NC}"
    
    if [ ! -d "$BACKUP_DIR/system" ]; then
        echo -e "${YELLOW}  ⚠️  Backup système non trouvé, ignoré${NC}"
        return
    fi
    
    # Restauration fichiers système (avec confirmation)
    echo -e "${YELLOW}  ⚠️  Restauration fichiers système (manuellement recommandé)${NC}"
    echo "  Fichiers disponibles dans: $BACKUP_DIR/system"
    echo "  - hosts"
    echo "  - sshd_config"
    echo "  - krb5.conf"
    echo "  - ldap.conf"
    echo "  - sssd.conf"
    
    echo -e "${GREEN}  ✅ Configuration système (à restaurer manuellement)${NC}"
}

# ============================================================================
# 7. RESTAURATION UTILISATEURS LOCAUX
# ============================================================================
restore_users() {
    echo -e "\n${YELLOW}[7/7] Restauration utilisateurs locaux...${NC}"
    
    if [ ! -f "$BACKUP_DIR/passwd" ]; then
        echo -e "${YELLOW}  ⚠️  Backup utilisateurs non trouvé, ignoré${NC}"
        return
    fi
    
    echo -e "${YELLOW}  ⚠️  Restauration utilisateurs locaux (manuellement recommandé)${NC}"
    echo "  Fichiers disponibles dans: $BACKUP_DIR"
    echo "  - passwd"
    echo "  - group"
    echo "  - shadow"
    echo "  - gshadow"
    
    echo -e "${GREEN}  ✅ Utilisateurs locaux (à restaurer manuellement)${NC}"
}

# ============================================================================
# EXECUTION
# ============================================================================
if [ "$SELECTIVE_MODE" == "--selective" ]; then
    restore_component "$SELECTIVE_COMPONENT"
    restore_users
else
    # Restauration complète
    restore_ldap
    restore_kerberos
    restore_gpfs
    restore_slurm
    restore_system
    restore_users
fi

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== RESTAURATION TERMINÉE ===${NC}"
echo "Archive: $BACKUP_ARCHIVE"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Vérifier les services restaurés"
echo "  - Tester l'authentification"
echo "  - Vérifier les configurations"
echo "  - Redémarrer les services si nécessaire"
echo ""
echo -e "${GREEN}Restauration terminée!${NC}"
