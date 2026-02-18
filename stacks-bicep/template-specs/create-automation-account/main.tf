terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name  = "iac"
    storage_account_name = "stdeviacusw2001"
    container_name       = "dev"
    key                  = "automation-account.tfstate"
  }
}

data "azurerm_client_config" "current" {
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix  = ["${local.ResourceEnvironment}", "${local.ResourceProjAppSvc}", "${local.ResourceLocation}", "${local.ResourceInstance}"]
}

resource "azurerm_resource_group" "rg" {
  location = local.location
  name     = module.naming.resource_group.name
}

resource "azurerm_automation_account" "example" {
  name                = module.naming.automation_account.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Basic"
  identity {
    type         = "SystemAssigned"
  }

  public_network_access_enabled = true
}

data "azurerm_subscription" "current" {}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_role_assignment" "example" {
  scope              = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id       = azurerm_automation_account.example.identity[0].principal_id
}