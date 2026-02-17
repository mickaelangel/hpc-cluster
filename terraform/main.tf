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
  
  # Backend configuration (optionnel)
  # backend "s3" {
  #   bucket = "hpc-cluster-terraform-state"
  #   key    = "cluster/terraform.tfstate"
  #   region = "us-east-1"
  # }
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
# Docker Networks
# ============================================================================

resource "docker_network" "management" {
  name = "${var.cluster_name}-management"
  
  ipam_config {
    subnet = var.docker_network_management
  }
  
  labels {
    label = "com.hpc.network"
    value = "management"
  }
}

resource "docker_network" "cluster" {
  name = "${var.cluster_name}-cluster"
  
  ipam_config {
    subnet = var.docker_network_cluster
  }
  
  labels {
    label = "com.hpc.network"
    value = "cluster"
  }
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
