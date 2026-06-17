# network module
#
# VNet + subnets (nodes / app-gateway-for-containers / private-endpoints /
# bastion) and a NAT Gateway providing deterministic egress for the node subnet.
#
# Subnets are carved from the first VNet address-space prefix:
#   nodes             /20  (large pod/node IP budget with Azure CNI Overlay)
#   app-gw-containers /24  (delegated to the ALB Controller / AGC)
#   private-endpoints /24
#   bastion           /26  (AzureBastionSubnet — required name if Bastion is used)

locals {
  base_cidr    = var.vnet_address_space[0]
  nodes_cidr   = cidrsubnet(local.base_cidr, 4, 0)   # /20
  alb_cidr     = cidrsubnet(local.base_cidr, 8, 16)  # /24
  pe_cidr      = cidrsubnet(local.base_cidr, 8, 17)  # /24
  bastion_cidr = cidrsubnet(local.base_cidr, 10, 72) # /26
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "nodes" {
  name                 = "${var.project_name}-snet-nodes"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.nodes_cidr]
}

resource "azurerm_subnet" "alb" {
  name                 = "${var.project_name}-snet-alb"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.alb_cidr]

  # Application Gateway for Containers requires a delegated subnet.
  delegation {
    name = "alb-delegation"
    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "${var.project_name}-snet-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.pe_cidr]
}

# AzureBastionSubnet must use exactly this name; created so an optional Bastion
# can be attached later without re-shaping the VNet.
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.bastion_cidr]
}

# ---------------------------------------------------------------------------
# NAT Gateway egress for the node subnet (deterministic outbound, no node
# public IPs). Single NAT Gateway for the lean baseline; collapse/expand per
# zone is a documented cost lever (see ARCHITECTURE.md).
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "nat" {
  name                = "${var.project_name}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                    = "${var.project_name}-nat"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "nodes" {
  subnet_id      = azurerm_subnet.nodes.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}
