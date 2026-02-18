# Terraform Module Management for Acestus Infrastructure

This directory contains reusable Terraform modules following Acestus security and operational standards, using [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) where available.

## What is Azure Verified Modules?

Azure Verified Modules (AVM) provides the single definition of what a good IaC module is from Microsoft:
- Modules are **supported by Microsoft** across its internal organizations
- Aligned to clear specifications enforcing consistency
- Stay up-to-date with product/service roadmaps
- Align to Well-Architected Framework recommendations
- Tested to comply with AVM specifications

## Available Modules

| Module | AVM Source | Azure Resource |
|--------|------------|----------------|
| [action-group](./action-group) | Native TF | Microsoft.Insights/actionGroups |
| [aks-cluster](./aks-cluster) | avm-res-containerservice-managedcluster | Microsoft.ContainerService/managedClusters |
| [app-gateway-waf-policy](./app-gateway-waf-policy) | avm-res-network-applicationgatewaywebapplicationfirewallpolicy | Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies |
| [app-insights](./app-insights) | avm-res-insights-component | Microsoft.Insights/components |
| [app-service-plan](./app-service-plan) | avm-res-web-serverfarm | Microsoft.Web/serverfarms |
| [application-gateway](./application-gateway) | avm-res-network-applicationgateway | Microsoft.Network/applicationGateways |
| [container-registry](./container-registry) | avm-res-containerregistry-registry | Microsoft.ContainerRegistry/registries |
| [data-collection-rule](./data-collection-rule) | Native TF | Microsoft.Insights/dataCollectionRules |
| [event-grid-topic](./event-grid-topic) | avm-res-eventgrid-topic | Microsoft.EventGrid/topics |
| [function-app](./function-app) | avm-res-web-site | Microsoft.Web/sites |
| [key-vault](./key-vault) | avm-res-keyvault-vault | Microsoft.KeyVault/vaults |
| [load-balancer](./load-balancer) | avm-res-network-loadbalancer | Microsoft.Network/loadBalancers |
| [log-analytics-workspace](./log-analytics-workspace) | avm-res-operationalinsights-workspace | Microsoft.OperationalInsights/workspaces |
| [metric-alert](./metric-alert) | Native TF | Microsoft.Insights/metricAlerts |
| [network-security-group](./network-security-group) | avm-res-network-networksecuritygroup | Microsoft.Network/networkSecurityGroups |
| [postgresql-flexible-server](./postgresql-flexible-server) | avm-res-dbforpostgresql-flexibleserver | Microsoft.DBforPostgreSQL/flexibleServers |
| [private-dns-zone](./private-dns-zone) | avm-res-network-privatednszone | Microsoft.Network/privateDnsZones |
| [private-endpoint](./private-endpoint) | avm-res-network-privateendpoint | Microsoft.Network/privateEndpoints |
| [public-ip-address](./public-ip-address) | avm-res-network-publicipaddress | Microsoft.Network/publicIPAddresses |
| [route-table](./route-table) | avm-res-network-routetable | Microsoft.Network/routeTables |
| [service-bus-namespace](./service-bus-namespace) | avm-res-servicebus-namespace | Microsoft.ServiceBus/namespaces |
| [storage-account](./storage-account) | avm-res-storage-storageaccount | Microsoft.Storage/storageAccounts |
| [user-managed-identity](./user-managed-identity) | avm-res-managedidentity-userassignedidentity | Microsoft.ManagedIdentity/userAssignedIdentities |
| [virtual-machine](./virtual-machine) | avm-res-compute-virtualmachine | Microsoft.Compute/virtualMachines |
| [virtual-machine-scale-set](./virtual-machine-scale-set) | avm-res-compute-virtualmachinescaleset | Microsoft.Compute/virtualMachineScaleSets |
| [virtual-network](./virtual-network) | avm-res-network-virtualnetwork | Microsoft.Network/virtualNetworks |

## Usage

### Using a Module from ACR

```hcl
module "storage_account" {
  source  = "oci://acracemgtcrprdsea001.azurecr.io/terraform/modules/storage-account"
  version = "1.0.0"

  name                = "stexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  tags = {
    Environment = "Production"
    CostCenter  = "IT"
  }
}
```

### Using a Module from HashiCorp Registry (AVM directly)

```hcl
module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  name                = "kv-example-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Acestus security defaults
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  public_network_access_enabled = false
}
```

## Publishing Modules to ACR

### Publish a Single Module

```powershell
.\Publish-TerraformModule.ps1 -ModuleName "storage-account" -Version "v1.0.0"
```

### Publish All Modules

```powershell
.\Publish-AllModules.ps1 -Version "v1.0.0"
```

## Module Versioning

- Use semantic versioning (e.g., v1.0.0, v1.1.0, v2.0.0)
- Major version changes for breaking changes
- Minor version changes for new features
- Patch version changes for bug fixes

## Acestus Security Standards

All modules follow Acestus security defaults:

| Standard | Default Setting |
|----------|-----------------|
| TLS Version | 1.2 minimum |
| Network Access | Private endpoints enabled, public access disabled |
| Authentication | Managed identities preferred over keys/secrets |
| Authorization | RBAC preferred over access policies |
| Diagnostics | Diagnostic settings supported for all resources |
| Encryption | Infrastructure encryption enabled where applicable |
| Data Protection | Soft delete and purge protection enabled |

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI installed and authenticated
- Access to the Acestus ACR (acracemgtcrprdsea001 or acracemgtcrdevneu001)
- AcrPush permissions on the container registry

## Contributing

1. Create or update module in the appropriate directory
2. Follow the existing module structure (main.tf, variables.tf, outputs.tf, versions.tf)
3. Use AVM modules as source where available
4. Apply Acestus security defaults
5. Test with `terraform validate`
6. Publish using the provided scripts

## Resources

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Terraform Registry](https://registry.terraform.io/namespaces/Azure)
- [Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
