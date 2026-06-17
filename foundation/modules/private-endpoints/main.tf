# private-endpoints module
#
# Generic private-endpoint + private-DNS factory for PaaS dependencies (e.g. the
# state/etcd Key Vault), mirroring the EKS vpc-endpoints module. Driven by the
# `private_endpoints` map; empty by default (lean baseline). The AKS API server's
# private endpoint is AKS-managed and not configured here.

# One private DNS zone per distinct dns_zone_name across the requested endpoints.
locals {
  dns_zones = toset([for e in values(var.private_endpoints) : e.dns_zone_name])
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.dns_zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = azurerm_private_dns_zone.this
  name                  = "${replace(each.key, ".", "-")}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "this" {
  for_each            = var.private_endpoints
  name                = "${each.key}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = each.value.target_resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${each.key}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.this[each.value.dns_zone_name].id]
  }
}
