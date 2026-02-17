#!/bin/bash
# ============================================================================
# Script de Configuration Salt States - Cluster HPC
# Configuration Salt States pour SUMA et conformité DISA STIG
# Compatible SUSE 15 SP7
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
SALT_DIR="/srv/salt"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION SALT STATES${NC}"
echo -e "${GREEN}Pour SUMA et Conformité DISA STIG${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. CRÉATION STRUCTURE SALT
# ============================================================================
echo -e "\n${YELLOW}[1/4] Création structure Salt...${NC}"

mkdir -p "$SALT_DIR/states/hardening"
mkdir -p "$SALT_DIR/states/suma"
mkdir -p "$SALT_DIR/states/hpc"
mkdir -p "$SALT_DIR/files"

echo -e "${GREEN}  ✅ Structure créée${NC}"

# ============================================================================
# 2. TOP FILE
# ============================================================================
echo -e "\n${YELLOW}[2/4] Configuration top.sls...${NC}"

cat > "$SALT_DIR/states/top.sls" <<'EOF'
# Top File - Hiérarchie des States Salt
# SUSE Manager - Cluster HPC Defense

base:
  # Tous les nœuds - Hardening de base obligatoire
  '*':
    - hardening.sysctl
    - hardening.ssh
    - hardening.audit
    - hardening.aide
    - suma.minion-config

  # Frontaux de management
  'frontal-*':
    - match: glob
    - slurm.controller
    - auth.kerberos-server
    - security.bastion

  # Nœuds de calcul
  'compute-*':
    - match: glob
    - slurm.worker
    - hpc.mpi-config
EOF

echo -e "${GREEN}  ✅ top.sls configuré${NC}"

# ============================================================================
# 3. SALT STATE SUMA MINION
# ============================================================================
echo -e "\n${YELLOW}[3/4] Configuration Salt State SUMA...${NC}"

cat > "$SALT_DIR/states/suma/minion-config.sls" <<'EOF'
# Configuration Salt Minion - Intégration SUMA

suma-minion-config:
  file.managed:
    - name: /etc/salt/minion.d/suma-defense.conf
    - source: salt://files/suma-defense.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: salt-minion

  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - file: suma-minion-config
EOF

# Fichier de configuration SUMA
cat > "$SALT_DIR/files/suma-defense.conf" <<'EOF'
# Configuration Salt Minion pour SUMA Defense
master: {{ salt['pillar.get']('suma:master', 'suma-internal.defense.local') }}
master_port: 4506

# Sécurité
verify_master_pubkey_sign: True
always_verify_signature: True

# Grains
grains:
  suma_server: {{ salt['pillar.get']('suma:master', 'suma-internal.defense.local') }}
  cluster_role: {{ grains['host'] | regex_replace('-[0-9]+$', '') }}
EOF

echo -e "${GREEN}  ✅ Salt State SUMA configuré${NC}"

# ============================================================================
# 4. SALT STATE HARDENING
# ============================================================================
echo -e "\n${YELLOW}[4/4] Configuration Salt State Hardening...${NC}"

cat > "$SALT_DIR/states/hardening/sysctl.sls" <<'EOF'
# Hardening Kernel - sysctl
# DISA STIG SLES 15

hardening-sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 0
    - config: /etc/sysctl.d/99-hpc-hardening.conf

  sysctl.present:
    - name: net.ipv4.conf.all.send_redirects
    - value: 0

  sysctl.present:
    - name: net.ipv4.conf.all.accept_redirects
    - value: 0

  sysctl.present:
    - name: net.ipv4.conf.all.accept_source_route
    - value: 0

  sysctl.present:
    - name: kernel.unprivileged_bpf_disabled
    - value: 1
EOF

cat > "$SALT_DIR/states/hardening/ssh.sls" <<'EOF'
# Hardening SSH
# DISA STIG

hardening-ssh:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://files/sshd_config
    - backup: True
    - user: root
    - group: root
    - mode: 600

  service.running:
    - name: sshd
    - enable: True
    - reload: True
    - require:
      - file: hardening-ssh
EOF

echo -e "${GREEN}  ✅ Salt States Hardening configurés${NC}"

# ============================================================================
# RÉSUMÉ
# ============================================================================
echo -e "\n${GREEN}=== SALT STATES CONFIGURÉS ===${NC}"
echo "Répertoire: $SALT_DIR"
echo ""
echo "States créés:"
echo "  ✅ top.sls"
echo "  ✅ suma/minion-config.sls"
echo "  ✅ hardening/sysctl.sls"
echo "  ✅ hardening/ssh.sls"
echo ""
echo -e "${YELLOW}UTILISATION:${NC}"
echo "  # Appliquer sur tous les nœuds"
echo "  salt '*' state.apply"
echo ""
echo "  # Appliquer uniquement hardening"
echo "  salt '*' state.apply hardening"
echo ""
echo -e "${GREEN}Configuration terminée!${NC}"
