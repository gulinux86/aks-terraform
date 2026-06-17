output "identity_client_id" {
  value       = azurerm_user_assigned_identity.alb.client_id
  description = "Client ID of the ALB Controller identity (annotates the service account)"
}

output "service_account" {
  value       = "${var.controller_namespace}/${var.service_account_name}"
  description = "namespace/name of the controller service account bound by the federated credential"
}

output "extension_id" {
  value       = azurerm_kubernetes_cluster_extension.alb.id
  description = "ID of the ALB Controller cluster extension"
}
