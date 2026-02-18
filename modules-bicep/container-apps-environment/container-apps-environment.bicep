// Opinionated Container Apps Environment module following Acestus standards
// This wrapper provides a simplified interface to the AVM managed-environment module

metadata name = 'Acestus Container Apps Environment'
metadata description = 'Container Apps Managed Environment module with Acestus defaults'
metadata version = '1.0.0'

@description('Name of the Container Apps Environment')
param name string

@description('Location for the environment')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Log Analytics workspace resource ID for logs destination')
param logAnalyticsWorkspaceResourceId string = ''

@description('Logs destination (log-analytics, azure-monitor, or none)')
@allowed([
  'log-analytics'
  'azure-monitor'
  ''
])
param logsDestination string = 'log-analytics'

@description('Managed identities configuration. Example: { userAssignedResourceIds: ["..."] }')
param managedIdentities object = {}

@description('Enable zone redundancy')
param zoneRedundant bool = false

@description('Workload profiles for the environment')
param workloadProfiles array = []

@description('Virtual network configuration for internal environments')
param infrastructureSubnetId string = ''

@description('Whether the environment is internal (no public endpoint)')
param internal bool = false

@description('DAPR AI connection string')
param daprAIConnectionString string = ''

@description('DAPR AI instrumentation key')
param daprAIInstrumentationKey string = ''

@description('App Insights connection string')
param appInsightsConnectionString string = ''

// Use the same AVM version as rg-aspire-usw2 stack for compatibility
module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
  name: '${deployment().name}-cae'
  params: {
    name: name
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    logsDestination: !empty(logsDestination) ? logsDestination : null
    managedIdentities: managedIdentities
    zoneRedundant: zoneRedundant
    workloadProfiles: workloadProfiles
    infrastructureSubnetId: infrastructureSubnetId
    internal: internal
    daprAIConnectionString: daprAIConnectionString
    daprAIInstrumentationKey: daprAIInstrumentationKey
    appInsightsConnectionString: appInsightsConnectionString
  }
}

@description('The resource ID of the Container Apps Environment')
output resourceId string = containerAppsEnvironment.outputs.resourceId

@description('The name of the Container Apps Environment')
output name string = containerAppsEnvironment.outputs.name

@description('The default domain of the Container Apps Environment')
output defaultDomain string = containerAppsEnvironment.outputs.defaultDomain

@description('The static IP of the Container Apps Environment')
output staticIp string = containerAppsEnvironment.outputs.staticIp
