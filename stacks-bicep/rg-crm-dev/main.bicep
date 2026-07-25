targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = 'southcentralus'

@description('The project name used in CAF naming.')
param projectName string = 'crm'

@description('The environment name used in CAF naming.')
param environment string = 'dev'

@description('The Azure region code used in CAF naming.')
param CAFLocation string = 'scus'

@description('The instance number used in CAF naming.')
param instanceNumber string = '001'

@description('Tags to be applied to all resources.')
param tags object = {}

var cafName = '${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var appServicePlanName = 'asp-${cafName}'
var staticWebAppName = 'swa-${cafName}'
var functionAppName = 'func-${cafName}'
var functionStorageAccountName = 'st${projectName}${environment}func${CAFLocation}${instanceNumber}'
var dataStorageAccountName = 'st${projectName}${environment}${CAFLocation}${instanceNumber}'
var userManagedIdentityName = 'umi-${cafName}'
var gitHubActionsIssuer = 'https://token.actions.githubusercontent.com'
var gitHubActionsAudience = 'api://AzureADTokenExchange'
var gitHubActionsRepository = 'Acestus/ace'
var gitHubActionsSubjects = [
  'repo:${gitHubActionsRepository}:environment:${environment}'
  'repo:${gitHubActionsRepository}:ref:refs/heads/main'
]
var storageTableRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' existing = {
  name: staticWebAppName
}

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: functionStorageAccountName
}

resource dataStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: dataStorageAccountName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'FC1'
    capacity: 0
    tier: 'FlexConsumption'
  }
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }
}

module userManagedIdentity '../../modules-bicep/user-managed-identity/user-managed-identity.bicep' = {
  name: '${deployment().name}-umi'
  params: {
    name: userManagedIdentityName
    location: location
    tags: tags
    federatedIdentityCredentials: [
      for subject in gitHubActionsSubjects: {
        name: 'github-oidc-${uniqueString(subject)}'
        issuer: gitHubActionsIssuer
        subject: subject
        audiences: [
          gitHubActionsAudience
        ]
      }
    ]
  }
}

resource dataStorageTableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(dataStorageAccount.id, userManagedIdentityName, storageTableRoleDefinitionId)
  scope: dataStorageAccount
  properties: {
    roleDefinitionId: storageTableRoleDefinitionId
    principalId: userManagedIdentity.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userManagedIdentityName)}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    functionAppConfig: {
      runtime: {
        name: 'dotnet-isolated'
        version: '10.0'
      }
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${functionStorageAccount.properties.primaryEndpoints.blob}function-deployments'
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
          'https://${staticWebApp.properties.defaultHostname}'
        ]
      }
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccountName};EndpointSuffix=core.windows.net;AccountKey=${functionStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'AceCrmTableStorageAccountName'
          value: dataStorageAccountName
        }
        {
          name: 'AceCrmTableStorageClientId'
          value: userManagedIdentity.outputs.clientId
        }
      ]
    }
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.id

@description('The name of the App Service Plan.')
output appServicePlanNameOutput string = appServicePlan.name

@description('The deployment token for the Static Web App.')
output deploymentToken string = staticWebApp.listSecrets().properties.apiKey

@description('The default hostname of the Static Web App.')
output defaultHostname string = staticWebApp.properties.defaultHostname

@description('The default hostname of the Function App.')
output functionAppHostname string = functionApp.properties.defaultHostName

@description('The resource ID of the user managed identity.')
output userManagedIdentityResourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity.')
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity.')
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId

@description('The name of the user managed identity.')
output userManagedIdentityName string = userManagedIdentity.outputs.identityName

@description('The resource ID of the CRM data storage account.')
output dataStorageAccountResourceId string = dataStorageAccount.id
