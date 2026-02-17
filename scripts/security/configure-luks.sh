#!/bin/bash
# ============================================================================
# Configuration LUKS - Chiffrement Disques
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION LUKS${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation outils LUKS...${NC}"

zypper install -y cryptsetup || {
    echo -e "${RED}Erreur: Installation cryptsetup échouée${NC}"
    exit 1
}

echo -e "${GREEN}  ✅ Outils LUKS installés${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration LUKS...${NC}"

# Script helper pour créer volume chiffré
cat > /usr/local/bin/create-luks-volume.sh <<'EOF'
#!/bin/bash
# Créer un volume LUKS
DEVICE=$1
VOLUME_NAME=$2

if [ -z "$DEVICE" ] || [ -z "$VOLUME_NAME" ]; then
    echo "Usage: create-luks-volume.sh /dev/sdX volume-name"
    exit 1
fi

# Créer partition LUKS
cryptsetup luksFormat "$DEVICE"

# Ouvrir volume
cryptsetup open "$DEVICE" "$VOLUME_NAME"

# Formater
mkfs.ext4 "/dev/mapper/$VOLUME_NAME"

# Ajouter à /etc/crypttab
echo "$VOLUME_NAME $DEVICE none luks" >> /etc/crypttab

# Créer point de montage
mkdir -p "/mnt/$VOLUME_NAME"

# Ajouter à /etc/fstab
echo "/dev/mapper/$VOLUME_NAME /mnt/$VOLUME_NAME ext4 defaults 0 2" >> /etc/fstab
EOF

chmod +x /usr/local/bin/create-luks-volume.sh

echo -e "${GREEN}  ✅ LUKS configuré${NC}"

# ============================================================================
# 3. DOCUMENTATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Documentation...${NC}"

cat > /usr/local/share/doc/luks-usage.txt <<'EOF'
# Utilisation LUKS

## Créer un volume chiffré
create-luks-volume.sh /dev/sdX my-volume

## Ouvrir un volume
cryptsetup open /dev/sdX my-volume

## Fermer un volume
cryptsetup close my-volume

## Monter un volume
mount /dev/mapper/my-volume /mnt/my-volume

## Démonter un volume
umount /mnt/my-volume
cryptsetup close my-volume
EOF

echo -e "${GREEN}  ✅ Documentation créée${NC}"

echo -e "\n${GREEN}=== LUKS CONFIGURÉ ===${NC}"
echo "Script: /usr/local/bin/create-luks-volume.sh"
echo "Documentation: /usr/local/share/doc/luks-usage.txt"
echo -e "${YELLOW}ATTENTION: Utiliser avec précaution sur disques de production!${NC}"
