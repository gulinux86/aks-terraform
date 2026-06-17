output "private_endpoint_ids" {
  value       = { for k, pe in azurerm_private_endpoint.this : k => pe.id }
  description = "Map of created private endpoint IDs, keyed by the input map key"
}

output "private_dns_zone_ids" {
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
  description = "Map of created private DNS zone IDs, keyed by zone name"
}
