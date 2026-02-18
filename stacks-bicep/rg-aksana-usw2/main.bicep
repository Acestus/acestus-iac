targetScope = 'resourceGroup'

// ============================================================================
// AKS Analytics Stack using AVM Pattern Module
// Deploys AKS cluster with monitoring using avm/ptn/azd/aks pattern
// ============================================================================

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the project, used for naming resources.')
param projectName string

@description('The environment name, used for naming resources.')
@allowed(['dev', 'stg', 'prd'])
param environment string

@description('The Cloud Adoption Framework location, used for naming resources.')
param CAFLocation string

@description('The instance number, used for naming resources.')
param instanceNumber string

@description('Tags to be applied to all resources.')
param tags object = {}

@description('Kubernetes version.')
param kubernetesVersion string = '1.30'

@description('System pool VM size: CostOptimised, Standard, HighSpec.')
@allowed(['CostOptimised', 'Standard', 'HighSpec'])
param systemPoolSize string = 'CostOptimised'

@description('Agent pool VM size: CostOptimised, Standard, HighSpec, or empty for no agent pool.')
@allowed(['', 'CostOptimised', 'Standard', 'HighSpec'])
param agentPoolSize string = ''

@description('SKU tier: Free or Standard.')
@allowed(['Free', 'Standard'])
param skuTier string = 'Free'

@description('Resource ID of existing Log Analytics workspace for monitoring.')
param monitoringWorkspaceResourceId string

@description('Principal ID for Key Vault access (e.g., deploying user or service principal).')
param principalId string

// ============================================================================
// Variables
// ============================================================================

var aksClusterName = 'aks-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var containerRegistryName = 'acr${projectName}${environment}${CAFLocation}${instanceNumber}'
var keyVaultName = 'kv-${projectName}-${environment}-${CAFLocation}'

// ============================================================================
// Resources
// ============================================================================

// AKS Cluster using Acestus AKS AZD Pattern Module
// This pattern creates: AKS cluster, Container Registry, Key Vault, and configures monitoring
module aksStack 'br:acracemgtcrdeveus2001.azurecr.io/bicep/modules/aks-azd-pattern:v1.0.0' = {
  name: '${deployment().name}-aks'
  params: {
    name: aksClusterName
    location: location
    tags: tags
    
    // Required parameters
    containerRegistryName: containerRegistryName
    keyVaultName: keyVaultName
    monitoringWorkspaceResourceId: monitoringWorkspaceResourceId
    principalId: principalId
    
    // Kubernetes configuration
    kubernetesVersion: kubernetesVersion
    skuTier: skuTier
    
    // Pool sizing (CostOptimised/Standard/HighSpec maps to VM sizes)
    systemPoolSize: systemPoolSize
    agentPoolSize: agentPoolSize
    
    // Network configuration
    networkDataplane: 'azure'
    loadBalancerSku: 'standard'
    
    // Security configuration
    enableRbacAuthorization: true
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('The name of the AKS cluster.')
output aksClusterName string = aksStack.outputs.managedClusterName ?? ''

@description('The resource ID of the AKS cluster.')
output aksClusterResourceId string = aksStack.outputs.?managedClusterResourceId ?? ''

@description('The client ID of the AKS managed identity.')
output aksClientId string = aksStack.outputs.?managedClusterClientId ?? ''

@description('The object ID of the AKS managed identity.')
output aksObjectId string = aksStack.outputs.?managedClusterObjectId ?? ''

@description('The name of the Container Registry.')
output containerRegistryName string = aksStack.outputs.?containerRegistryName ?? ''

@description('The login server of the Container Registry.')
output containerRegistryLoginServer string = aksStack.outputs.containerRegistryLoginServer ?? ''

@description('The resource group name.')
output resourceGroupName string = aksStack.outputs.resourceGroupName ?? resourceGroup().name
