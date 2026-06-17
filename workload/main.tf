# workload — in-cluster add-ons (reads foundation outputs).
#
# The ingress controller is installed as a control-plane-managed cluster
# extension, so this layer needs NO kubernetes/helm provider and NO network
# reach to the private API server (see provider.tf).

data "terraform_remote_state" "foundation" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.foundation_state_resource_group
    storage_account_name = var.foundation_state_storage_account
    container_name       = var.foundation_state_container
    key                  = var.foundation_state_key
    use_azuread_auth     = true
  }
}

module "alb_controller" {
  source = "./modules/alb-controller"

  project_name        = data.terraform_remote_state.foundation.outputs.cluster_name
  location            = data.terraform_remote_state.foundation.outputs.location
  resource_group_name = data.terraform_remote_state.foundation.outputs.resource_group_name
  cluster_id          = data.terraform_remote_state.foundation.outputs.cluster_id
  oidc_issuer_url     = data.terraform_remote_state.foundation.outputs.oidc_issuer_url
  alb_subnet_id       = data.terraform_remote_state.foundation.outputs.alb_subnet_id
  tags                = data.terraform_remote_state.foundation.outputs.tags
}
