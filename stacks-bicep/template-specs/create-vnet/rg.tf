provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = module.naming.resource_group.name
  location = var.location
}