// Action Group module for resource group-scoped deployment
targetScope = 'resourceGroup'

// Parameters
@description('The name of the action group.')
param name string

@description('Tags to be applied to the action group.')
param tags object = {}

@description('Email receivers for the action group.')
param emailReceivers array = []

@description('Azure Function receivers for the action group.')
param azureFunctionReceivers array = []

// Variables
var groupShortName = length(name) > 12 ? take(name, 12) : name

// Resources
resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: name
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: groupShortName
    enabled: true
    emailReceivers: emailReceivers
    azureFunctionReceivers: azureFunctionReceivers
  }
}

// Outputs
@description('The resource ID of the action group.')
output resourceId string = actionGroup.id

@description('The name of the action group.')
output name string = actionGroup.name
