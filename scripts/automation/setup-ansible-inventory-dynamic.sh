#!/bin/bash
# ============================================================================
# Configuration Inventaire Ansible Dynamique
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INVENTAIRE ANSIBLE DYNAMIQUE${NC}"
echo -e "${GREEN}========================================${NC}"

# Créer script inventaire dynamique
cat > /usr/local/bin/ansible-inventory-dynamic.sh <<'EOF'
#!/bin/bash
# Inventaire Ansible dynamique basé sur Slurm

echo '{
  "all": {
    "hosts": [],
    "children": {
      "frontals": {
        "hosts": []
      },
      "compute": {
        "hosts": []
      }
    }
  }
}'

# Récupérer nœuds depuis Slurm
sinfo -h -o "%N" | while read nodes; do
    echo "$nodes"
done
EOF

chmod +x /usr/local/bin/ansible-inventory-dynamic.sh

echo -e "${GREEN}✅ Inventaire dynamique créé${NC}"
