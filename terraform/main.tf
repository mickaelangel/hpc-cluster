# ============================================================================
# Terraform Configuration - Cluster HPC Infrastructure
# Infrastructure as Code pour déploiement cloud/on-premise
# ============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  
  # Backend configuration - Voir backend.tf.example
  # Pour production, utiliser un backend distant (S3, Azure, GCS, etc.)
}

# ============================================================================
# Variables
# ============================================================================

variable "cluster_name" {
  description = "Nom du cluster HPC"
  type        = string
  default     = "hpc-cluster"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "frontend_nodes" {
  description = "Nombre de nœuds frontaux"
  type        = number
  default     = 2
}

variable "compute_nodes" {
  description = "Nombre de nœuds de calcul"
  type        = number
  default     = 6
}

variable "docker_network_management" {
  description = "Réseau Docker pour management"
  type        = string
  default     = "172.20.0.0/24"
}

variable "docker_network_cluster" {
  description = "Réseau Docker pour cluster"
  type        = string
  default     = "10.0.0.0/24"
}

# ============================================================================
# Provider Configuration
# ============================================================================

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# ============================================================================
# Modules
# ============================================================================

module "network" {
  source = "./modules/network"
  
  cluster_name      = var.cluster_name
  management_subnet = var.docker_network_management
  cluster_subnet    = var.docker_network_cluster
}

module "monitoring" {
  source = "./modules/monitoring"
  
  cluster_name      = var.cluster_name
  prometheus_version = var.prometheus_version
  grafana_version   = var.grafana_version
  network_id        = module.network.management_network_id
}

# ============================================================================
# Outputs
# ============================================================================

output "cluster_name" {
  description = "Nom du cluster"
  value       = var.cluster_name
}

output "management_network" {
  description = "Réseau management"
  value       = docker_network.management.name
}

output "cluster_network" {
  description = "Réseau cluster"
  value       = docker_network.cluster.name
}
