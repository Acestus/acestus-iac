targetScope = 'resourceGroup'

@description('Name of the function app')
param functionAppName string

@description('Name of the storage account')
param storageAccountName string

@description('Primary location for all resources')
param location string

@description('The tenant ID')
param tenantId string

@description('Application Insights Resource Group')
param aiResourceGroup string

@description('Existing App Service Plan resource ID')
param existingAppServicePlanId string

@description('Existing Application Insights resource ID')
param existingApplicationInsightsId string

@description('User Managed Identity Resource ID')
param userManagedIdentityId string

@description('Existing Service Bus Namespace Resource ID')
param existingServiceBusNamespaceId string

@description('Python version for the function app')
param pythonVersion string

@description('func API authentication settings')
@secure()
param funcApiSettings object = {}

var tags = {
  Application: 'JML'
  ManagedBy: 'Bicep'
  Purpose: 'Entra Lifecycle Management - JML Functions'
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: 'storageAccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    allowSharedKeyAccess: true
    requireInfrastructureEncryption: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }

    blobServices: {
      containers: [
        {
          name: 'azure-webjobs-hosts'
          publicAccess: 'None'
        }
        {
          name: 'azure-webjobs-secrets'
          publicAccess: 'None'
        }
      ]
    }

    queueServices: null
    tags: tags
  }
}

resource existingApplicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: last(split(existingApplicationInsightsId, '/'))
  scope: resourceGroup(split(existingApplicationInsightsId, '/')[2], split(existingApplicationInsightsId, '/')[4])
}

module functionApp 'br/public:avm/res/web/site:0.21.0' = {
  name: 'functionApp'
  params: {
    name: functionAppName
    location: location
    kind: 'functionapp,linux'
    serverFarmResourceId: existingAppServicePlanId
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: !empty(userManagedIdentityId) ? [userManagedIdentityId] : []
    }
    storageAccountResourceId: storageAccount.outputs.resourceId
    storageAccountUseIdentityAuthentication: true
    appInsightResourceId: existingApplicationInsightsId
    siteConfig: {
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.outputs.name
        }
        {
          name: 'AzureWebJobsStorage__blobServiceUri'
          value: storageAccount.outputs.primaryBlobEndpoint
        }
        {
          name: 'AzureWebJobsStorage__credential'
          value: 'managedidentity'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME_VERSION'
          value: pythonVersion
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: existingApplicationInsights.properties.ConnectionString
        }
        {
          name: 'AZURE_TENANT_ID'
          value: tenantId
        }
        {
          name: 'AI_RESOURCE_GROUP'
          value: aiResourceGroup
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storageAccount.outputs.name
        }
        {
          name: 'CALL_SCRIPTS_CONTAINER_NAME'
          value: 'call-scripts'
        }
        {
          name: 'STORAGE_QUEUE_ENDPOINT'
          value: replace(storageAccount.outputs.primaryBlobEndpoint, 'blob', 'queue')
        }
        {
          name: 'func_CONTAINER_NAME'
          value: 'func'
        }
        {
          name: 'LOG_TO_APPLICATION_INSIGHTS'
          value: 'true'
        }
        {
          name: 'func_API_TIMEOUT_SECONDS'
          value: '30'
        }
        {
          name: 'func_MAX_FILES_RESPONSE'
          value: '100'
        }
        {
          name: 'func_ENABLE_CACHING'
          value: 'true'
        }
        {
          name: 'func_CACHE_DURATION_MINUTES'
          value: '5'
        }
        {
          name: 'func_MAX_FILE_SIZE'
          value: string(funcApiSettings.maxFileSize)
        }
        {
          name: 'func_RATE_LIMIT_PER_MINUTE'
          value: string(funcApiSettings.rateLimitPerMinute)
        }
        {
          name: 'func_CACHE_CONTROL_MAX_AGE'
          value: string(funcApiSettings.cacheControlMaxAge)
        }
        {
          name: 'func_ENABLE_HTML_GENERATION'
          value: string(funcApiSettings.enableHTMLGeneration)
        }
        {
          name: 'func_DEFAULT_SCRIPT_TYPE'
          value: funcApiSettings.defaultScriptType
        }
        {
          name: 'func_ENABLE_TOKEN_REPLACEMENT'
          value: string(funcApiSettings.enableTokenReplacement)
        }
        {
          name: 'SERVICE_BUS_NAMESPACE_ID'
          value: existingServiceBusNamespaceId
        }
        {
          name: 'SERVICE_BUS_CONNECTION__fullyQualifiedNamespace'
          value: '${last(split(existingServiceBusNamespaceId, '/'))}.servicebus.windows.net'
        }
      ]
    }
    httpsOnly: true
    tags: tags
  }
}

output functionAppName string = functionApp.outputs.name
output functionAppResourceId string = functionApp.outputs.resourceId
output applicationInsightsName string = last(split(existingApplicationInsightsId, '/'))
output functionAppPrincipalId string = functionApp.outputs.systemAssignedMIPrincipalId
output userManagedIdentityEnabled bool = !empty(userManagedIdentityId)
output userManagedIdentityId string = userManagedIdentityId
