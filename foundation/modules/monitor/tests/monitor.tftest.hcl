# Mocked-provider unit test for the monitor module.

mock_provider "azurerm" {}

variables {
  project_name        = "test"
  location            = "eastus"
  resource_group_name = "test-rg"
  log_retention_days  = 30
  tags                = { env = "test" }
}

run "workspace_shape" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.this.sku == "PerGB2018"
    error_message = "Workspace must use the PerGB2018 SKU"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.retention_in_days == 30
    error_message = "Workspace retention must honour the input"
  }
}
