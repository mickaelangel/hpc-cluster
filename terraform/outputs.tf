# ============================================================================
# Terraform Outputs
# ============================================================================

output "cluster_name" {
  description = "Nom du cluster déployé"
  value       = var.cluster_name
}

output "management_network" {
  description = "Réseau management"
  value       = module.network.management_network_id
}

output "cluster_network" {
  description = "Réseau cluster"
  value       = module.network.cluster_network_id
}

output "storage_network" {
  description = "Réseau storage"
  value       = module.network.storage_network_id
}

output "prometheus_url" {
  description = "URL Prometheus"
  value       = module.monitoring.prometheus_url
}

output "grafana_url" {
  description = "URL Grafana"
  value       = module.monitoring.grafana_url
}

output "environment" {
  description = "Environnement déployé"
  value       = var.environment
}
