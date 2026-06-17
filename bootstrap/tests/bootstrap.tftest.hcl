# Mocked-provider unit tests for bootstrap — the CI federated-identity and state
# backend invariants (no client secret, no wildcard subject, CMK on state).

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      object_id       = "00000000-0000-0000-0000-000000000002"
      client_id       = "00000000-0000-0000-0000-000000000003"
      subscription_id = "00000000-0000-0000-0000-000000000004"
    }
  }
  mock_data "azurerm_subscription" {
    defaults = {
      id              = "/subscriptions/00000000-0000-0000-0000-000000000004"
      subscription_id = "00000000-0000-0000-0000-000000000004"
    }
  }
}

variables {
  storage_account_name = "akstfstatetest0001"
  github_repository    = "gulinux86/aks-terraform"
}

run "ci_federation_is_scoped_and_secretless" {
  command = plan

  # Deploy/destroy subjects are environment-scoped, plan is pull-request-scoped.
  assert {
    condition     = azurerm_federated_identity_credential.ci_hml.subject == "repo:gulinux86/aks-terraform:environment:hml"
    error_message = "hml deploy credential must be environment:hml scoped"
  }

  assert {
    condition     = azurerm_federated_identity_credential.ci_prod.subject == "repo:gulinux86/aks-terraform:environment:prod"
    error_message = "prod deploy credential must be environment:prod scoped"
  }

  assert {
    condition     = azurerm_federated_identity_credential.ci_plan.subject == "repo:gulinux86/aks-terraform:pull_request"
    error_message = "plan credential must be pull_request scoped"
  }

  # No credential may use a repo wildcard subject.
  assert {
    condition = alltrue([
      !strcontains(azurerm_federated_identity_credential.ci_hml.subject, ":*"),
      !strcontains(azurerm_federated_identity_credential.ci_prod.subject, ":*"),
      !strcontains(azurerm_federated_identity_credential.ci_plan.subject, ":*"),
    ])
    error_message = "No federated subject may use a repo wildcard"
  }
}

run "state_storage_uses_cmk_and_no_shared_keys" {
  command = plan

  assert {
    condition     = azurerm_storage_account.state.shared_access_key_enabled == false
    error_message = "State Storage Account must disable shared keys (Entra-only)"
  }

  assert {
    condition     = azurerm_storage_account.state.min_tls_version == "TLS1_2"
    error_message = "State Storage Account must require TLS 1.2"
  }

  assert {
    condition     = azurerm_key_vault.state.purge_protection_enabled == true
    error_message = "State Key Vault must have purge protection (required for CMK)"
  }
}
