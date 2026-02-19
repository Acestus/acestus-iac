// Opinionated IaaS VM CosmosDB Tier4 module following Acestus standards and security best practices

metadata name = 'Acestus IaaS VM CosmosDB Tier4'
metadata description = 'Custom IaaS VM CosmosDB Tier4 module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('IaaS VM CosmosDB Tier4 name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('IaaS VM CosmosDB Tier4 properties')
param properties object

module iaasVmCosmosdbTier4 'br:avm/ptn/app/iaas-vm-cosmosdb-tier4:0.1.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the IaaS VM CosmosDB Tier4')
output resourceId string = iaasVmCosmosdbTier4.outputs.resourceId

@description('All outputs from the AVM IaaS VM CosmosDB Tier4 module')
output iaasVmCosmosdbTier4 object = iaasVmCosmosdbTier4.outputs
