output "node_pool_id" {
  value       = azurerm_kubernetes_cluster_node_pool.this.id
  description = "ID of the user node pool"
}
