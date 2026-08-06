targetScope = 'resourceGroup'

@description('Azure region for Function App')
param location string = 'southcentralus'

@description('Function App name')
param functionAppName string = 'acestus-blog-api-scus'

@description('Storage account for Function App runtime')
param storageAccountName string = 'acestusblogapiscus'

@description('Name of the App Service Plan hosting the Function App')
param appServicePlanName string = 'asp-mail-dev-scus-001'

@description('Name of the Application Insights instance for the Function App')
param appInsightsName string = 'ai-mail-dev-scus-001'

@description('Resend API key for sending newsletter emails')
@secure()
param resendApiKey string = ''

@description('From address for the History newsletter')
param newsletterFromHistory string = 'newsletter@history.acestus.com'

@description('From address for the Cloud newsletter')
param newsletterFromCloud string = 'newsletter@cloud.acestus.com'

@description('From address for the Christian/Dad newsletter')
param newsletterFromChristian string = 'newsletter@dad.acestus.com'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
  }
}

resource functionDeploymentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccountName}/default/function-deployments'
  dependsOn: [
    storageAccount
  ]
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource functionPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp,linux'
  sku: {
    name: 'FC1'
    tier: 'FlexConsumption'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: functionPlan.id
    reserved: true
    functionAppConfig: {
      runtime: {
        name: 'dotnet-isolated'
        version: '10.0'
      }
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}function-deployments'
          authentication: {
            type: 'StorageAccountConnectionString'
            storageAccountConnectionStringName: 'AzureWebJobsStorage'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 10
        instanceMemoryMB: 2048
      }
    }
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://fabric.acestus.com'
          'https://dad.acestus.com'
          'https://blog.acestus.com'
          'https://history.acestus.com'
          'http://localhost:1313'
        ]
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=core.windows.net;AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'RESEND_API_KEY'
          value: resendApiKey
        }
        {
          name: 'NEWSLETTER_FROM_HISTORY'
          value: newsletterFromHistory
        }
        {
          name: 'NEWSLETTER_FROM_CLOUD'
          value: newsletterFromCloud
        }
        {
          name: 'NEWSLETTER_FROM_CHRISTIAN'
          value: newsletterFromChristian
        }
      ]
    }
  }
}

output functionAppHostname string = functionApp.properties.defaultHostName
output storageAccountName string = storageAccount.name
output appInsightsName string = appInsights.name
output appServicePlanName string = functionPlan.name
