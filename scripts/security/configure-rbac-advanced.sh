#!/bin/bash
# ============================================================================
# Configuration RBAC Avancé - Cluster HPC
# Gestion des Rôles et Permissions
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CONFIGURATION RBAC AVANCÉ${NC}"
echo -e "${BLUE}========================================${NC}"

# Configuration RBAC Slurm
echo -e "\n${YELLOW}[1/3] Configuration RBAC Slurm...${NC}"

# Créer répertoire si nécessaire
mkdir -p /etc/slurm

# Créer groupes de rôles
cat > /etc/slurm/roles.conf <<EOF
# Rôles Slurm
Role:admin
  AllowAccounts=*
  AllowPartitions=*
  AllowQOS=*

Role:user
  AllowAccounts=user_*
  AllowPartitions=normal
  AllowQOS=normal

Role:researcher
  AllowAccounts=research_*
  AllowPartitions=normal,gpu
  AllowQOS=normal,premium
EOF

# Configuration RBAC Stockage
echo -e "\n${YELLOW}[2/3] Configuration RBAC Stockage...${NC}"

# Créer répertoire si nécessaire
mkdir -p /etc/storage

# Quotas et permissions par rôle
cat > /etc/storage/rbac.conf <<EOF
# RBAC Stockage
Role:admin
  Quota=unlimited
  Access=read-write

Role:user
  Quota=100GB
  Access=read-write

Role:guest
  Quota=10GB
  Access=read-only
EOF

# Audit des permissions
echo -e "\n${YELLOW}[3/3] Configuration Audit Permissions...${NC}"

cat > /usr/local/bin/audit-permissions.sh <<'EOF'
#!/bin/bash
# Audit des permissions
echo "=== Audit Permissions ==="
echo "Date: $(date)"
echo ""
echo "Utilisateurs et groupes:"
getent passwd | awk -F: '{print $1, $3, $4}'
echo ""
echo "Permissions fichiers sensibles:"
find /etc -type f -perm -002 2>/dev/null
EOF

chmod +x /usr/local/bin/audit-permissions.sh

echo -e "\n${GREEN}✅ RBAC avancé configuré${NC}"
