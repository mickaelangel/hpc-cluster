# ============================================================================
# Terraform Module - Monitoring Stack
# ============================================================================

variable "cluster_name" {
  description = "Nom du cluster"
  type        = string
}

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

variable "influxdb_version" {
  description = "Version d'InfluxDB"
  type        = string
  default     = "2.7"
}

variable "loki_version" {
  description = "Version de Loki"
  type        = string
  default     = "2.9.0"
}

variable "network_id" {
  description = "ID du réseau Docker"
  type        = string
}

# Prometheus
resource "docker_image" "prometheus" {
  name = "prom/prometheus:${var.prometheus_version}"
}

resource "docker_container" "prometheus" {
  name  = "${var.cluster_name}-prometheus"
  image = docker_image.prometheus.image_id
  
  networks_advanced {
    name = var.network_id
  }
  
  ports {
    internal = 9090
    external = 9090
  }
  
  volumes {
    host_path      = "${path.module}/../../configs/prometheus"
    container_path = "/etc/prometheus"
  }
  
  restart = "always"
  
  labels = {
    "com.hpc.service" = "prometheus"
    "com.hpc.cluster" = var.cluster_name
  }
}

# Grafana
resource "docker_image" "grafana" {
  name = "grafana/grafana:${var.grafana_version}"
}

resource "docker_container" "grafana" {
  name  = "${var.cluster_name}-grafana"
  image = docker_image.grafana.image_id
  
  networks_advanced {
    name = var.network_id
  }
  
  ports {
    internal = 3000
    external = 3000
  }
  
  restart = "always"
  
  labels = {
    "com.hpc.service" = "grafana"
    "com.hpc.cluster" = var.cluster_name
  }
}

output "prometheus_url" {
  value = "http://localhost:9090"
}

output "grafana_url" {
  value = "http://localhost:3000"
}
