output "cluster_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name"
}

output "cluster_id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "AKS cluster resource ID (consumed by the workload cluster extension)"
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "Cluster OIDC issuer URL (used for Workload Identity federated credentials)"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.this.node_resource_group
  description = "AKS-managed node resource group"
}

output "kubelet_identity_object_id" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
  description = "Object ID of the kubelet identity"
}

output "cluster_identity_principal_id" {
  value       = azurerm_user_assigned_identity.cluster.principal_id
  description = "Principal ID of the cluster control-plane identity"
}
