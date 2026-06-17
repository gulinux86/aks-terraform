variable "project_name" {
  type        = string
  description = "Project name used to name the Log Analytics workspace"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the workspace in"
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics retention in days"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the workspace"
}
