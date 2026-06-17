# Key Vault + key for KMS etcd encryption (customer-managed key for Kubernetes
# secrets at rest). Purge protection is required for KMS; RBAC authorization.
locals {
  etcd_kv_name = substr("${replace(var.project_name, "-", "")}etcdkv", 0, 24)
}

resource "azurerm_key_vault" "etcd" {
  name                       = local.etcd_kv_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  tags                       = var.tags
}

# Operator creating the key needs crypto-officer on the vault.
resource "azurerm_role_assignment" "operator_etcd_kv" {
  scope                = azurerm_key_vault.etcd.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# The cluster identity must use the key for envelope encryption.
resource "azurerm_role_assignment" "cluster_etcd_kv" {
  scope                = azurerm_key_vault.etcd.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
}

resource "azurerm_key_vault_key" "etcd" {
  name         = "etcd-encryption"
  key_vault_id = azurerm_key_vault.etcd.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.operator_etcd_kv]
}
