output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "VNet ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "VNet name"
}

output "node_subnet_id" {
  value       = azurerm_subnet.nodes.id
  description = "Subnet ID for the AKS node pool (NAT-Gateway egress)"
}

output "alb_subnet_id" {
  value       = azurerm_subnet.alb.id
  description = "Delegated subnet ID for Application Gateway for Containers"
}

output "private_endpoint_subnet_id" {
  value       = azurerm_subnet.private_endpoints.id
  description = "Subnet ID for private endpoints"
}

output "bastion_subnet_id" {
  value       = azurerm_subnet.bastion.id
  description = "AzureBastionSubnet ID (for the optional bastion module)"
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.this.id
  description = "NAT Gateway ID providing node egress"
}
