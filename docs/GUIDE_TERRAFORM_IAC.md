# Guide Terraform - Infrastructure as Code
## Gestion Infrastructure avec Terraform

**Classification**: Documentation DevOps  
**Public**: Administrateurs / Ingénieurs  
**Version**: 1.0  
**Date**: 2024

---

## 📚 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation Terraform](#installation-terraform)
3. [Configuration](#configuration)
4. [Utilisation](#utilisation)
5. [Modules](#modules)
6. [State Management](#state-management)
7. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

**Terraform** : Outil Infrastructure as Code (IaC) pour provisionner et gérer l'infrastructure de manière déclarative.

### Bénéfices

- ✅ **Reproductibilité** : Infrastructure identique partout
- ✅ **Versioning** : Historique des changements
- ✅ **Idempotence** : Exécution multiple sans effet de bord
- ✅ **Collaboration** : Travail en équipe facilité

---

## 🚀 Installation Terraform

### Installation

```bash
./scripts/iac/install-terraform.sh
```

### Vérification

```bash
terraform version
```

---

## ⚙️ Configuration

### Structure Projet

```
terraform/
├── main.tf          # Configuration principale
├── variables.tf     # Variables
├── outputs.tf       # Sorties
├── terraform.tfstate # État (généré)
└── modules/         # Modules réutilisables
```

### Fichier main.tf

**Exemple basique** :
```hcl
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
```

### Fichier variables.tf

```hcl
variable "cluster_name" {
  description = "Nom du cluster HPC"
  type        = string
}

variable "node_count" {
  description = "Nombre de nœuds de calcul"
  type        = number
  default     = 6
}

variable "instance_type" {
  description = "Type d'instance"
  type        = string
  default     = "t3.medium"
}
```

### Fichier outputs.tf

```hcl
output "cluster_endpoint" {
  description = "Endpoint du cluster"
  value       = "http://${var.cluster_name}:3000"
}

output "node_ips" {
  description = "IPs des nœuds"
  value       = [for i in range(var.node_count) : "10.0.0.${201 + i}"]
}
```

---

## 📊 Utilisation

### Commandes de Base

**Initialisation** :
```bash
cd terraform
terraform init
```

**Planification** :
```bash
terraform plan
```

**Application** :
```bash
terraform apply
```

**Destruction** :
```bash
terraform destroy
```

### Workflow Complet

```bash
# 1. Initialiser
terraform init

# 2. Planifier
terraform plan -out=tfplan

# 3. Appliquer
terraform apply tfplan

# 4. Vérifier
terraform show

# 5. Sorties
terraform output
```

---

## 🧩 Modules

### Créer un Module

**Structure** :
```
modules/cluster-node/
├── main.tf
├── variables.tf
└── outputs.tf
```

**Utilisation** :
```hcl
module "compute_nodes" {
  source = "./modules/cluster-node"
  
  node_count = 6
  node_type  = "compute"
}
```

---

## 💾 State Management

### Backend Local

```hcl
backend "local" {
  path = "terraform.tfstate"
}
```

### Backend Remote (S3)

```hcl
backend "s3" {
  bucket = "hpc-cluster-terraform"
  key    = "terraform.tfstate"
  region = "us-east-1"
}
```

### State Locking

```hcl
backend "s3" {
  bucket         = "hpc-cluster-terraform"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-locks"
}
```

---

## 🔧 Dépannage

### Problèmes Courants

**State locké** :
```bash
# Forcer déverrouillage
terraform force-unlock <lock-id>
```

**State corrompu** :
```bash
# Vérifier state
terraform state list

# Importer ressource
terraform import <resource> <id>
```

**Erreur de validation** :
```bash
# Valider configuration
terraform validate

# Formater
terraform fmt
```

---

## 📚 Documentation Complémentaire

- `GUIDE_DEPLOIEMENT_PRODUCTION.md` - Déploiement production
- `GUIDE_INFRASTRUCTURE_PROFESSIONNELLE.md` - Infrastructure professionnelle
- `GUIDE_TROUBLESHOOTING.md` - Dépannage général

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
