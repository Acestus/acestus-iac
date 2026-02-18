// Azure Kubernetes Service (AKS) Template Infrastructure - .NET
// Deploys AKS cluster with Azure Container Registry
// Note: This template uses ACR-hosted Bicep modules. Replace with your own ACR or use public modules.

// ============================================================================
// Parameters
// ============================================================================

@description('Project name used in resource naming')
param projectName string = 'aksdotnet'

@description('Environment: dev, stg, prd')
@allowed(['dev', 'stg', 'prd'])
param environment string

@description('Azure region short code for naming')
param regionCode string = 'usw2'

@description('Instance number for resource naming')
param instanceNumber string = '001'

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('Kubernetes version')
param kubernetesVersion string = '1.34.2'

@description('Node pool VM size')
param nodeVmSize string = 'Standard_D2s_v3'

@description('Node count')
param nodeCount int = 2

@description('Username who created the resources')
param createdBy string

@description('Additional tags to apply to resources')
param tags object = {}

@description('Existing ACR name')
param existingAcrName string = ''

@description('Existing ACR resource group')
param existingAcrResourceGroup string = ''

@description('Existing ACR subscription ID')
param existingAcrSubscriptionId string = ''

@description('Existing Log Analytics Workspace name')
param existingLogAnalyticsName string = ''

@description('Existing Log Analytics Workspace resource group')
param existingLogAnalyticsResourceGroup string = ''

@description('Existing Log Analytics Workspace subscription ID')
param existingLogAnalyticsSubscriptionId string = ''

@description('Existing User Assigned Identity name')
param existingIdentityName string = ''

@description('Existing User Assigned Identity resource group')
param existingIdentityResourceGroup string = ''

@description('Existing Application Insights name')
param existingAppInsightsName string = ''

@description('Existing Application Insights resource group')
param existingAppInsightsResourceGroup string = ''

// ============================================================================
// Variables
// ============================================================================

var cafName = '${projectName}-${environment}-${regionCode}-${instanceNumber}'

var defaultTags = {
  ManagedBy: '<your-repo-url>'
  CreatedBy: createdBy
  Environment: environment == 'prd' ? 'Production' : 'Development'
  Project: 'Time Logger - AKS .NET Template'
  CAFName: cafName
}

var mergedTags = union(defaultTags, tags)

// Resource names (following CAF conventions)
var aksClusterName = 'aks-${projectName}-${environment}-${regionCode}-${instanceNumber}'
var logAnalyticsName = 'log-${cafName}'
var storageAccountName = 'st${projectName}${environment}${regionCode}${instanceNumber}'

// Check if existing resources are provided
var useExistingAcr = existingAcrName != ''
var useExistingLogAnalytics = existingLogAnalyticsName != ''
var useExistingIdentity = existingIdentityName != ''
var useExistingAppInsights = existingAppInsightsName != ''

// ============================================================================
// Resources
// ============================================================================

// Reference to existing Log Analytics Workspace (if provided)
resource existingLogAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (useExistingLogAnalytics) {
  name: existingLogAnalyticsName
  scope: resourceGroup(existingLogAnalyticsSubscriptionId, existingLogAnalyticsResourceGroup)
}

// Log Analytics Workspace for AKS monitoring
module logAnalytics 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/log-analytics-workspace:v1.2.0' = if (!useExistingLogAnalytics) {
  name: 'deploy-${logAnalyticsName}'
  params: {
    name: logAnalyticsName
    location: location
    tags: mergedTags
    sku: 'PerGB2018'
    retentionInDays: 30
  }
}

// Reference to existing User Assigned Identity (if provided)
resource existingIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (useExistingIdentity) {
  name: existingIdentityName
  scope: resourceGroup(existingIdentityResourceGroup)
}

// Reference to existing Application Insights (if provided)
resource existingAppInsights 'Microsoft.Insights/components@2020-02-02' existing = if (useExistingAppInsights) {
  name: existingAppInsightsName
  scope: resourceGroup(existingAppInsightsResourceGroup)
}

// Reference to existing ACR (if provided)
resource existingAcr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = if (useExistingAcr) {
  name: existingAcrName
  scope: resourceGroup(
    existingAcrSubscriptionId != '' ? existingAcrSubscriptionId : subscription().subscriptionId,
    existingAcrResourceGroup
  )
}

// Storage Account for time-logger CronJob
module storageAccount 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/storage-account:v1.1.0' = {
  name: 'deploy-${storageAccountName}'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: mergedTags
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    defaultNetworkAction: 'Allow' // Allow for AKS access
    allowedIpRules: []
    blobContainers: [
      {
        name: 'time-logs'
        publicAccess: 'None'
      }
    ]
  }
}

// AKS Cluster
module aksCluster 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/aks-cluster:v1.1.0' = {
  name: 'deploy-${aksClusterName}'
  params: {
    name: aksClusterName
    location: location
    tags: mergedTags
    kubernetesVersion: kubernetesVersion
    skuTier: environment == 'prd' ? 'Standard' : 'Free'
    enableSystemAssignedIdentity: !useExistingIdentity
    userAssignedIdentityResourceId: useExistingIdentity ? existingIdentity.id : ''
    primaryAgentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: nodeVmSize
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: environment == 'prd'
        minCount: environment == 'prd' ? 2 : null
        maxCount: environment == 'prd' ? 5 : null
        maxPods: 30
      }
    ]
    networkPlugin: 'azure'
    networkPolicy: 'azure'
    loadBalancerSku: 'standard'
    enableContainerInsights: true
    monitoringWorkspaceResourceId: useExistingLogAnalytics ? existingLogAnalytics.id : logAnalytics.outputs.resourceId
    enableAzureRBAC: true
    enableAadAuthentication: true
    disableLocalAccounts: environment == 'prd'
  }
}

output aksClusterName string = aksCluster.outputs.name
output aksClusterFqdn string = aksCluster.outputs.controlPlaneFQDN
output logAnalyticsWorkspaceId string = useExistingLogAnalytics
  ? existingLogAnalytics!.id
  : logAnalytics.outputs.resourceId
output appInsightsName string = useExistingAppInsights ? existingAppInsights!.name : ''
output appInsightsInstrumentationKey string = useExistingAppInsights
  ? existingAppInsights!.properties.InstrumentationKey
  : ''
output storageAccountName string = storageAccount.outputs.name
output storageAccountId string = storageAccount.outputs.resourceId
output acrLoginServer string = useExistingAcr ? existingAcr!.properties.loginServer : ''
output acrName string = useExistingAcr ? existingAcr!.name : ''
