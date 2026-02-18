terraform {
  required_version = "1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-labmgmt-sbox-usw2"
    storage_account_name = "stdeviacusw2003"
    container_name       = "dev"
    key                  = "rg-dns-dev-usw2.tfstate"
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id            = local.SubscriptionId
}
