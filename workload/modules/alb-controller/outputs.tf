output "identity_client_id" {
  value       = azurerm_user_assigned_identity.alb.client_id
  description = "Client ID of the ALB Controller identity (passed to the Helm release: albController.podIdentity.clientID)"
}

output "controller_namespace" {
  value       = var.controller_namespace
  description = "Namespace the ALB Controller is installed into (Helm --namespace)"
}

output "service_account_name" {
  value       = var.service_account_name
  description = "Service account bound by the federated credential (must match the chart's SA)"
}

output "service_account" {
  value       = "${var.controller_namespace}/${var.service_account_name}"
  description = "namespace/name of the controller service account"
}
