// Acestus .NET AKS Template - AVM Patterns
// Uses Azure Verified Modules (AVM) for best-practice deployment

// ============================================================================
// Parameters
// ============================================================================

@description('Project name used in resource naming')
param projectName string = 'timelogger'

@description('Environment: dev, stg, prd')
@allowed(['dev', 'stg', 'prd'])
param environment string = 'dev'

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
param createdBy string = 'deployment-pipeline'

@description('Additional tags to apply to resources')
param tags object = {
  ManagedBy: '<your-repo-url>'
  CreatedBy: createdBy
  Subscription: '<your-subscription-name>'
  Project: 'Time Logger Template'
  CAFName: '${projectName}-${environment}-${regionCode}-${instanceNumber}'
}

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

// Subscription vending (lz/sub-vending)
module subVending 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/lz/sub-vending:0.5.3' = {
  name: 'sub-vending'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    instanceNumber: instanceNumber
    location: location
    tags: tags
  }
}

// Hub networking (network/hub-networking)
module hubNetworking 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/network/hub-networking:0.5.0' = {
  name: 'hub-networking'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    instanceNumber: instanceNumber
    location: location
    tags: tags
  }
}

// Azure Container Registry (res/container-registry)
module acr 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/res/container-registry:0.5.1' = {
  name: 'acr'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    instanceNumber: instanceNumber
    location: location
    tags: tags
    sku: 'Basic'
    geoReplicationEnabled: false
    vulnerabilityAssessmentEnabled: true
  }
}

// AKS Landing Zone Accelerator (ptn/aks-lza)
module aksLza 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/ptn/aks-lza:0.3.0' = {
  name: 'aks-lza'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    instanceNumber: instanceNumber
    location: location
    tags: tags
    containerRegistryId: acr.outputs.resourceId
    hubNetworkId: hubNetworking.outputs.virtualNetworkId
    enableDefender: true
    enableAzureAD: true
    enableCNI: true
    enableAGIC: true
  }
}

// RBAC management (authorization/resource-role-assignment)
module rbacAssignment 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/authorization/resource-role-assignment:0.1.2' = {
  name: 'rbac-assignment'
  params: {
    principalId: aksLza.outputs.kubeletIdentityPrincipalId
    scope: acr.outputs.resourceId
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // AcrPull
  }
}

// Centralized monitoring (azd/monitoring)
module monitoring 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/azd/monitoring:0.2.1' = {
  name: 'monitoring'
  params: {
    projectName: projectName
    environment: environment
    regionCode: regionCode
    instanceNumber: instanceNumber
    location: location
    tags: tags
    aksClusterId: aksLza.outputs.resourceId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    enablePrometheus: true
    enableContainerInsights: true
  }
}

// Reference to existing Log Analytics Workspace (if provided)
// Log Analytics Workspace for AKS monitoring
module logAnalytics 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/log-analytics-workspace:v1.2.0' = {
  name: 'deploy-${logAnalyticsName}'
  params: {
    name: logAnalyticsName
    location: location
    tags: mergedTags
    sku: 'PerGB2018'
    retentionInDays: 30
  }
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
module userAssignedIdentity 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/user-managed-identity:v1.0.0' = {
  name: 'deploy-${cafName}-identity'
  params: {
    name: '${cafName}-identity'
    location: location
    tags: mergedTags
  }
}

// Reference to existing Application Insights (if provided)
module appInsights 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/app-insights:v1.0.0' = {
  name: 'deploy-${cafName}-appinsights'
  params: {
    name: '${cafName}-appinsights'
    location: location
    tags: mergedTags
    applicationType: 'web'
  }
}

// Reference to existing ACR (if provided)
module acr 'br:acrskpmgtcrprdusw2001.azurecr.io/bicep/container-registry:v1.0.0' = {
  name: 'deploy-${cafName}-acr'
  params: {
    name: 'acr${projectName}${environment}${regionCode}${instanceNumber}'
    location: location
    tags: mergedTags
    sku: 'Basic'
  }
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
    enableSystemAssignedIdentity: false
    userAssignedIdentityResourceId: userAssignedIdentity.outputs.resourceId
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
    monitoringWorkspaceResourceId: logAnalytics.outputs.resourceId
    enableAzureRBAC: true
    enableAadAuthentication: true
    disableLocalAccounts: environment == 'prd'
  }
}

output aksClusterName string = aksLza.outputs.name
output aksClusterFqdn string = aksLza.outputs.controlPlaneFQDN
output logAnalyticsWorkspaceId string = monitoring.outputs.logAnalyticsWorkspaceId
output acrLoginServer string = acr.outputs.loginServer
output acrName string = acr.outputs.name
