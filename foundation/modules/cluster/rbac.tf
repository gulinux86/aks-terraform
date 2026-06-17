# Azure RBAC for Kubernetes: grant the configured Entra object IDs cluster-admin
# at the cluster scope (the EKS access-entries equivalent). With local accounts
# disabled, this is how CI and operators get in.
resource "azurerm_role_assignment" "cluster_admin" {
  for_each = toset(var.cluster_admin_object_ids)

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
}
