// Opinionated Function App module following Acestus standards and security best practices

metadata name = 'Acestus Function App'
metadata description = 'Custom Function App module with Acestus security defaults and naming conventions'
metadata version = '1.1.0'

@description('Function App name')
param name string

@description('Location for the Function App')
param location string = resourceGroup().location

@description('Tags to apply to the Function App')
param tags object = {}

@description('Function App kind (e.g., functionapp, functionapp,linux)')
param kind string = 'functionapp'

@description('App Service Plan resource ID (AVM-compatible alias: serverFarmResourceId)')
param appServicePlanId string = ''

@description('App Service Plan resource ID (AVM-compatible parameter)')
param serverFarmResourceId string = ''

// Resolve the actual App Service Plan ID
var resolvedServerFarmResourceId = !empty(serverFarmResourceId) ? serverFarmResourceId : appServicePlanId

@description('Storage account resource ID (legacy parameter - use storageAccountResourceId for AVM compatibility)')
param storageAccountId string = ''

@description('Storage account resource ID (AVM-compatible parameter)')
param storageAccountResourceId string = ''

// Resolve the actual storage account resource ID
var resolvedStorageAccountResourceId = !empty(storageAccountResourceId) ? storageAccountResourceId : storageAccountId

@description('Storage account name used for managed identity auth')
param storageAccountName string = ''

@description('Use managed identity authentication for storage account access')
param storageAccountUseIdentityAuthentication bool = true

@description('Storage account connection string (required if managed identity is disabled)')
@secure()
param storageAccountConnectionString string = ''

@description('Application Insights resource ID')
param applicationInsightsId string = ''

@description('Application Insights resource ID (AVM-compatible alias)')
param appInsightResourceId string = ''

// Resolve the actual App Insights ID
var resolvedAppInsightsId = !empty(appInsightResourceId) ? appInsightResourceId : applicationInsightsId

@description('Application Insights connection string')
@secure()
param applicationInsightsConnectionString string = ''

@description('Application Insights instrumentation key')
@secure()
param applicationInsightsInstrumentationKey string = ''

@description('Functions worker runtime')
@allowed([
  'powershell'
  'python'
  'dotnet'
  'node'
])
param functionsWorkerRuntime string = 'powershell'

@description('Functions worker runtime version (optional)')
param functionsWorkerRuntimeVersion string = ''

@description('Functions extension version')
param functionsExtensionVersion string = '~4'

@description('Enable WEBSITE_RUN_FROM_PACKAGE')
param websiteRunFromPackage bool = true

@description('Always On setting for the Function App')
param alwaysOn bool = false

@description('Force HTTPS only')
param httpsOnly bool = true

@description('Additional app settings to merge')
param additionalAppSettings array = []

@description('Additional site config settings to merge (overrides defaults if provided)')
param additionalSiteConfig object = {}

@description('Direct siteConfig object (AVM-compatible). If provided, overrides all other site config settings.')
param siteConfig object = {}

@description('Managed identities configuration (AVM-compatible). If provided, overrides enableSystemAssignedIdentity and userManagedIdentityId.')
param managedIdentities object = {}

@description('Enable system-assigned managed identity')
param enableSystemAssignedIdentity bool = true

@description('User-assigned identity resource ID (optional)')
param userManagedIdentityId string = ''

var storageBlobServiceUri = 'https://${storageAccountName}.blob.${environment().suffixes.storage}'

var managedIdentitySettings = storageAccountUseIdentityAuthentication ? [
  {
    name: 'AzureWebJobsStorage__accountName'
    value: storageAccountName
  }
  {
    name: 'AzureWebJobsStorage__blobServiceUri'
    value: storageBlobServiceUri
  }
  {
    name: 'AzureWebJobsStorage__credential'
    value: 'managedidentity'
  }
] : (!empty(storageAccountConnectionString) ? [
  {
    name: 'AzureWebJobsStorage'
    value: storageAccountConnectionString
  }
] : [])

var appInsightsSettings = !empty(applicationInsightsConnectionString) ? [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
  }
] : []

var appInsightsKeySettings = !empty(applicationInsightsInstrumentationKey) ? [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsightsInstrumentationKey
  }
] : []

var runtimeSettings = [
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: functionsWorkerRuntime
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: functionsExtensionVersion
  }
]

var runtimeVersionSettings = !empty(functionsWorkerRuntimeVersion) ? [
  {
    name: 'FUNCTIONS_WORKER_RUNTIME_VERSION'
    value: functionsWorkerRuntimeVersion
  }
] : []

var runFromPackageSettings = websiteRunFromPackage ? [
  {
    name: 'WEBSITE_RUN_FROM_PACKAGE'
    value: '1'
  }
] : []

var baseAppSettings = concat(
  runtimeSettings,
  runtimeVersionSettings,
  runFromPackageSettings,
  appInsightsSettings,
  appInsightsKeySettings,
  managedIdentitySettings
)

var finalAppSettings = concat(baseAppSettings, additionalAppSettings)

var baseSiteConfig = {
  appSettings: finalAppSettings
  use32BitWorkerProcess: false
  ftpsState: 'FtpsOnly'
  minTlsVersion: '1.2'
  alwaysOn: alwaysOn
}

var finalSiteConfig = union(baseSiteConfig, additionalSiteConfig)

// Resolve siteConfig - use direct param if provided, otherwise use computed config
var resolvedSiteConfig = !empty(siteConfig) ? siteConfig : finalSiteConfig

// Resolve managedIdentities - use direct param if provided, otherwise use legacy params
var resolvedManagedIdentities = !empty(managedIdentities) ? managedIdentities : {
  systemAssigned: enableSystemAssignedIdentity
  userAssignedResourceIds: !empty(userManagedIdentityId) ? [userManagedIdentityId] : []
}

module functionApp 'br/public:avm/res/web/site:0.21.0' = {
  params: {
    name: name
    location: location
    tags: tags
    kind: kind
    serverFarmResourceId: resolvedServerFarmResourceId
    storageAccountResourceId: resolvedStorageAccountResourceId
    storageAccountUseIdentityAuthentication: storageAccountUseIdentityAuthentication
    managedIdentities: resolvedManagedIdentities
    appInsightResourceId: !empty(resolvedAppInsightsId) ? resolvedAppInsightsId : null
    siteConfig: resolvedSiteConfig
    httpsOnly: httpsOnly
  }
}

@description('The resource ID of the Function App')
output resourceId string = functionApp.outputs.resourceId

@description('The name of the Function App')
output functionAppName string = functionApp.outputs.name

@description('The default hostname of the Function App')
output defaultHostname string = functionApp.outputs.defaultHostname

@description('The principal ID of the system-assigned managed identity')
output systemAssignedPrincipalId string = functionApp.outputs.?systemAssignedMIPrincipalId ?? ''

@description('All outputs from the AVM Function App module')
output functionApp object = functionApp.outputs
