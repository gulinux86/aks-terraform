# Consumed by the `workload` layer via terraform_remote_state, and by operators.

output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "AKS cluster name"
}

output "cluster_id" {
  value       = module.cluster.cluster_id
  description = "AKS cluster resource ID (consumed by the workload cluster extension)"
}

output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Resource group, reused by the workload layer"
}

output "oidc_issuer_url" {
  value       = module.cluster.oidc_issuer_url
  description = "Cluster OIDC issuer URL (used for Workload Identity federated credentials)"
}

output "node_resource_group" {
  value       = module.cluster.node_resource_group
  description = "AKS-managed node resource group"
}

output "vnet_id" {
  value       = module.network.vnet_id
  description = "VNet ID, reused by the workload layer"
}

output "alb_subnet_id" {
  value       = module.network.alb_subnet_id
  description = "Delegated subnet for Application Gateway for Containers (consumed by the workload layer)"
}

output "location" {
  value       = var.location
  description = "Azure region, reused by the workload layer"
}

output "tags" {
  value       = var.tags
  description = "Project tags, reused by the workload layer"
}
