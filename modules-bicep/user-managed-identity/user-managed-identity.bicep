// Opinionated User Managed Identity module following Acestus standards

metadata name = 'Acestus User Managed Identity'
metadata description = 'Custom User Managed Identity module with Acestus defaults'
metadata version = '1.0.0'

@description('User Managed Identity name')
param name string

@description('Location for the identity')
param location string = resourceGroup().location

@description('Tags to apply to the identity')
param tags object = {}

@description('Federated identity credentials')
param federatedIdentityCredentials array = []

module userManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.0' = {
  name: '${deployment().name}-umi'
  params: {
    name: name
    location: location
    tags: tags
    federatedIdentityCredentials: !empty(federatedIdentityCredentials) ? federatedIdentityCredentials : null
  }
}

@description('The resource ID of the user managed identity')
output resourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity')
output principalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity')
output clientId string = userManagedIdentity.outputs.clientId

@description('The name of the user managed identity')
output identityName string = userManagedIdentity.outputs.name

@description('All outputs from the AVM user assigned identity module')
output userManagedIdentity object = userManagedIdentity.outputs
