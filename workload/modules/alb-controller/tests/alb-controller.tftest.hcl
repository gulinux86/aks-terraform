# Mocked-provider unit tests for the ALB Controller module — Workload Identity
# least-privilege invariants and the extension (not Helm) install path.

mock_provider "azurerm" {}

variables {
  project_name        = "test"
  location            = "eastus"
  resource_group_name = "test-rg"
  cluster_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
  oidc_issuer_url     = "https://oidc.example/test"
  alb_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/alb"
  tags                = { env = "test" }
}

run "workload_identity_and_extension_invariants" {
  command = plan

  # Federated credential is scoped to exactly one service account, no wildcard.
  assert {
    condition     = azurerm_federated_identity_credential.alb.subject == "system:serviceaccount:azure-alb-system:alb-controller-sa"
    error_message = "Federated subject must be a single system:serviceaccount:<ns>:<sa>"
  }

  assert {
    condition     = !strcontains(azurerm_federated_identity_credential.alb.subject, "*")
    error_message = "Federated subject must not be a wildcard"
  }

  assert {
    condition     = contains(azurerm_federated_identity_credential.alb.audience, "api://AzureADTokenExchange")
    error_message = "Federated audience must be api://AzureADTokenExchange"
  }

  assert {
    condition     = azurerm_federated_identity_credential.alb.issuer == var.oidc_issuer_url
    error_message = "Federated issuer must be the cluster OIDC issuer URL"
  }

  # Installed as a managed cluster extension — never via helm/kubernetes providers.
  assert {
    condition     = azurerm_kubernetes_cluster_extension.alb.cluster_id == var.cluster_id
    error_message = "ALB Controller must target the cluster via a cluster extension"
  }
}
