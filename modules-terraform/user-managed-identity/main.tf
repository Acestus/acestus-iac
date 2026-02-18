# Acestus User Managed Identity Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-managedidentity-userassignedidentity/azurerm

module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.3"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Federated identity credentials (for workload identity)
  federated_identity_credentials = var.federated_identity_credentials

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
