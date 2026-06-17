variable "name" {
  type        = string
  description = "Node pool name (lowercase alphanumeric, <= 12 chars)"
  default     = "user"
}

variable "kubernetes_cluster_id" {
  type        = string
  description = "ID of the AKS cluster to attach this node pool to"
}

variable "kubernetes_version" {
  type        = string
  description = "Orchestrator version for the node pool"
}

variable "node_subnet_id" {
  type        = string
  description = "Subnet ID for the node pool (NAT-Gateway egress)"
}

variable "vm_size" {
  type        = string
  description = "VM size for the node pool"
}

variable "node_min_count" {
  type        = number
  description = "Minimum nodes (autoscaler)"
}

variable "node_max_count" {
  type        = number
  description = "Maximum nodes (autoscaler)"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the node pool"
}
