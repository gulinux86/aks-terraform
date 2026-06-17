terraform {
  required_version = "~> 1.10"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    # The ingress controller is installed as a control-plane-managed cluster
    # extension, so the kubernetes/helm providers are intentionally ABSENT here:
    # a private API server is unreachable from GitHub-hosted runners, and the
    # extension is deployed by Azure, not over the runner's network path.
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
