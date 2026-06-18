# GitHub Actions → Azure via Workload Identity Federation (no client secret).
#
# One user-assigned identity holds three federated credentials, each matching a
# specific GitHub OIDC subject:
#   - pull_request          → plan (read-only feedback on PRs)
#   - environment:hml       → deploy/destroy in hml
#   - environment:prod      → deploy/destroy in prod (prod env reviewer-gated)
# No `repo:*` wildcard subject exists, so arbitrary branches cannot federate.

resource "azurerm_user_assigned_identity" "ci" {
  name                = var.ci_identity_name
  location            = azurerm_resource_group.state.location
  resource_group_name = azurerm_resource_group.state.name
  tags                = var.tags
}

locals {
  github_oidc_issuer = "https://token.actions.githubusercontent.com"
  github_audience    = ["api://AzureADTokenExchange"]
}

resource "azurerm_federated_identity_credential" "ci_plan" {
  name                      = "github-plan-pull-request"
  user_assigned_identity_id = azurerm_user_assigned_identity.ci.id
  audience                  = local.github_audience
  issuer                    = local.github_oidc_issuer
  subject                   = "repo:${var.github_repository}:pull_request"
}

resource "azurerm_federated_identity_credential" "ci_hml" {
  name                      = "github-deploy-hml"
  user_assigned_identity_id = azurerm_user_assigned_identity.ci.id
  audience                  = local.github_audience
  issuer                    = local.github_oidc_issuer
  subject                   = "repo:${var.github_repository}:environment:hml"
}

resource "azurerm_federated_identity_credential" "ci_prod" {
  name                      = "github-deploy-prod"
  user_assigned_identity_id = azurerm_user_assigned_identity.ci.id
  audience                  = local.github_audience
  issuer                    = local.github_oidc_issuer
  subject                   = "repo:${var.github_repository}:environment:prod"
}

# ---------------------------------------------------------------------------
# CI role assignments.
#   - Contributor: create/destroy the foundation + workload resources.
#   - Role Based Access Control Administrator: the foundation/workload layers
#     create role assignments for workload identities, which Contributor cannot
#     do. Scoped to this subscription.
#   - Storage Blob Data Contributor: read/write remote state (shared keys off).
#   - Key Vault Crypto User: the spec requires Terraform principals to hold the
#     Key Vault crypto permissions needed for state access.
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "ci_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.ci.principal_id
}

resource "azurerm_role_assignment" "ci_rbac_admin" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azurerm_user_assigned_identity.ci.principal_id
}

resource "azurerm_role_assignment" "ci_state_blob" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.ci.principal_id
}

resource "azurerm_role_assignment" "ci_kv_crypto" {
  scope                = azurerm_key_vault.state.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_user_assigned_identity.ci.principal_id
}
