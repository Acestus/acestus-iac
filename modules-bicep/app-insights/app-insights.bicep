// Opinionated Application Insights module following Acestus standards

metadata name = 'Acestus Application Insights'
metadata description = 'Custom Application Insights module with Acestus defaults'
metadata version = '1.0.0'

@description('Application Insights name')
param name string

@description('Location for the Application Insights instance')
param location string = resourceGroup().location

@description('Tags to apply to the Application Insights instance')
param tags object = {}

@description('Log Analytics workspace resource ID')
param workspaceResourceId string

@description('Application type')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Kind of Application Insights resource')
param kind string = 'web'

@description('Disable IP masking')
param disableIpMasking bool = true

@description('Disable local (non-AAD) auth')
param disableLocalAuth bool = false

@description('Public network access for ingestion')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Public network access for query')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Retention in days')
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
param retentionInDays int = 365

module appInsights 'br/public:avm/res/insights/component:0.7.1' = {
  name: '${deployment().name}-ai'
  params: {
    name: name
    location: location
    tags: tags
    workspaceResourceId: workspaceResourceId
    applicationType: applicationType
    kind: kind
    disableIpMasking: disableIpMasking
    disableLocalAuth: disableLocalAuth
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    retentionInDays: retentionInDays
  }
}

@description('The resource ID of the Application Insights component')
output resourceId string = appInsights.outputs.resourceId

@description('The name of the Application Insights component')
output applicationInsightsName string = appInsights.outputs.name

@description('The instrumentation key of the Application Insights component')
output instrumentationKey string = appInsights.outputs.instrumentationKey

@description('The connection string of the Application Insights component')
output connectionString string = appInsights.outputs.connectionString

@description('All outputs from the AVM Application Insights module')
output applicationInsights object = appInsights.outputs
