# foundation — long-lived infrastructure.
#
# Resource group + VNet/NAT egress + private AKS (OIDC issuer, Workload Identity,
# KMS etcd encryption, Azure RBAC) + an optional user node pool. The AKS API
# server's private endpoint and DNS zone are AKS-managed (cluster module,
# private_dns_zone_id = "System"); the private-endpoints module is available for
# PaaS dependencies and is empty by default.

resource "azurerm_resource_group" "this" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_address_space  = var.vnet_address_space
  tags                = var.tags
}

module "cluster" {
  source = "./modules/cluster"

  project_name             = var.project_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  kubernetes_version       = var.kubernetes_version
  node_subnet_id           = module.network.node_subnet_id
  node_vm_size             = var.node_vm_size
  node_count               = var.node_count
  node_min_count           = var.node_min_count
  node_max_count           = var.node_max_count
  cluster_admin_object_ids = var.cluster_admin_object_ids
  tags                     = var.tags
}

module "node_pool" {
  source = "./modules/node-pool"
  count  = var.user_node_pool_enabled ? 1 : 0

  name                  = "user"
  kubernetes_cluster_id = module.cluster.cluster_id
  kubernetes_version    = var.kubernetes_version
  node_subnet_id        = module.network.node_subnet_id
  vm_size               = var.node_vm_size
  node_min_count        = var.node_min_count
  node_max_count        = var.node_max_count
  tags                  = var.tags
}

module "private_endpoints" {
  source = "./modules/private-endpoints"

  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.network.private_endpoint_subnet_id
  vnet_id             = module.network.vnet_id
  tags                = var.tags
  # private_endpoints = {} by default — lean baseline. Add PaaS dependencies
  # (e.g. the etcd Key Vault) here to keep their traffic on the VNet.
}

# OPTIONAL — Azure Bastion. `command invoke` covers CI; Bastion is ~$140-210/mo.
# module "bastion" {
#   source              = "./modules/bastion"
#   project_name        = var.project_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.this.name
#   subnet_id           = module.network.bastion_subnet_id
#   tags                = var.tags
# }
