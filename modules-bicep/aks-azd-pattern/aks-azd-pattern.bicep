// Opinionated AKS AZD Pattern wrapper module following Acestus standards
// Wraps the AVM avm/ptn/azd/aks pattern for standardized deployments

metadata name = 'Acestus AKS AZD Pattern'
metadata description = 'Wrapper module for AVM avm/ptn/azd/aks pattern with Acestus defaults and naming conventions'
metadata version = '1.0.0'

// ============================================================================
// Parameters - Identity
// ============================================================================

@description('The name of the AKS cluster.')
param name string

@description('Location for the AKS cluster.')
param location string = resourceGroup().location

@description('Tags to apply to all resources.')
param tags object = {}

// ============================================================================
// Parameters - Associated Resources
// ============================================================================

@description('Name for the Container Registry. Must be globally unique, alphanumeric only.')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('Name for the Key Vault.')
@minLength(3)
@maxLength(24)
param keyVaultName string

@description('Resource ID of existing Log Analytics workspace for monitoring.')
param monitoringWorkspaceResourceId string

@description('Principal ID for Key Vault access (deploying user or service principal).')
param principalId string

@description('Principal type for Key Vault access.')
@allowed(['Device', 'ForeignGroup', 'Group', 'ServicePrincipal', 'User'])
param principalType string = 'ServicePrincipal'

// ============================================================================
// Parameters - Kubernetes Configuration
// ============================================================================

@description('Kubernetes version.')
param kubernetesVersion string = '1.30'

@description('SKU tier for the AKS cluster.')
@allowed(['Free', 'Standard', 'Premium'])
param skuTier string = 'Free'

@description('System pool VM size: CostOptimised, Standard, HighSpec.')
@allowed(['CostOptimised', 'Standard', 'HighSpec'])
param systemPoolSize string = 'Standard'

@description('Agent pool VM size: CostOptimised, Standard, HighSpec, or empty for no agent pool.')
@allowed(['', 'CostOptimised', 'Standard', 'HighSpec'])
param agentPoolSize string = ''

@description('Custom system pool configuration array.')
param systemPoolConfig array = []

@description('Custom agent pool configuration array.')
param agentPoolConfig array = []

// ============================================================================
// Parameters - Network Configuration
// ============================================================================

@description('Network dataplane.')
@allowed(['azure', 'cilium'])
param networkDataplane string = 'azure'

@description('Network plugin.')
@allowed(['azure', 'kubenet'])
param networkPlugin string = 'azure'

@description('Network policy.')
@allowed(['azure', 'calico'])
param networkPolicy string = 'azure'

@description('Load balancer SKU.')
@allowed(['basic', 'standard'])
param loadBalancerSku string = 'standard'

@description('Service CIDR for Kubernetes services.')
param serviceCidr string = ''

@description('DNS service IP address.')
param dnsServiceIP string = ''

@description('Pod CIDR for Kubernetes pods.')
param podCidr string = ''

@description('DNS prefix for the cluster.')
param dnsPrefix string = ''

@description('Enable public network access.')
param publicNetworkAccess string = 'Enabled'

// ============================================================================
// Parameters - Security Configuration
// ============================================================================

@description('Enable Azure RBAC for Kubernetes authorization.')
param enableRbacAuthorization bool = true

@description('Enable Azure RBAC.')
param enableAzureRbac bool = true

@description('Disable local accounts.')
param disableLocalAccounts bool = true

@description('Enable Key Vault secrets provider.')
param enableKeyvaultSecretsProvider bool = false

// ============================================================================
// Parameters - Container Registry Configuration
// ============================================================================

@description('Container Registry SKU.')
@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string = 'Basic'

// ============================================================================
// Parameters - Key Vault Configuration
// ============================================================================

@description('Enable purge protection for Key Vault.')
param enablePurgeProtection bool = true

@description('Enable vault for deployment.')
param enableVaultForDeployment bool = true

@description('Enable vault for template deployment.')
param enableVaultForTemplateDeployment bool = true

// ============================================================================
// AVM Pattern Module
// ============================================================================

module aksAzdPattern 'br/public:avm/ptn/azd/aks:0.2.0' = {
  name: '${deployment().name}-avm-aks'
  params: {
    // Identity
    name: name
    location: location
    tags: tags
    
    // Associated resources
    containerRegistryName: containerRegistryName
    keyVaultName: keyVaultName
    monitoringWorkspaceResourceId: monitoringWorkspaceResourceId
    principalId: principalId
    principalType: principalType
    
    // Kubernetes configuration
    kubernetesVersion: kubernetesVersion
    skuTier: skuTier
    systemPoolSize: systemPoolSize
    agentPoolSize: agentPoolSize
    systemPoolConfig: !empty(systemPoolConfig) ? systemPoolConfig : null
    agentPoolConfig: !empty(agentPoolConfig) ? agentPoolConfig : null
    
    // Network configuration
    networkDataplane: networkDataplane
    networkPlugin: networkPlugin
    networkPolicy: networkPolicy
    loadBalancerSku: loadBalancerSku
    serviceCidr: !empty(serviceCidr) ? serviceCidr : null
    dnsServiceIP: !empty(dnsServiceIP) ? dnsServiceIP : null
    podCidr: !empty(podCidr) ? podCidr : null
    dnsPrefix: !empty(dnsPrefix) ? dnsPrefix : null
    publicNetworkAccess: publicNetworkAccess
    
    // Security configuration
    enableRbacAuthorization: enableRbacAuthorization
    enableAzureRbac: enableAzureRbac
    disableLocalAccounts: disableLocalAccounts
    enableKeyvaultSecretsProvider: enableKeyvaultSecretsProvider
    
    // Container Registry configuration
    acrSku: acrSku
    
    // Key Vault configuration
    enablePurgeProtection: enablePurgeProtection
    enableVaultForDeployment: enableVaultForDeployment
    enableVaultForTemplateDeployment: enableVaultForTemplateDeployment
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('The name of the AKS managed cluster.')
output managedClusterName string = aksAzdPattern.outputs.?managedClusterName ?? ''

@description('The resource ID of the AKS managed cluster.')
output managedClusterResourceId string = aksAzdPattern.outputs.?managedClusterResourceId ?? ''

@description('The client ID of the AKS managed identity.')
output managedClusterClientId string = aksAzdPattern.outputs.?managedClusterClientId ?? ''

@description('The object ID of the AKS managed identity.')
output managedClusterObjectId string = aksAzdPattern.outputs.?managedClusterObjectId ?? ''

@description('The name of the Container Registry.')
output containerRegistryName string = aksAzdPattern.outputs.?containerRegistryName ?? ''

@description('The login server of the Container Registry.')
output containerRegistryLoginServer string = aksAzdPattern.outputs.?containerRegistryLoginServer ?? ''

@description('The name of the resource group.')
output resourceGroupName string = aksAzdPattern.outputs.?resourceGroupName ?? resourceGroup().name
