# Optional additional USER node pool.
#
# The system node pool lives inline in the cluster module's default_node_pool
# (AKS requires exactly one). This module mirrors the EKS managed-node-group as a
# separate, composable user pool; foundation instantiates it behind a toggle and
# it is off by default for the lean baseline.

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = var.name
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.vm_size
  orchestrator_version  = var.kubernetes_version
  vnet_subnet_id        = var.node_subnet_id
  mode                  = "User"

  auto_scaling_enabled   = true
  min_count              = var.node_min_count
  max_count              = var.node_max_count
  node_public_ip_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}
