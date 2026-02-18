# Azure Storage Account using Azure Verified Module (AVM)
# Documentation: https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8a0d1fba-54d6-4f26-86a9-04aa58ba7fb0"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-tofu-dev-jpe"
  location = "Japan East"

  tags = {
    Environment = "dev"
    Project     = "tofu"
    ManagedBy   = "tofu"
  }
}

module "storage-account-01" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6"

  name                = "sttofudevjpe001"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"
  
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
  min_tls_version = "~> 0.6"
  shared_access_key_enabled    = true
  
}

 