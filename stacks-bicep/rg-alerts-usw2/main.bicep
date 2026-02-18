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

@description('Teams webhook URL for sending alerts.')
@secure()
param teamsWebhookUrl string

@description('Resource ID of the Log Analytics workspace.')
param workspaceResourceId string

@description('Tags to be applied to all resources.')
param tags object = {}

var appServicePlanName = 'asp-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var storageAccountName = 'st${projectName}${environment}${CAFLocation}${instanceNumber}'
var applicationInsightsName = 'ai-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var functionAppName = 'func-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
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
    name: 'P1V4'
    capacity: 1
  }
  kind: 'functionapp'
  properties: {
    reserved: false
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: '${deployment().name}-st'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

module applicationInsights 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/app-insights:v1.1.0' = {
  name: '${deployment().name}-ai'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceResourceId: workspaceResourceId
    applicationType: 'web'
    kind: 'web'
  }
}

module functionApp 'br/public:avm/res/web/site:0.21.0' = {
  name: '${deployment().name}-func'
  params: {
    name: functionAppName
    location: location
    tags: tags
    kind: 'functionapp'
    serverFarmResourceId: appServicePlan.id
    storageAccountResourceId: storageAccount.outputs.resourceId
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.outputs.instrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.outputs.connectionString
        }
        {
          name: 'TEAMS_WEBHOOK_URL'
          value: teamsWebhookUrl
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
      powerShellVersion: '7.4'
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      alwaysOn: false
      cors: {
        allowedOrigins: ['*']
      }
    }
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.id

@description('The resource ID of the Function App.')
output functionAppResourceId string = functionApp.outputs.resourceId

@description('The default hostname of the Function App.')
output functionAppDefaultHostname string = functionApp.outputs.defaultHostname

@description('The resource ID of the Application Insights component.')
output applicationInsightsResourceId string = applicationInsights.outputs.resourceId

@description('The instrumentation key of the Application Insights component.')
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey

@description('The connection string of the Application Insights component.')
output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString

@description('The resource ID of the Storage Account.')
output storageAccountResourceId string = storageAccount.outputs.resourceId

@description('The resource ID of the user managed identity.')
output userManagedIdentityResourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity.')
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity.')
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId
