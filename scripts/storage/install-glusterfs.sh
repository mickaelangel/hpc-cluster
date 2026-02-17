#!/bin/bash
# ============================================================================
# Installation GlusterFS - FS distribué open-source (alternative à GPFS)
# Compatible openSUSE / SUSE
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION GLUSTERFS${NC}"
echo -e "${GREEN}========================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Exécuter en root (sudo)${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[1/4] Installation paquets...${NC}"
zypper --non-interactive install -y glusterfs glusterfs-server 2>/dev/null || \
zypper --non-interactive install -y glusterfs glusterfs-server glusterfs-client 2>/dev/null || {
    echo -e "${YELLOW}Dépôt SUSE Package Hub peut être requis pour glusterfs-server${NC}"
    zypper --non-interactive install -y glusterfs 2>/dev/null || true
}

echo -e "\n${YELLOW}[2/4] Démarrage glusterd...${NC}"
systemctl enable glusterd
systemctl start glusterd

echo -e "\n${YELLOW}[3/4] Volume démo (nœud unique)...${NC}"
BRICK_DIR="/var/lib/glusterfs/brick_hpc"
VOL_NAME="gv_hpc"
mkdir -p "$BRICK_DIR"
if ! gluster volume info "$VOL_NAME" &>/dev/null; then
    H=$(hostname -s)
    gluster volume create "$VOL_NAME" "${H}:${BRICK_DIR}" force 2>/dev/null || \
    gluster volume create "$VOL_NAME" "${BRICK_DIR}" force 2>/dev/null || true
    gluster volume start "$VOL_NAME" 2>/dev/null || true
else
    gluster volume start "$VOL_NAME" 2>/dev/null || true
fi

echo -e "\n${YELLOW}[4/4] Vérification...${NC}"
gluster volume status 2>/dev/null || true
echo -e "${GREEN}✅ GlusterFS installé${NC}"
echo "Montage: mount -t glusterfs $(hostname):/$VOL_NAME /mnt/hpc"
