variable "project_name" {
  type        = string
  description = "Project name used to name resources"
}

variable "location" {
  type        = string
  description = "Azure region to create the resources"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the AKS cluster. Pin a version in standard support."
  default     = "1.31"
}

variable "node_vm_size" {
  type        = string
  description = "VM size for the system node pool. B-series (burstable) is the cheap portfolio default."
  default     = "Standard_B2s"
}

variable "node_count" {
  type        = number
  description = "Desired number of nodes in the system node pool"
  default     = 2
}

variable "node_min_count" {
  type        = number
  description = "Minimum nodes (autoscaler)"
  default     = 1
}

variable "node_max_count" {
  type        = number
  description = "Maximum nodes (autoscaler)"
  default     = 3
}

variable "cluster_admin_object_ids" {
  type        = list(string)
  description = "Entra object IDs granted AKS cluster-admin via Azure RBAC for Kubernetes (typically the CI deploy identity)."
  default     = []
}

variable "user_node_pool_enabled" {
  type        = bool
  description = "Create an additional user node pool (separate module). Off by default for the lean baseline; the system pool runs workloads."
  default     = false
}

variable "observability_enabled" {
  type        = bool
  description = "Create a Log Analytics workspace and enable control-plane diagnostic logs (Level 1) + Container Insights (Level 2) on the cluster."
  default     = false
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics retention in days (when observability is enabled)"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}
