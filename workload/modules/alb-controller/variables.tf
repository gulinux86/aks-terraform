variable "project_name" {
  type        = string
  description = "Project name used to name the controller identity"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group of the cluster (scope for the controller's role assignments)"
}

variable "cluster_id" {
  type        = string
  description = "AKS cluster resource ID (target for the cluster extension)"
}

variable "oidc_issuer_url" {
  type        = string
  description = "Cluster OIDC issuer URL (federated-credential issuer)"
}

variable "alb_subnet_id" {
  type        = string
  description = "Delegated subnet for Application Gateway for Containers (Network Contributor scope)"
}

variable "controller_namespace" {
  type        = string
  description = "Namespace the ALB Controller runs in"
  default     = "azure-alb-system"
}

variable "service_account_name" {
  type        = string
  description = "Service account the controller uses (bound by the federated credential)"
  default     = "alb-controller-sa"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the controller identity"
}
