# Mocked-provider unit tests for the cluster module — the security invariants of
# the private AKS posture. `command = plan` against a mock azurerm provider, so
# no Azure creds and no infrastructure are required.

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      object_id       = "00000000-0000-0000-0000-000000000002"
      client_id       = "00000000-0000-0000-0000-000000000003"
      subscription_id = "00000000-0000-0000-0000-000000000004"
    }
  }
}

variables {
  project_name        = "test"
  location            = "eastus"
  resource_group_name = "test-rg"
  kubernetes_version  = "1.31"
  node_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/nodes"
  node_vm_size        = "Standard_B2s"
  node_count          = 2
  node_min_count      = 1
  node_max_count      = 3
  tags                = { env = "test" }
}

run "private_cluster_security_invariants" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_enabled == true
    error_message = "API server must be private (private_cluster_enabled)"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_public_fqdn_enabled == false
    error_message = "No public FQDN may be exposed for the API server"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.oidc_issuer_enabled == true
    error_message = "OIDC issuer must be enabled for Workload Identity"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.workload_identity_enabled == true
    error_message = "Workload Identity must be enabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.local_account_disabled == true
    error_message = "Local accounts must be disabled (Entra-only)"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_active_directory_role_based_access_control[0].azure_rbac_enabled == true
    error_message = "Azure RBAC for Kubernetes must be enabled"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.key_management_service) == 1
    error_message = "KMS etcd encryption (customer-managed key) must be configured"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].outbound_type == "userAssignedNATGateway"
    error_message = "Egress must route through the user-assigned NAT Gateway"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.network_profile[0].network_plugin_mode == "overlay"
    error_message = "Network plugin mode must be Azure CNI Overlay"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].node_public_ip_enabled == false
    error_message = "Nodes must not have public IPs"
  }
}

run "no_observability_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 0
    error_message = "Container Insights must be off when no workspace is provided"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.aks) == 0
    error_message = "Diagnostic settings must be off when no workspace is provided"
  }
}

run "observability_when_workspace_wired" {
  command = plan

  variables {
    observability_enabled      = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 1
    error_message = "Container Insights (oms_agent) must be enabled when a workspace is provided"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.aks) == 1
    error_message = "Control-plane diagnostic settings must be created when a workspace is provided"
  }
}
