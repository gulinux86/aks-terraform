# bootstrap — one-time, per-subscription.
#
# Creates the remote-state backend (Storage Account + container, native
# blob-lease lock, Key Vault customer-managed key) consumed by the foundation
# and workload layers. The GitHub Actions federated CI identity is in ci.tf.

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ---------------------------------------------------------------------------
# Key Vault + customer-managed key for state encryption.
#   - RBAC authorization (no access policies).
#   - Purge protection is REQUIRED for a Storage Account CMK.
# ---------------------------------------------------------------------------
resource "azurerm_key_vault" "state" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.state.location
  resource_group_name        = azurerm_resource_group.state.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  tags                       = var.tags
}

# The operator running bootstrap must be able to create the key.
resource "azurerm_role_assignment" "operator_kv_crypto_officer" {
  scope                = azurerm_key_vault.state.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "state" {
  name         = "tfstate-cmk"
  key_vault_id = azurerm_key_vault.state.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_role_assignment.operator_kv_crypto_officer]
}

# A user-assigned identity the Storage Account uses to reach the CMK. Using a
# dedicated identity (not the SA system identity) avoids the create-time cycle
# between the account and its key reference.
resource "azurerm_user_assigned_identity" "state_cmk" {
  name                = "${var.resource_group_name}-sa-cmk"
  location            = azurerm_resource_group.state.location
  resource_group_name = azurerm_resource_group.state.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "sa_cmk_encryption" {
  scope                = azurerm_key_vault.state.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.state_cmk.principal_id
}

# ---------------------------------------------------------------------------
# Storage Account + container for remote state.
#   - shared_access_key_enabled = false  → Entra-only (use_azuread_auth).
#   - blob versioning on; no public access; TLS 1.2.
#   - locking is the native blob lease — there is no lock table to create.
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "state" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.state_cmk.id]
  }

  blob_properties {
    versioning_enabled = true
  }

  tags = var.tags
}

resource "azurerm_storage_account_customer_managed_key" "state" {
  storage_account_id        = azurerm_storage_account.state.id
  key_vault_id              = azurerm_key_vault.state.id
  key_name                  = azurerm_key_vault_key.state.name
  user_assigned_identity_id = azurerm_user_assigned_identity.state_cmk.id

  depends_on = [azurerm_role_assignment.sa_cmk_encryption]
}

# Operator needs data-plane access to create the container (shared keys are off).
resource "azurerm_role_assignment" "operator_blob_owner" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_container" "state" {
  name                  = var.state_container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.operator_blob_owner]
}
