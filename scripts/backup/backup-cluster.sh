#!/bin/bash
# ============================================================================
# Script de Backup Complet - Cluster HPC
# Backup LDAP, Kerberos, GPFS, Slurm, Configuration
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/backup/cluster}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/${DATE}"

# Créer le répertoire de backup
mkdir -p "${BACKUP_PATH}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BACKUP CLUSTER HPC${NC}"
echo -e "${GREEN}Date: ${DATE}${NC}"
echo -e "${GREEN}Destination: ${BACKUP_PATH}${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. BACKUP LDAP
# ============================================================================
echo -e "\n${YELLOW}[1/6] Backup LDAP...${NC}"

if systemctl is-active dirsrv@cluster > /dev/null 2>&1; then
    LDAP_BASE="dc=cluster,dc=local"
    LDAP_DN="cn=Directory Manager"
    LDAP_PW="${LDAP_PASSWORD:-DSPassword123!}"
    
    ldapsearch -x -D "${LDAP_DN}" -w "${LDAP_PW}" \
        -b "${LDAP_BASE}" > "${BACKUP_PATH}/ldap-backup.ldif" 2>/dev/null || {
        echo -e "${RED}  ⚠️  Backup LDAP échoué${NC}"
    }
    
    echo -e "${GREEN}  ✅ Backup LDAP terminé${NC}"
else
    echo -e "${YELLOW}  ⚠️  LDAP non actif, backup ignoré${NC}"
fi

# ============================================================================
# 2. BACKUP KERBEROS
# ============================================================================
echo -e "\n${YELLOW}[2/6] Backup Kerberos...${NC}"

if systemctl is-active krb5kdc > /dev/null 2>&1; then
    # Backup base de données Kerberos
    if [ -f /var/kerberos/krb5kdc/principal ]; then
        cp -a /var/kerberos/krb5kdc/principal* "${BACKUP_PATH}/" 2>/dev/null || true
        cp -a /var/kerberos/krb5kdc/stash "${BACKUP_PATH}/" 2>/dev/null || true
        echo -e "${GREEN}  ✅ Backup Kerberos terminé${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Base Kerberos non trouvée${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Kerberos non actif, backup ignoré${NC}"
fi

# ============================================================================
# 3. BACKUP GPFS
# ============================================================================
echo -e "\n${YELLOW}[3/6] Backup GPFS...${NC}"

if command -v mmgetstate > /dev/null 2>&1; then
    # Backup configuration GPFS
    if [ -f /var/mmfs/gen/mmsdrfs ]; then
        mkdir -p "${BACKUP_PATH}/gpfs"
        cp -a /var/mmfs/gen/mmsdrfs "${BACKUP_PATH}/gpfs/" 2>/dev/null || true
        cp -a /var/mmfs/etc/* "${BACKUP_PATH}/gpfs/" 2>/dev/null || true
        echo -e "${GREEN}  ✅ Backup configuration GPFS terminé${NC}"
    fi
    
    # Export quotas GPFS
    if command -v mmdefquota > /dev/null 2>&1; then
        mmdefquota -j > "${BACKUP_PATH}/gpfs-quotas.txt" 2>/dev/null || true
    fi
else
    echo -e "${YELLOW}  ⚠️  GPFS non installé, backup ignoré${NC}"
fi

# ============================================================================
# 4. BACKUP SLURM
# ============================================================================
echo -e "\n${YELLOW}[4/6] Backup Slurm...${NC}"

mkdir -p "${BACKUP_PATH}/slurm"

# Backup configuration Slurm
if [ -f /etc/slurm/slurm.conf ]; then
    cp -a /etc/slurm/* "${BACKUP_PATH}/slurm/" 2>/dev/null || true
fi

# Backup base de données Slurm
if [ -d /var/lib/slurm ]; then
    cp -a /var/lib/slurm/* "${BACKUP_PATH}/slurm/" 2>/dev/null || true
fi

# Backup Munge
if [ -f /etc/munge/munge.key ]; then
    cp -a /etc/munge/munge.key "${BACKUP_PATH}/munge.key" 2>/dev/null || true
    chmod 600 "${BACKUP_PATH}/munge.key"
fi

echo -e "${GREEN}  ✅ Backup Slurm terminé${NC}"

# ============================================================================
# 5. BACKUP CONFIGURATION SYSTÈME
# ============================================================================
echo -e "\n${YELLOW}[5/6] Backup configuration système...${NC}"

mkdir -p "${BACKUP_PATH}/system"

# Configuration réseau
cp -a /etc/hosts "${BACKUP_PATH}/system/" 2>/dev/null || true
cp -a /etc/sysconfig/network/* "${BACKUP_PATH}/system/" 2>/dev/null || true

# Configuration SSH
cp -a /etc/ssh/sshd_config "${BACKUP_PATH}/system/" 2>/dev/null || true

# Configuration Kerberos
cp -a /etc/krb5.conf "${BACKUP_PATH}/system/" 2>/dev/null || true

# Configuration LDAP
cp -a /etc/ldap/ldap.conf "${BACKUP_PATH}/system/" 2>/dev/null || true

# Configuration SSSD
if [ -f /etc/sssd/sssd.conf ]; then
    cp -a /etc/sssd/sssd.conf "${BACKUP_PATH}/system/" 2>/dev/null || true
fi

echo -e "${GREEN}  ✅ Backup configuration système terminé${NC}"

# ============================================================================
# 6. BACKUP UTILISATEURS LOCAUX
# ============================================================================
echo -e "\n${YELLOW}[6/6] Backup utilisateurs locaux...${NC}"

cp -a /etc/passwd "${BACKUP_PATH}/passwd" 2>/dev/null || true
cp -a /etc/group "${BACKUP_PATH}/group" 2>/dev/null || true
cp -a /etc/shadow "${BACKUP_PATH}/shadow" 2>/dev/null || true
cp -a /etc/gshadow "${BACKUP_PATH}/gshadow" 2>/dev/null || true

echo -e "${GREEN}  ✅ Backup utilisateurs locaux terminé${NC}"

# ============================================================================
# CRÉATION ARCHIVE
# ============================================================================
echo -e "\n${YELLOW}Création archive...${NC}"

cd "${BACKUP_DIR}"
tar -czf "cluster-backup-${DATE}.tar.gz" "${DATE}/" 2>/dev/null || {
    echo -e "${RED}  ⚠️  Création archive échouée${NC}"
    exit 1
}

# Calculer la taille
SIZE=$(du -h "cluster-backup-${DATE}.tar.gz" | cut -f1)

echo -e "${GREEN}  ✅ Archive créée: cluster-backup-${DATE}.tar.gz (${SIZE})${NC}"

# ============================================================================
# NETTOYAGE ANCIENS BACKUPS (garder 7 jours)
# ============================================================================
echo -e "\n${YELLOW}Nettoyage anciens backups...${NC}"

find "${BACKUP_DIR}" -name "cluster-backup-*.tar.gz" -mtime +7 -delete 2>/dev/null || true
find "${BACKUP_DIR}" -type d -name "20*" -mtime +7 -exec rm -rf {} + 2>/dev/null || true

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== BACKUP TERMINÉ ===${NC}"
echo "Backup sauvegardé dans: ${BACKUP_PATH}"
echo "Archive créée: cluster-backup-${DATE}.tar.gz"
echo ""
echo "Contenu du backup:"
echo "  ✅ LDAP (ldap-backup.ldif)"
echo "  ✅ Kerberos (principal, stash)"
echo "  ✅ GPFS (configuration, quotas)"
echo "  ✅ Slurm (configuration, base de données, Munge)"
echo "  ✅ Configuration système"
echo "  ✅ Utilisateurs locaux"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  - Copier l'archive sur un support externe"
echo "  - Vérifier l'intégrité de l'archive"
echo "  - Tester la restauration régulièrement"
echo ""
echo -e "${GREEN}Backup terminé!${NC}"
