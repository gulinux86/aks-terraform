variable "project_name" {
  type        = string
  description = "Project name used to name network resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the network resources in"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the VNet"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all network resources"
}
