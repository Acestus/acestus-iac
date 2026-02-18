targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the project, used for naming resources.')
param projectName string

@description('The environment name, used for naming resources.')
param environment string

@description('The Cloud Adoption Framework location, used for naming resources.')
param CAFLocation string

@description('The instance number, used for naming resources.')
param instanceNumber string

@description('Tags to be applied to all resources.')
param tags object = {}

var appServicePlanName = 'asp-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var applicationInsightsName = 'ai-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var userManagedIdentityName = 'umi-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'

module userManagedIdentity 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/user-managed-identity:v1.1.0' = {
  name: '${deployment().name}-umi'
  params: {
    name: userManagedIdentityName
    location: location
    tags: tags
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'B1'
    capacity: 1
  }
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    zoneRedundant: false
  }
}

module applicationInsights 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/app-insights:v1.1.0' = {
  name: '${deployment().name}-ai'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceResourceId: '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'
    applicationType: 'web'
    kind: 'web'
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.id

@description('The resource ID of the Application Insights component.')
output applicationInsightsResourceId string = applicationInsights.outputs.resourceId

@description('The instrumentation key of the Application Insights component.')
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey

@description('The connection string of the Application Insights component.')
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString

@description('The resource ID of the user managed identity.')
output userManagedIdentityResourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity.')
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity.')
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId
