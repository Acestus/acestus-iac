targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('CAF Name prefix for all resources.')
@secure()
param projectName string
 
@description('Environment for all resources.')
param environment string

@description('Region for all resources.')
param region string

@description('Instance number for all resources.')
param instanceNumber string

@description('SKU for the App Service Plan.')
param aspSKU string

@description('Linux App Service Plan instance name prefix.')
param linuxASPinstanceNumber string

@description('Tags to be applied to all resources.')
param tags object = {}

@description('Resource ID of the Log Analytics workspace for Application Insights')
param workspaceResourceId string

var linuxAppServicePlanName = 'asp-${projectName}-${environment}-${region}-${linuxASPinstanceNumber}'
var applicationInsightsName = 'ai-${projectName}-${environment}-${region}-${instanceNumber}'
var userManagedIdentityName = 'umi-${projectName}-${environment}-${region}-${instanceNumber}'
var serviceBusNamespaceName = 'sb-${projectName}-${environment}-${region}-${instanceNumber}'


module userManagedIdentity 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/user-managed-identity:v1.1.0' = {
  name: '${deployment().name}-umi'
  params: {
    name: userManagedIdentityName
    location: location
    tags: tags
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: linuxAppServicePlanName
  location: location
  tags: tags
  sku: {
    name: aspSKU
    capacity: 1
  }
  kind: 'linux'
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
    workspaceResourceId: workspaceResourceId
    applicationType: 'web'
    kind: 'web'
  }
}

module serviceBusNamespace 'br/public:avm/res/service-bus/namespace:0.16.1' = {
  name: '${deployment().name}-sb'
  params: {
    name: serviceBusNamespaceName
    location: location
    tags: tags
    skuObject: {
      name: 'Standard'
    }
    minimumTlsVersion: '1.2'
    disableLocalAuth: true
    zoneRedundant: true
    publicNetworkAccess: 'Enabled'
    topics: [
      {
        name: 'jml-events'
        maxMessageSizeInKilobytes: 256
        defaultMessageTimeToLive: 'P14D'
        maxSizeInMegabytes: 1024
        requiresDuplicateDetection: true
        duplicateDetectionHistoryTimeWindow: 'PT10M'
        enableBatchedOperations: true
        supportOrdering: false
        enablePartitioning: false
        enableExpress: false
        subscriptions: [
          {
            name: 'itsm-tickets'
            lockDuration: 'PT1M'
            requiresSession: false
            defaultMessageTimeToLive: 'P14D'
            deadLetteringOnMessageExpiration: false
            deadLetteringOnFilterEvaluationExceptions: false
            maxDeliveryCount: 10
            enableBatchedOperations: true
          }
          {
            name: 'provisioning'
            lockDuration: 'PT1M'
            requiresSession: false
            defaultMessageTimeToLive: 'P14D'
            deadLetteringOnMessageExpiration: false
            deadLetteringOnFilterEvaluationExceptions: false
            maxDeliveryCount: 10
            enableBatchedOperations: true
          }
        ]
      }
    ]
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

@description('The resource ID of the Service Bus namespace.')
output serviceBusNamespaceResourceId string = serviceBusNamespace.outputs.resourceId

@description('The name of the Service Bus namespace.')
output serviceBusNamespaceName string = serviceBusNamespace.outputs.name

@description('The endpoint of the Service Bus namespace.')
output serviceBusEndpoint string = serviceBusNamespace.outputs.serviceBusEndpoint
