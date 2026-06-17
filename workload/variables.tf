variable "foundation_state_resource_group" {
  type        = string
  description = "Resource group of the Storage Account holding the foundation remote state"
}

variable "foundation_state_storage_account" {
  type        = string
  description = "Storage Account holding the foundation remote state"
}

variable "foundation_state_container" {
  type        = string
  description = "Blob container holding the foundation remote state"
  default     = "tfstate"
}

variable "foundation_state_key" {
  type        = string
  description = "Blob key of the foundation remote state (e.g. foundation/hml/terraform.tfstate)"
}
