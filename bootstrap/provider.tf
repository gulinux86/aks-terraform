terraform {
  required_version = "~> 1.10"

  # Local state on purpose: bootstrap solves the chicken-and-egg problem
  # (it creates the state backend + CI identity the other layers rely on), so it
  # cannot itself depend on a remote backend. Apply it once, per subscription,
  # with privileged credentials.

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # Shared keys are disabled on the state Storage Account, so all data-plane
  # operations (container create) go through Entra ID. The operator running
  # bootstrap therefore needs Storage Blob Data Owner (granted in main.tf).
  storage_use_azuread = true

  features {}
}
