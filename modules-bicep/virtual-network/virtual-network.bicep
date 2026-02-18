// Opinionated Virtual Network module following Acestus standards and security best practices

metadata name = 'Acestus Virtual Network'
metadata description = 'Custom Virtual Network module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Virtual Network name')
param name string

@description('Location for the Virtual Network')
param location string = resourceGroup().location

@description('Tags to apply to the Virtual Network')
param tags object = {}

@description('Virtual Network address prefixes')
param addressPrefixes array

@description('Subnets to create within the Virtual Network')
param subnets array = []

@description('DNS servers for the Virtual Network (empty uses Azure DNS)')
param dnsServers array = []

@description('Enable DDoS protection')
param enableDdosProtection bool = false

@description('DDoS protection plan resource ID (required if DDoS protection is enabled)')
param ddosProtectionPlanResourceId string = ''

@description('Enable VM protection')
param enableVmProtection bool = false

@description('Enable encryption on the virtual network')
param encryptionEnabled bool = false

@description('Encryption enforcement policy')
@allowed([
  'AllowUnencrypted'
  'DropUnencrypted'
])
param encryptionEnforcement string = 'AllowUnencrypted'

@description('Virtual Network flow timeout in minutes')
@minValue(4)
@maxValue(30)
param flowTimeoutInMinutes int = 4

@description('Peerings to create for this Virtual Network')
param peerings array = []

@description('Diagnostic settings for the Virtual Network')
param diagnosticSettings array = []

@description('Lock settings for the Virtual Network')
param lock object = {}

@description('Role assignments for the Virtual Network')
param roleAssignments array = []

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: '${deployment().name}-vnet'
  params: {
    name: name
    location: location
    tags: tags
    addressPrefixes: addressPrefixes
    subnets: subnets
    dnsServers: dnsServers
    ddosProtectionPlanResourceId: enableDdosProtection ? ddosProtectionPlanResourceId : ''
    enableVmProtection: enableVmProtection
    vnetEncryption: encryptionEnabled
    vnetEncryptionEnforcement: encryptionEnabled ? encryptionEnforcement : null
    flowTimeoutInMinutes: flowTimeoutInMinutes
    peerings: peerings
    diagnosticSettings: diagnosticSettings
    lock: !empty(lock) ? lock : null
    roleAssignments: roleAssignments
  }
}

// Outputs
@description('The resource ID of the Virtual Network')
output resourceId string = virtualNetwork.outputs.resourceId

@description('The name of the Virtual Network')
output name string = virtualNetwork.outputs.name

@description('The resource group the Virtual Network was deployed into')
output resourceGroupName string = virtualNetwork.outputs.resourceGroupName

@description('The location the Virtual Network was deployed into')
output location string = virtualNetwork.outputs.location

@description('The subnets of the Virtual Network')
output subnetResourceIds array = virtualNetwork.outputs.subnetResourceIds

@description('The names of the subnets')
output subnetNames array = virtualNetwork.outputs.subnetNames

@description('All outputs from the AVM Virtual Network module')
output virtualNetwork object = virtualNetwork.outputs
