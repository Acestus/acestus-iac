// Acestus .NET AKS Template - AVM Pattern Modules
// Uses Azure Verified Modules (AVM) patterns for best-practice, production-ready deployment
// Patterns used:
//   - avm/ptn/azd/aks (via aks-azd-pattern wrapper) - AKS + ACR + Key Vault + RBAC
//   - avm/ptn/azd/monitoring - Log Analytics + Application Insights + Dashboard
//   - avm/res/storage/storage-account - Blob storage for time-logger

targetScope = 'resourceGroup'

// ============================================================================
// Parameters - Identity & Naming
// ============================================================================

@description('Project name used in resource naming')
param projectName string = 'timelogger'

@description('Environment: dev, stg, prd')
@allowed(['dev', 'stg', 'prd'])
param environment string = 'dev'

@description('Azure region short code for naming (e.g., eus1, weu, aue)')
param regionCode string = 'eus1'

@description('Instance number for resource naming')
param instanceNumber string = '001'

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Additional tags to apply to resources')
param tags object = {}

// ============================================================================
// Parameters - AKS Configuration
// ============================================================================

@description('Kubernetes version')
param kubernetesVersion string = '1.30'

@description('AKS SKU tier')
@allowed(['Free', 'Standard', 'Premium'])
param aksSkuTier string = 'Free'

@description('System pool VM size preset')
@allowed(['CostOptimised', 'Standard', 'HighSpec'])
param systemPoolSize string = 'Standard'

@description('Agent pool VM size preset (empty for no agent pool)')
@allowed(['', 'CostOptimised', 'Standard', 'HighSpec'])
param agentPoolSize string = ''

@description('Enable Azure RBAC for Kubernetes authorization')
param enableAzureRbac bool = true

@description('Disable local accounts (recommended for production)')
param disableLocalAccounts bool = false

@description('Enable Key Vault secrets provider CSI driver')
param enableKeyvaultSecretsProvider bool = false

// ============================================================================
// Parameters - Container Registry Configuration
// ============================================================================

@description('Container Registry SKU')
@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string = 'Basic'

// ============================================================================
// Parameters - Storage Configuration (for time-logger)
// ============================================================================

@description('Storage account SKU')
@allowed(['Standard_LRS', 'Standard_ZRS', 'Standard_GRS', 'Standard_RAGRS'])
param storageSkuName string = 'Standard_LRS'

@description('Enable blob soft delete for storage')
param enableBlobSoftDelete bool = true

// ============================================================================
// Parameters - Network Configuration
// ============================================================================

@description('Network plugin for AKS')
@allowed(['azure', 'kubenet'])
param networkPlugin string = 'azure'

@description('Network policy for AKS')
@allowed(['azure', 'calico'])
param networkPolicy string = 'azure'

// ============================================================================
// Parameters - Security & Monitoring
// ============================================================================

@description('Principal ID for Key Vault access (deploying user or service principal)')
param principalId string

@description('Principal type for Key Vault access')
@allowed(['Device', 'ForeignGroup', 'Group', 'ServicePrincipal', 'User'])
param principalType string = 'ServicePrincipal'

// ============================================================================
// Variables
// ============================================================================

var cafName = '${projectName}-${environment}-${regionCode}-${instanceNumber}'

// Tags are now fully provided by the 'tags' parameter from bicepparam

// Resource names (following CAF conventions)
var aksClusterName = 'aks-${cafName}'
// ACR name must be 5-50 chars, alphanumeric only, globally unique
var acrName = 'acr${replace(projectName, '-', '')}${environment}${regionCode}${instanceNumber}'
var keyVaultName = 'kv-${cafName}'
var monitoringName = cafName // Base name for monitoring resources (log-, appi-, dash- prefixes added by module)
var storageAccountName = 'st${replace(projectName, '-', '')}${environment}${regionCode}${instanceNumber}'

// ============================================================================
// Resources - AVM Pattern Modules
// ============================================================================

// Monitoring Pattern - Includes Log Analytics + Application Insights + Dashboard
// Pattern: avm/ptn/azd/monitoring:0.2.1
module monitoring '../../modules-bicep/avm-ptn-azd-monitoring/main.bicep' = {
  name: 'deploy-monitoring-${cafName}'
  params: {
    name: monitoringName
    location: location
    tags: tags
  }
}

// AKS AZD Pattern - Includes AKS cluster, ACR, Key Vault, and RBAC configuration
// This is the primary pattern that deploys the complete AKS infrastructure
// Pattern: avm/ptn/azd/aks:0.2.0
module aksAzdPattern '../../modules-bicep/aks-azd-pattern/main.bicep' = {
  name: 'deploy-${aksClusterName}'
  params: {
    // Identity
    name: aksClusterName
    location: location
    tags: tags

    // Associated resources
    containerRegistryName: acrName
    keyVaultName: keyVaultName
    monitoringWorkspaceResourceId: monitoring.outputs.logAnalyticsWorkspaceResourceId
    principalId: principalId
    principalType: principalType

    // Kubernetes configuration
    kubernetesVersion: kubernetesVersion
    skuTier: aksSkuTier
    systemPoolSize: systemPoolSize
    agentPoolSize: agentPoolSize

    // Network configuration
    networkPlugin: networkPlugin
    networkPolicy: networkPolicy
    loadBalancerSku: 'standard'

    // Security configuration
    enableRbacAuthorization: true
    enableAzureRbac: enableAzureRbac
    disableLocalAccounts: disableLocalAccounts
    enableKeyvaultSecretsProvider: enableKeyvaultSecretsProvider

    // Container Registry configuration
    acrSku: acrSku

    // Key Vault configuration
    enablePurgeProtection: environment == 'prd'
    enableVaultForDeployment: true
    enableVaultForTemplateDeployment: true
  }
}

// Storage Account for time-logger CronJob blob storage
// Pattern: avm/res/storage/storage-account:0.31.0
module storageAccount '../../modules-bicep/storage-account/main.bicep' = {
  name: 'deploy-${storageAccountName}'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    skuName: storageSkuName
    kind: 'StorageV2'

    // Security configuration
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true

    // Soft delete configuration
    enableBlobSoftDelete: enableBlobSoftDelete
    blobSoftDeleteRetentionDays: 30
    enableContainerSoftDelete: true
    containerSoftDeleteRetentionDays: 30
    enableBlobVersioning: environment == 'prd'

    // Network configuration - Allow access for now (can be locked down with private endpoints)
    defaultNetworkAction: 'Allow'
    allowedIpRules: []

    // Blob containers for time-logger
    blobContainers: [
      {
        name: 'time-logs'
        publicAccess: 'None'
      }
    ]
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('AKS cluster name')
output aksClusterName string = aksAzdPattern.outputs.managedClusterName

@description('AKS cluster resource ID')
output aksClusterResourceId string = aksAzdPattern.outputs.managedClusterResourceId

@description('AKS managed identity client ID')
output aksClientId string = aksAzdPattern.outputs.managedClusterClientId

@description('Container registry name')
output acrName string = aksAzdPattern.outputs.containerRegistryName

@description('Container registry login server')
output acrLoginServer string = aksAzdPattern.outputs.containerRegistryLoginServer

@description('Log Analytics workspace resource ID')
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceResourceId

@description('Log Analytics workspace name')
output logAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsWorkspaceName

@description('Application Insights resource ID')
output applicationInsightsResourceId string = monitoring.outputs.applicationInsightsResourceId

@description('Application Insights connection string')
output applicationInsightsConnectionString string = monitoring.outputs.applicationInsightsConnectionString

@description('Storage account name')
output storageAccountName string = storageAccount.outputs.name

@description('Storage account resource ID')
output storageAccountResourceId string = storageAccount.outputs.resourceId

@description('Resource group name')
output resourceGroupName string = resourceGroup().name

@description('CAF naming prefix')
output cafName string = cafName
