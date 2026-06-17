# OPTIONAL Azure Bastion.
#
# Off by default — `az aks command invoke` covers CI access to the private API,
# and Bastion is ~$140 (Basic)–$210 (Standard)/mo. Kept as a hardening/ops
# add-on for interactive human access to nodes/jump hosts.

resource "azurerm_public_ip" "bastion" {
  name                = "${var.project_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "${var.project_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
