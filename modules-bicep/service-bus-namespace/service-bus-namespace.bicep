// Opinionated Service Bus Namespace module following Acestus standards

metadata name = 'Acestus Service Bus Namespace'
metadata description = 'Custom Service Bus Namespace module with Acestus defaults'
metadata version = '1.1.0'

@description('Service Bus namespace name')
param name string

@description('Location for the namespace')
param location string = resourceGroup().location

@description('Tags to apply to the namespace')
param tags object = {}

@description('SKU object for the namespace')
param skuObject object = {
  name: 'Standard'
  capacity: 1
}

@description('Minimum TLS version')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param minimumTlsVersion string = '1.2'

@description('Disable local auth (SAS)')
param disableLocalAuth bool = true

@description('Zone redundancy')
param zoneRedundant bool = false

@description('Public network access')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Enabled'

@description('Network rule sets (optional)')
param networkRuleSets object = {}

@description('Managed identities configuration (optional)')
param managedIdentities object = {}

@description('Customer managed key configuration (optional)')
param customerManagedKey object = {}

@description('Topics to create in the namespace')
param topics array = []

@description('Queues to create in the namespace')
param queues array = []

@description('Authorization rules for the namespace')
param authorizationRules array = []

@description('Diagnostic settings for the namespace')
param diagnosticSettings array = []

module serviceBus 'br/public:avm/res/service-bus/namespace:0.16.1' = {
  params: {
    name: name
    location: location
    tags: tags
    skuObject: skuObject
    minimumTlsVersion: minimumTlsVersion
    disableLocalAuth: disableLocalAuth
    zoneRedundant: zoneRedundant
    publicNetworkAccess: publicNetworkAccess
    networkRuleSets: !empty(networkRuleSets) ? networkRuleSets : null
    managedIdentities: !empty(managedIdentities) ? managedIdentities : null
    customerManagedKey: !empty(customerManagedKey) ? customerManagedKey : null
    topics: !empty(topics) ? topics : null
    queues: !empty(queues) ? queues : null
    authorizationRules: !empty(authorizationRules) ? authorizationRules : null
    diagnosticSettings: !empty(diagnosticSettings) ? diagnosticSettings : null
  }
}

@description('The resource ID of the Service Bus namespace')
output resourceId string = serviceBus.outputs.resourceId

@description('The name of the Service Bus namespace')
output name string = serviceBus.outputs.name

@description('The name of the Service Bus namespace (legacy output)')
output namespaceName string = serviceBus.outputs.name

@description('The endpoint of the Service Bus namespace')
output serviceBusEndpoint string = serviceBus.outputs.serviceBusEndpoint

@description('The resource group of the Service Bus namespace')
output resourceGroupName string = serviceBus.outputs.resourceGroupName
