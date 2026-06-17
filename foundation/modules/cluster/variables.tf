variable "project_name" {
  type        = string
  description = "Project name used to name the cluster and related resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the cluster in"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version (pin a version in standard support)"
}

variable "node_subnet_id" {
  type        = string
  description = "Subnet ID for the system node pool (NAT-Gateway egress)"
}

variable "node_vm_size" {
  type        = string
  description = "VM size for the system node pool"
}

variable "node_count" {
  type        = number
  description = "Desired number of nodes in the system node pool"
}

variable "node_min_count" {
  type        = number
  description = "Minimum nodes (autoscaler)"
}

variable "node_max_count" {
  type        = number
  description = "Maximum nodes (autoscaler)"
}

variable "cluster_admin_object_ids" {
  type        = list(string)
  description = "Entra object IDs granted AKS RBAC Cluster Admin (e.g. the CI deploy identity)"
  default     = []
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID. When set, enables Container Insights (oms_agent, Level 2) and control-plane diagnostic logs (Level 1). Null = no observability (lean baseline)."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the cluster resources"
}
