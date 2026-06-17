terraform {
  # Partial configuration: resource_group_name / storage_account_name /
  # container_name / key come from environments/<env>/backend.hcl.
  backend "azurerm" {
    use_azuread_auth = true
  }
}
