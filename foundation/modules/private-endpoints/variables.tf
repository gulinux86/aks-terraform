variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the private endpoints in"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID hosting the private endpoint NICs"
}

variable "vnet_id" {
  type        = string
  description = "VNet ID to link the private DNS zones to"
}

variable "private_endpoints" {
  description = <<-EOT
    Map of PaaS dependencies to expose via a private endpoint. Each entry creates
    a private endpoint + a private DNS zone (linked to the VNet). Example:
      { keyvault = {
          target_resource_id = "<kv id>"
          subresource_names   = ["vault"]
          dns_zone_name       = "privatelink.vaultcore.azure.net"
      } }
    The AKS API server's own private endpoint is managed by AKS (private_dns_zone_id
    = "System") and is NOT configured here.
  EOT
  type = map(object({
    target_resource_id = string
    subresource_names  = list(string)
    dns_zone_name      = string
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the private-endpoint resources"
}
