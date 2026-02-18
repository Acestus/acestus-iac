terraform {
  required_version = "1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-labmgmt-sbox-sea"
    storage_account_name = "stdeviacsea003"
    container_name       = "dev"
    key                  = "rg-dns-dev-sea.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id            = local.SubscriptionId
}
