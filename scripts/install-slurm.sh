#!/bin/bash
# ============================================================================
# Installation Slurm + Munge - Ordonnanceur HPC
# Compatible openSUSE Leap 15 / SUSE SLE 15
# ============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION SLURM + MUNGE${NC}"
echo -e "${GREEN}========================================${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Exécuter en root (sudo)${NC}"
    exit 1
fi

# Dépôt network:cluster pour openSUSE (Slurm, Munge)
if [ -f /etc/os-release ]; then
    source /etc/os-release
    if [[ "$ID" =~ opensuse-leap|sles ]] && [ ! -f /etc/zypp/repos.d/network_cluster.repo ]; then
        echo -e "\n${YELLOW}[1/5] Ajout dépôt network:cluster...${NC}"
        LEAP="${VERSION_ID:-15.4}"
        zypper --non-interactive --gpg-auto-import-keys addrepo -f \
            "https://download.opensuse.org/repositories/network:cluster/openSUSE_Leap_${LEAP}/network:cluster.repo" \
            network_cluster 2>/dev/null || true
        zypper --non-interactive refresh 2>/dev/null || true
    fi
fi

echo -e "\n${YELLOW}[2/5] Installation paquets...${NC}"
zypper --non-interactive install -y munge 2>/dev/null || true
zypper --non-interactive install -y slurm slurm-munge 2>/dev/null || \
zypper --non-interactive install -y slurm 2>/dev/null || {
    echo -e "${YELLOW}Slurm non dans les dépôts, tentative slurm-wlm...${NC}"
    zypper --non-interactive install -y slurm-wlm munge 2>/dev/null || true
}

if ! command -v slurmd &>/dev/null && ! command -v slurmctld &>/dev/null; then
    echo -e "${YELLOW}⚠️  Slurm non installé (dépôt network:cluster requis pour openSUSE)${NC}"
    echo "Ajout manuel: zypper ar -f https://download.opensuse.org/repositories/network:cluster/openSUSE_Leap_15.4/network:cluster.repo"
    exit 0
fi

echo -e "\n${YELLOW}[3/5] Configuration Munge...${NC}"
if [ ! -f /etc/munge/munge.key ]; then
    dd if=/dev/urandom bs=1 count=1024 2>/dev/null | base64 | head -c 1024 > /etc/munge/munge.key
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
fi
systemctl enable munge
systemctl start munge

echo -e "\n${YELLOW}[4/5] Configuration Slurm (nœud unique)...${NC}"
SLURM_CONF="/etc/slurm/slurm.conf"
mkdir -p /etc/slurm
HOSTNAME=$(hostname -s)

if [ ! -f "$SLURM_CONF" ] || ! grep -q "ClusterName=hpc" "$SLURM_CONF" 2>/dev/null; then
    cat > "$SLURM_CONF" <<EOF
ClusterName=hpc
SlurmctldHost=${HOSTNAME}
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=2
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
StateSaveLocation=/var/spool/slurm/ctld
SwitchType=switch/none
TaskPlugin=task/none
SlurmctldTimeout=120
SlurmdTimeout=300
InactiveLimit=0
KillWait=30
MinJobAge=300
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
JobCompType=jobcomp/none
JobAcctGatherType=jobacct_gather/none
JobAcctGatherFrequency=30
AccountingStorageType=accounting_storage/none
NodeName=${HOSTNAME} CPUs=4 RealMemory=4096 State=UNKNOWN
PartitionName=compute Nodes=${HOSTNAME} Default=YES MaxTime=INFINITE State=UP
EOF
fi
mkdir -p /var/spool/slurm/ctld /var/spool/slurmd
chown -R slurm:slurm /var/spool/slurm 2>/dev/null || true

echo -e "\n${YELLOW}[5/5] Démarrage services...${NC}"
systemctl enable slurmctld
systemctl enable slurmd
systemctl start slurmctld
systemctl start slurmd
sleep 2
scontrol update nodename="${HOSTNAME}" state=idle 2>/dev/null || true

echo -e "${GREEN}✅ Slurm installé${NC}"
echo "Test: scontrol ping ; sinfo"
