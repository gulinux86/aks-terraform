# Outputs for the workload layer.

output "alb_controller_identity_client_id" {
  value       = module.alb_controller.identity_client_id
  description = "Client ID of the ALB Controller identity (for service-account annotation / verification)"
}

output "alb_controller_service_account" {
  value       = module.alb_controller.service_account
  description = "namespace/name of the controller service account bound by the federated credential"
}

output "alb_controller_extension_id" {
  value       = module.alb_controller.extension_id
  description = "ID of the ALB Controller cluster extension"
}
