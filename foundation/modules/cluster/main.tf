# Private AKS cluster:
#   - private API server (Private Endpoint + AKS-managed private DNS zone)
#   - OIDC issuer + Workload Identity (for the IRSA-equivalent pattern)
#   - KMS etcd encryption backed by a customer-managed Key Vault key
#   - Entra integration + Azure RBAC for Kubernetes; local accounts disabled
#   - Azure CNI Overlay; NAT-Gateway egress (outbound via the node subnet)
#   - system node pool sized via variables (autoscaler)

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${var.project_name}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.project_name}-aks"
  kubernetes_version  = var.kubernetes_version
  sku_tier            = "Free" # $0 control plane for the portfolio baseline

  # --- private API server, no public endpoint ---
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = "System" # AKS manages the private DNS zone

  # --- Workload Identity prerequisites ---
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # --- authorization: Entra + Azure RBAC for Kubernetes, no local accounts ---
  local_account_disabled = true
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cluster.id]
  }

  # --- KMS etcd encryption (customer-managed key) ---
  key_management_service {
    key_vault_key_id         = azurerm_key_vault_key.etcd.id
    key_vault_network_access = "Public"
  }

  # --- Container Insights (Level 2) — enabled when a workspace is provided ---
  dynamic "oms_agent" {
    for_each = var.observability_enabled ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = true
    }
  }

  default_node_pool {
    name                   = "system"
    vm_size                = var.node_vm_size
    vnet_subnet_id         = var.node_subnet_id
    orchestrator_version   = var.kubernetes_version
    auto_scaling_enabled   = true
    node_count             = var.node_count
    min_count              = var.node_min_count
    max_count              = var.node_max_count
    node_public_ip_enabled = false
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"                 # enforce NetworkPolicy (deny-by-intent between pods)
    outbound_type       = "userAssignedNATGateway" # egress via the node subnet's NAT GW
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "172.16.0.0/16"
    dns_service_ip      = "172.16.0.10"
  }

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.cluster_etcd_kv, # key access must exist before KMS
  ]

  lifecycle {
    # Autoscaler owns node_count after creation; treat it as initial-only.
    ignore_changes = [default_node_pool[0].node_count]
  }
}
