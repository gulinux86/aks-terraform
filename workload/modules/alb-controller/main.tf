# Application Gateway for Containers — ALB Controller.
#
# Installed as a control-plane-managed CLUSTER EXTENSION (not a helm_release /
# kubernetes_* resource), so the install path does not need network reach to the
# private API server. Authorized via Workload Identity: a dedicated user-assigned
# identity bound by a federated credential to the controller's service account,
# with narrowly scoped role assignments (no node-identity sharing).

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

# --- 4. The controller itself, as a managed cluster extension ---
# The extension is installed by the Azure control plane; configuration_settings
# pass the identity client ID through so the controller's service account is
# annotated for Workload Identity (task 5.4) without a kubernetes provider.
#
# NOTE (open question 5.1): confirm Application Gateway for Containers + the ALB
# Controller extension is GA in the target region and that this extension_type /
# configuration surface is correct; otherwise pin via `azapi` or fall back to
# AGIC (managed add-on) / NGINX. The federated credential + identity + role
# assignments above are stable regardless of that choice.
resource "azurerm_kubernetes_cluster_extension" "alb" {
  name           = "alb-controller"
  cluster_id     = var.cluster_id
  extension_type = "microsoft.azure-alb-controller"

  configuration_settings = {
    "albController.namespace"            = var.controller_namespace
    "albController.podIdentity.clientId" = azurerm_user_assigned_identity.alb.client_id
  }

  depends_on = [
    azurerm_federated_identity_credential.alb,
    azurerm_role_assignment.alb_config_manager,
  ]
}
