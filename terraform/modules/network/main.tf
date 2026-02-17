# ============================================================================
# Terraform Module - Network Configuration
# ============================================================================

variable "cluster_name" {
  description = "Nom du cluster"
  type        = string
}

variable "management_subnet" {
  description = "Subnet pour réseau management"
  type        = string
  default     = "172.20.0.0/24"
}

variable "cluster_subnet" {
  description = "Subnet pour réseau cluster"
  type        = string
  default     = "10.0.0.0/24"
}

variable "storage_subnet" {
  description = "Subnet pour réseau storage"
  type        = string
  default     = "10.10.10.0/24"
}

resource "docker_network" "management" {
  name = "${var.cluster_name}-management"
  
  ipam_config {
    subnet = var.management_subnet
  }
  
  labels = {
    "com.hpc.network" = "management"
    "com.hpc.cluster" = var.cluster_name
  }
}

resource "docker_network" "cluster" {
  name = "${var.cluster_name}-cluster"
  
  ipam_config {
    subnet = var.cluster_subnet
  }
  
  labels = {
    "com.hpc.network" = "cluster"
    "com.hpc.cluster" = var.cluster_name
  }
}

resource "docker_network" "storage" {
  name = "${var.cluster_name}-storage"
  
  ipam_config {
    subnet = var.storage_subnet
  }
  
  labels = {
    "com.hpc.network" = "storage"
    "com.hpc.cluster" = var.cluster_name
  }
}

output "management_network_id" {
  value = docker_network.management.id
}

output "cluster_network_id" {
  value = docker_network.cluster.id
}

output "storage_network_id" {
  value = docker_network.storage.id
}
