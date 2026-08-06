targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('Tags to apply to all resources.')
param tags object = {}

@description('The Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@description('The Application Insights component name.')
param applicationInsightsName string

@description('Application type for Application Insights.')
@allowed([
  'web'
  'other'
])
param applicationInsightsType string = 'web'

@description('Kind of Application Insights resource.')
param applicationInsightsKind string = 'web'

@description('Disable IP masking for Application Insights.')
param disableIpMasking bool = true

@description('Disable local (non-AAD) auth for Application Insights.')
param disableLocalAuth bool = false

@description('Retention in days for Application Insights.')
@allowed([
  30
  60
  90
  120
  180
  270
  365
  550
  730
])
param appInsightsRetentionInDays int = 90

@description('Log Analytics workspace data retention in days.')
@minValue(30)
@maxValue(730)
param logAnalyticsRetentionInDays int = 90

module logAnalyticsWorkspace '../../modules-bicep/log-analytics-workspace/log-analytics-workspace.bicep' = {
  name: '${deployment().name}-law'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    dataRetention: logAnalyticsRetentionInDays
  }
}

module applicationInsights '../../modules-bicep/app-insights/app-insights.bicep' = {
  name: '${deployment().name}-ai'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: applicationInsightsType
    kind: applicationInsightsKind
    disableIpMasking: disableIpMasking
    disableLocalAuth: disableLocalAuth
    retentionInDays: appInsightsRetentionInDays
  }
}

@description('The resource ID of the Log Analytics workspace.')
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.outputs.resourceId

@description('The name of the Log Analytics workspace.')
output logAnalyticsWorkspaceResourceName string = logAnalyticsWorkspace.outputs.name

@description('The resource ID of the Application Insights component.')
output applicationInsightsResourceId string = applicationInsights.outputs.resourceId

@description('The name of the Application Insights component.')
output applicationInsightsComponentName string = applicationInsights.outputs.applicationInsightsName

@description('The instrumentation key of the Application Insights component.')
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey

@description('The connection string of the Application Insights component.')
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
