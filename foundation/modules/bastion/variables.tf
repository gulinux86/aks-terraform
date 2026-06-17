variable "project_name" {
  type        = string
  description = "Project name used to name the bastion resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the bastion in"
}

variable "subnet_id" {
  type        = string
  description = "AzureBastionSubnet ID"
}

variable "sku" {
  type        = string
  description = "Bastion SKU (Basic or Standard)"
  default     = "Basic"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the bastion resources"
}
