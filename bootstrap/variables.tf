variable "location" {
  type        = string
  description = "Azure region for the bootstrap resources (state Storage Account, Key Vault, CI identity)"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group that holds the state Storage Account and Key Vault. Must match environments/<env>/backend.hcl."
  default     = "aks-tfstate-rg"
}

variable "storage_account_name" {
  type        = string
  description = "Globally-unique Storage Account name for the foundation/workload remote state. Must match the account in environments/<env>/backend.hcl."
}

variable "state_container_name" {
  type        = string
  description = "Blob container holding the remote state"
  default     = "tfstate"
}

variable "key_vault_name" {
  type        = string
  description = "Globally-unique Key Vault name (<= 24 chars) holding the state customer-managed key. Override if the default collides."
  default     = "aks-tfstate-cmk-kv"

  validation {
    condition     = length(var.key_vault_name) <= 24
    error_message = "Key Vault names must be 24 characters or fewer."
  }
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to federate, as owner/name"
  default     = "gulinux86/aks-terraform"
}

variable "ci_identity_name" {
  type        = string
  description = "Name of the user-assigned managed identity GitHub Actions federates into"
  default     = "github-actions-aks-terraform"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the created bootstrap resources"
  default = {
    Project   = "aks"
    ManagedBy = "terraform"
    Layer     = "bootstrap"
  }
}
