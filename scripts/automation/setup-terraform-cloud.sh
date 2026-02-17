#!/bin/bash
# ============================================================================
# Configuration Terraform Cloud
# ============================================================================

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CONFIGURATION TERRAFORM CLOUD${NC}"
echo -e "${GREEN}========================================${NC}"

# Configuration Terraform Cloud backend
cat > terraform-cloud-backend.tf <<EOF
terraform {
  backend "remote" {
    organization = "cluster-hpc"
    workspaces {
      name = "cluster-infrastructure"
    }
  }
}
EOF

echo -e "${GREEN}✅ Configuration Terraform Cloud créée${NC}"
echo -e "${YELLOW}⚠️  Nécessite compte Terraform Cloud${NC}"
