terraform {
  # Partial configuration: resource_group_name / storage_account_name /
  # container_name / key come from environments/<env>/backend.hcl via
  # `terraform init -backend-config=...`. Locking is the native blob lease.
  backend "azurerm" {
    use_azuread_auth = true
  }
}
