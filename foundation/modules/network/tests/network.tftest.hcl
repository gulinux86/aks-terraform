# Mocked-provider unit tests for the network module. No Azure creds, no infra:
# `command = plan` against a mock azurerm provider.

mock_provider "azurerm" {}

variables {
  project_name        = "test"
  location            = "eastus"
  resource_group_name = "test-rg"
  vnet_address_space  = ["10.0.0.0/16"]
  tags                = { env = "test" }
}

run "nat_egress_wired" {
  command = plan

  assert {
    condition     = azurerm_nat_gateway.this.sku_name == "Standard"
    error_message = "NAT Gateway must be Standard SKU for zonal egress"
  }

  assert {
    condition     = azurerm_public_ip.nat.allocation_method == "Static" && azurerm_public_ip.nat.sku == "Standard"
    error_message = "NAT public IP must be a Standard static IP"
  }

  assert {
    condition     = azurerm_nat_gateway.this.idle_timeout_in_minutes > 0
    error_message = "NAT Gateway must define an idle timeout"
  }
}

run "alb_subnet_is_delegated" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.alb.delegation) == 1
    error_message = "The ALB subnet must be delegated to Application Gateway for Containers"
  }

  assert {
    condition     = azurerm_subnet.alb.delegation[0].service_delegation[0].name == "Microsoft.ServiceNetworking/trafficControllers"
    error_message = "ALB subnet delegation must target Microsoft.ServiceNetworking/trafficControllers"
  }
}
