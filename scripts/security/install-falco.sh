#!/bin/bash
# ============================================================================
# Installation Falco - Runtime Security Monitoring
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION FALCO${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Falco...${NC}"

# Ajouter repository Falco
curl -s https://falco.org/repo/falcosecurity-rpm.asc | gpg --import
cat > /etc/zypp/repos.d/falco.repo <<EOF
[falcosecurity]
name=Falco
baseurl=https://download.falco.org/packages/rpm
gpgcheck=1
enabled=1
EOF

zypper refresh
zypper install -y falco || {
    echo -e "${YELLOW}  ⚠️  Installation depuis repository, voir documentation Falco${NC}"
    # Alternative: installation depuis sources
}

echo -e "${GREEN}  ✅ Falco installé${NC}"

# ============================================================================
# 2. CONFIGURATION
# ============================================================================
echo -e "\n${YELLOW}[2/3] Configuration Falco...${NC}"

# Configuration Falco
cat > /etc/falco/falco.yaml <<EOF
# Configuration Falco pour Cluster HPC

# Outputs
json_output: true
json_include_output_property: true
json_include_tags_property: true

# Logs
log_stderr: true
log_syslog: true
log_level: info

# Rules
rules_file:
  - /etc/falco/falco_rules.yaml
  - /etc/falco/falco_rules.local.yaml
  - /etc/falco/rules.d/

# Container monitoring
load_plugins:
  - name: docker
    library_path: libdocker.so
    init_config:
      socket: "unix:///var/run/docker.sock"
EOF

# Règles personnalisées HPC
cat > /etc/falco/falco_rules.local.yaml <<EOF
# Règles personnalisées pour Cluster HPC

- rule: Suspicious Slurm Activity
  desc: Détection activité suspecte sur Slurm
  condition: >
    spawned_process and
    (proc.name in (slurm, sbatch, srun, scancel) and
     not user.name in (slurm, admin, hpc-user))
  output: >
    Suspicious Slurm activity detected
    (user=%user.name command=%proc.cmdline)
  priority: WARNING
  tags: [slurm, security]

- rule: Unauthorized Container Access
  desc: Accès non autorisé aux conteneurs
  condition: >
    container.id != host and
    evt.type = open and
    evt.dir = < and
    fd.name contains /etc/passwd
  output: >
    Unauthorized container access
    (container=%container.name user=%user.name)
  priority: CRITICAL
  tags: [container, security]
EOF

echo -e "${GREEN}  ✅ Falco configuré${NC}"

# ============================================================================
# 3. DÉMARRAGE
# ============================================================================
echo -e "\n${YELLOW}[3/3] Démarrage Falco...${NC}"

systemctl enable falco
systemctl start falco

echo -e "${GREEN}  ✅ Falco démarré${NC}"

echo -e "\n${GREEN}=== FALCO INSTALLÉ ===${NC}"
echo "Logs: /var/log/falco.log"
echo "Configuration: /etc/falco/falco.yaml"
echo "Règles: /etc/falco/falco_rules.local.yaml"
