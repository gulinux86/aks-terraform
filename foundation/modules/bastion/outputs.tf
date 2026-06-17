output "bastion_id" {
  value       = azurerm_bastion_host.this.id
  description = "Azure Bastion host ID"
}

output "bastion_fqdn" {
  value       = azurerm_bastion_host.this.dns_name
  description = "Bastion DNS name"
}
