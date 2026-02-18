targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('Project name')
param projectName string

@description('The environment suffix.')
param environmentSuffix string

@description('The location suffix.')
param locationSuffix string

@description('The instance number suffix.')
param instanceSuffix string

@description('Teams webhook URL for sending alerts.')
@secure()
param teamsWebhookUrl string

@description('Email address for alerts.')
param alertEmailAddress string

@description('Resource ID of the Log Analytics workspace.')
param workspaceResourceId string

@description('Tags to be applied to all resources.')
param tags object = {}

var appServicePlanName = 'asp-${projectName}-${environmentSuffix}-${locationSuffix}-${instanceSuffix}'
var storageAccountName = 'st${projectName}${environmentSuffix}${locationSuffix}${instanceSuffix}'
var applicationInsightsName = 'ai-${projectName}-${environmentSuffix}-${locationSuffix}-${instanceSuffix}'
var functionAppName = 'func-alert-${environmentSuffix}-${locationSuffix}-${instanceSuffix}'
var emailActionGroupName = 'ag-email-${environmentSuffix}-${locationSuffix}-${instanceSuffix}'
var teamsActionGroupName = 'ag-teams-${environmentSuffix}-${locationSuffix}-${instanceSuffix}'

module appServicePlan 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/app-service-plan:v1.1.0' = {
  name: '${deployment().name}-asp'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    skuName: 'Y1'
    kind: 'functionApp'
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
    serverFarmResourceId: appServicePlan.outputs.resourceId
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

module emailActionGroup 'actionGroup.bicep' = {
  name: '${deployment().name}-ag-email'
  params: {
    name: emailActionGroupName
    tags: tags
    emailReceivers: [
      {
        name: 'AlertEmail'
        emailAddress: alertEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

module teamsActionGroup 'actionGroup.bicep' = {
  name: '${deployment().name}-ag-teams'
  params: {
    name: teamsActionGroupName
    tags: tags
    azureFunctionReceivers: [
      {
        name: 'AlertTransformer'
        functionAppResourceId: functionApp.outputs.resourceId
        functionName: 'Alert_Transformer'
        httpTriggerUrl: 'https:
        useCommonAlertSchema: true
      }
    ]
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.outputs.resourceId

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

@description('The resource ID of the email action group.')
output emailActionGroupResourceId string = emailActionGroup.outputs.resourceId

@description('The resource ID of the teams action group.')
output teamsActionGroupResourceId string = teamsActionGroup.outputs.resourceId
