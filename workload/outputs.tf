# Outputs for the workload layer. Consumed by the deploy workflow's
# `az aks command invoke` Helm step to install the ALB Controller.

output "alb_controller_identity_client_id" {
  value       = module.alb_controller.identity_client_id
  description = "Client ID of the ALB Controller identity (Helm: albController.podIdentity.clientID)"
}

output "alb_controller_namespace" {
  value       = module.alb_controller.controller_namespace
  description = "Namespace to install the ALB Controller into"
}

output "alb_controller_service_account" {
  value       = module.alb_controller.service_account
  description = "namespace/name of the controller service account bound by the federated credential"
}
