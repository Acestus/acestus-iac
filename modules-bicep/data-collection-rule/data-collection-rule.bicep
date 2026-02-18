// Opinionated Data Collection Rule module following Acestus standards

metadata name = 'Acestus Data Collection Rule'
metadata description = 'Data Collection Rule module with Acestus monitoring standards'
metadata version = '1.0.0'

@description('Name of the data collection rule')
param name string

@description('Location for the data collection rule')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Description of the data collection rule')
param ruleDescription string = ''

@description('Kind of data collection rule')
@allowed([
  'Linux'
  'Windows'
  'AgentDirectToStore'
  'WorkspaceTransforms'
])
param kind string = 'Linux'

@description('Data collection endpoint resource ID')
param dataCollectionEndpointId string = ''

@description('Stream declarations for custom logs')
param streamDeclarations object = {}

@description('Data sources configuration')
param dataSources object = {}

@description('Destinations configuration')
param destinations object = {}

@description('Data flows configuration')
param dataFlows array = []

@description('Identity configuration')
param identity object = {}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-11-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  identity: !empty(identity) ? identity : null
  properties: {
    description: ruleDescription
    dataCollectionEndpointId: !empty(dataCollectionEndpointId) ? dataCollectionEndpointId : null
    streamDeclarations: !empty(streamDeclarations) ? streamDeclarations : null
    dataSources: dataSources
    destinations: destinations
    dataFlows: dataFlows
  }
}

@description('The resource ID of the data collection rule')
output resourceId string = dataCollectionRule.id

@description('The name of the data collection rule')
output name string = dataCollectionRule.name

@description('The immutable ID of the data collection rule')
output immutableId string = dataCollectionRule.properties.immutableId
