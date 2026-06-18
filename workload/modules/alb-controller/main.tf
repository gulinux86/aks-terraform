# Application Gateway for Containers — ALB Controller (Workload Identity side).
#
# This module provisions only the AZURE-SIDE identity for the controller:
#   - a dedicated user-assigned managed identity,
#   - a federated credential binding it to exactly one service account,
#   - narrowly scoped role assignments.
#
# The controller itself is installed by Helm THROUGH `az aks command invoke`
# (see .github/workflows/terraform-deploy.yml), NOT here. Rationale: the AGC ALB
# Controller has no supported AKS cluster-extension type (confirmed: 400
# ExtensionTypeRegistrationGetFailed in the target region), and the Terraform
# helm/kubernetes providers cannot reach a private API server from a
# GitHub-hosted runner. `command invoke` tunnels Helm through the AKS managed
# control plane — the same managed path used for kubectl — so no runner network
# reach and no in-cluster Terraform provider are required. The identity client
# ID below is passed to the Helm release so the controller's service account is
# annotated for Workload Identity.

# --- 1. Dedicated identity (the IAM-role equivalent) ---
resource "azurerm_user_assigned_identity" "alb" {
  name                = "${var.project_name}-alb-controller"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# --- 2. Federated credential: bind the identity to exactly one service account ---
resource "azurerm_federated_identity_credential" "alb" {
  name                      = "alb-controller-fed"
  user_assigned_identity_id = azurerm_user_assigned_identity.alb.id
  issuer                    = var.oidc_issuer_url
  subject                   = "system:serviceaccount:${var.controller_namespace}:${var.service_account_name}"
  audience                  = ["api://AzureADTokenExchange"]
}

# --- 3. Narrowly scoped role assignments (least privilege) ---
# Reader on the cluster RG, plus the AGC configuration role and Network
# Contributor on the delegated ALB subnet — the resources the controller manages.
resource "azurerm_role_assignment" "alb_reader" {
  scope                = "/subscriptions/${split("/", var.cluster_id)[2]}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.alb.principal_id
}

resource "azurerm_role_assignment" "alb_config_manager" {
  scope                = "/subscriptions/${split("/", var.cluster_id)[2]}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "AppGw for Containers Configuration Manager"
  principal_id         = azurerm_user_assigned_identity.alb.principal_id
}

resource "azurerm_role_assignment" "alb_subnet_network" {
  scope                = var.alb_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.alb.principal_id
}
