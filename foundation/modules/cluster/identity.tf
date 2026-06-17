# Dedicated user-assigned identity for the cluster control plane. Used (rather
# than a system-assigned identity) so it can be granted Key Vault access for KMS
# etcd encryption BEFORE the cluster is created, avoiding a create-time cycle.
resource "azurerm_user_assigned_identity" "cluster" {
  name                = "${var.project_name}-aks-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
