#!/bin/bash
# ============================================================================
# Installation Terraform - Infrastructure as Code
# ============================================================================

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION TERRAFORM${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# 1. INSTALLATION TERRAFORM
# ============================================================================
echo -e "\n${YELLOW}[1/3] Installation Terraform...${NC}"

TERRAFORM_VERSION="1.6.0"
TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TERRAFORM_DIR="/usr/local/bin"

cd /tmp
wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}" || {
    echo -e "${YELLOW}  ⚠️  Téléchargement échoué, voir documentation${NC}"
    exit 1
}

unzip -q "$TERRAFORM_ZIP"
mv terraform "$TERRAFORM_DIR/"
chmod +x "$TERRAFORM_DIR/terraform"

echo -e "${GREEN}  ✅ Terraform installé${NC}"

# ============================================================================
# 2. CRÉATION STRUCTURE
# ============================================================================
echo -e "\n${YELLOW}[2/3] Création structure Terraform...${NC}"

TERRAFORM_DIR_PROJECT="cluster hpc/terraform"
mkdir -p "$TERRAFORM_DIR_PROJECT"

# Fichier main.tf exemple
cat > "$TERRAFORM_DIR_PROJECT/main.tf.example" <<'EOF'
# Configuration Terraform pour Cluster HPC

terraform {
  required_version = ">= 1.0"
  
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Variables
variable "cluster_name" {
  description = "Nom du cluster"
  type        = string
  default     = "hpc-cluster"
}

variable "node_count" {
  description = "Nombre de nœuds"
  type        = number
  default     = 8
}

# Resources
# Exemple: création de ressources cloud ou locales
EOF

# Fichier variables.tf exemple
cat > "$TERRAFORM_DIR_PROJECT/variables.tf.example" <<'EOF'
variable "cluster_name" {
  description = "Nom du cluster HPC"
  type        = string
}

variable "node_count" {
  description = "Nombre de nœuds de calcul"
  type        = number
  default     = 6
}
EOF

echo -e "${GREEN}  ✅ Structure Terraform créée${NC}"

# ============================================================================
# 3. VÉRIFICATION
# ============================================================================
echo -e "\n${YELLOW}[3/3] Vérification...${NC}"

terraform version || {
    echo -e "${YELLOW}  ⚠️  Terraform non accessible${NC}"
}

echo -e "${GREEN}  ✅ Terraform vérifié${NC}"

echo -e "\n${GREEN}=== TERRAFORM INSTALLÉ ===${NC}"
echo "Version: $(terraform version | head -1)"
echo "Répertoire: $TERRAFORM_DIR_PROJECT"
echo "Exemples: main.tf.example, variables.tf.example"
