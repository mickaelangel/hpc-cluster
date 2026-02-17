#!/bin/bash
# ============================================================================
# Configuration EncFS - Chiffrement Fichiers Système
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION ENCFS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation EncFS...${NC}"

zypper install -y encfs fuse || {
    echo -e "${RED}Erreur: Installation EncFS échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ EncFS installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration EncFS...${NC}"

# Script helper pour créer volume EncFS
cat > /usr/local/bin/create-encfs-volume.sh <<'EOF'
#!/bin/bash
# Créer un volume EncFS
ENCRYPTED_DIR=$1
MOUNT_POINT=$2

if [ -z "$ENCRYPTED_DIR" ] || [ -z "$MOUNT_POINT" ]; then
    echo "Usage: create-encfs-volume.sh /path/encrypted /path/mount"
    exit 1
fi

mkdir -p "$ENCRYPTED_DIR"
mkdir -p "$MOUNT_POINT"

# Créer volume EncFS
encfs "$ENCRYPTED_DIR" "$MOUNT_POINT"

echo "Volume EncFS créé et monté"
echo "Pour monter: encfs $ENCRYPTED_DIR $MOUNT_POINT"
echo "Pour démonter: fusermount -u $MOUNT_POINT"
EOF

chmod +x /usr/local/bin/create-encfs-volume.sh

echo -e "${GREEN}  ✅ EncFS configuré${NC}"

# ============================================================================
# 3. DOCUMENTATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Documentation...${NC}"

cat > /usr/local/share/doc/encfs-usage.txt <<'EOF'
# Utilisation EncFS

## Créer un volume chiffré
create-encfs-volume.sh /encrypted/data /mnt/encrypted

## Monter un volume
encfs /encrypted/data /mnt/encrypted

## Démonter un volume
fusermount -u /mnt/encrypted
EOF

echo -e "${GREEN}  ✅ Documentation créée${NC}"

echo -e "\n${GREEN}=== ENCFS CONFIGURÉ ===${NC}"
echo "Script: /usr/local/bin/create-encfs-volume.sh"
echo "Documentation: /usr/local/share/doc/encfs-usage.txt"
