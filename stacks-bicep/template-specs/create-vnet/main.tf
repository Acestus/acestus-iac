terraform {
  required_version = ">= 1.5.7"
  backend "azurerm" {
    resource_group_name  = "iac"
    storage_account_name = "stprdiacusw2001"
    container_name       = "dev"
    key                  = "tfs-dev-test-usw2-008"
  }
}

data "azurerm_client_config" "current" {
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix  = ["${var.ResourceEnvironment}", "${var.ResourceProjAppSvc}", "${var.ResourceLocation}", "${var.ResourceInstance}"]

}

resource "azurerm_virtual_network" "example" {
  name                = module.naming.virtual_network.name
  resource_group_name = module.naming.resource_group.name
  location            = var.location
  address_space       = ["10.200.200.0/26"]
  
  depends_on = [ resource.azurerm_resource_group.main ]
}
