# Variables Terraform - Cluster HPC

variable "prometheus_version" {
  description = "Version de Prometheus"
  type        = string
  default     = "v2.48.0"
}

variable "grafana_version" {
  description = "Version de Grafana"
  type        = string
  default     = "10.2.0"
}

variable "enable_monitoring" {
  description = "Activer le stack de monitoring"
  type        = bool
  default     = true
}

variable "enable_jupyterhub" {
  description = "Activer JupyterHub"
  type        = bool
  default     = true
}

variable "resource_limits" {
  description = "Limites de ressources par type de nœud"
  type = object({
    frontal = object({
      cpu    = string
      memory = string
    })
    compute = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    frontal = {
      cpu    = "4"
      memory = "8G"
    }
    compute = {
      cpu    = "8"
      memory = "16G"
    }
  }
}
