# Outputs consumed when wiring CI secrets and the layer backends.

output "ci_client_id" {
  value       = azurerm_user_assigned_identity.ci.client_id
  description = "Client ID of the CI identity. Set as the AZURE_CLIENT_ID GitHub secret/variable."
}

output "ci_principal_id" {
  value       = azurerm_user_assigned_identity.ci.principal_id
  description = "Principal (object) ID of the CI identity. Use in cluster_admin_object_ids so CI can drive the cluster."
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Entra tenant ID. Set as the AZURE_TENANT_ID GitHub secret/variable."
}

output "subscription_id" {
  value       = data.azurerm_subscription.current.subscription_id
  description = "Subscription ID. Set as the AZURE_SUBSCRIPTION_ID GitHub secret/variable."
}

output "state_resource_group" {
  value       = azurerm_resource_group.state.name
  description = "Resource group holding the state Storage Account and Key Vault"
}

output "state_storage_account" {
  value       = azurerm_storage_account.state.name
  description = "Storage Account holding the foundation/workload remote state"
}

output "state_container" {
  value       = azurerm_storage_container.state.name
  description = "Blob container holding the remote state"
}
