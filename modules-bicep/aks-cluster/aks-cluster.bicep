// Opinionated AKS Managed Cluster module following Acestus standards and security best practices

metadata name = 'Acestus AKS Managed Cluster'
metadata description = 'Custom AKS Managed Cluster module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('AKS cluster name')
param name string

@description('Location for the AKS cluster')
param location string = resourceGroup().location

@description('Tags to apply to the AKS cluster')
param tags object = {}

@description('Kubernetes version')
param kubernetesVersion string = '1.29'

@description('DNS prefix for the cluster')
param dnsPrefix string = name

@description('System node pool configuration')
param primaryAgentPoolProfiles array = [
  {
    name: 'system'
    count: 3
    vmSize: 'Standard_D4s_v5'
    osDiskSizeGB: 128
    osDiskType: 'Managed'
    osType: 'Linux'
    mode: 'System'
    enableAutoScaling: true
    minCount: 2
    maxCount: 5
    availabilityZones: ['1', '2', '3']
    maxPods: 30
    nodeTaints: ['CriticalAddonsOnly=true:NoSchedule']
  }
]

@description('User node pools configuration')
param agentPools array = []

@description('Enable Azure RBAC for Kubernetes authorization')
param enableAzureRBAC bool = true

@description('Enable Azure AD integration')
param enableAadAuthentication bool = true

@description('Azure AD admin group object IDs')
param aadAdminGroupObjectIds array = []

@description('Disable local accounts')
param disableLocalAccounts bool = true

@description('Enable managed identity')
param enableSystemAssignedIdentity bool = true

@description('User-assigned identity resource ID for the cluster')
param userAssignedIdentityResourceId string = ''

@description('Network plugin')
@allowed([
  'azure'
  'kubenet'
  'none'
])
param networkPlugin string = 'azure'

@description('Network plugin mode for Azure CNI')
@allowed([
  ''
  'overlay'
])
param networkPluginMode string = 'overlay'

@description('Network policy')
@allowed([
  ''
  'azure'
  'calico'
  'cilium'
])
param networkPolicy string = 'azure'

@description('Network dataplane (for Cilium)')
@allowed([
  ''
  'azure'
  'cilium'
])
param networkDataplane string = ''

@description('Service CIDR')
param serviceCidr string = '10.0.0.0/16'

@description('DNS service IP (must be within service CIDR)')
param dnsServiceIP string = '10.0.0.10'

@description('Pod CIDR (required for kubenet or overlay)')
param podCidr string = '10.244.0.0/16'

@description('Outbound type')
@allowed([
  'loadBalancer'
  'managedNATGateway'
  'userAssignedNATGateway'
  'userDefinedRouting'
])
param outboundType string = 'loadBalancer'

@description('Load balancer SKU')
@allowed([
  'basic'
  'standard'
])
param loadBalancerSku string = 'standard'

@description('Subnet resource ID for the default node pool')
param subnetResourceId string = ''

@description('Private cluster enabled')
param enablePrivateCluster bool = false

@description('Private DNS zone resource ID (for private clusters)')
param privateDNSZoneResourceId string = ''

@description('Enable private cluster public FQDN')
param enablePrivateClusterPublicFQDN bool = false

@description('SKU tier')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

@description('Enable auto-upgrade')
param enableAutoUpgrade bool = true

@description('Auto-upgrade channel')
@allowed([
  'none'
  'patch'
  'rapid'
  'stable'
  'node-image'
])
param autoUpgradeChannel string = 'stable'

@description('Enable Container Insights')
param enableContainerInsights bool = true

@description('Log Analytics workspace resource ID for monitoring')
param monitoringWorkspaceResourceId string = ''

@description('Enable Azure Key Vault secrets provider')
param enableKeyvaultSecretsProvider bool = true

@description('Enable secret rotation')
param enableSecretRotation bool = true

@description('Enable HTTP application routing (not for production)')
param httpApplicationRoutingEnabled bool = false

@description('Enable ingress application gateway (AGIC)')
param ingressApplicationGatewayEnabled bool = false

@description('Application Gateway resource ID for AGIC')
param appGatewayResourceId string = ''

@description('Enable Azure Policy')
param enableAzurePolicy bool = true

@description('Enable OIDC issuer')
param enableOidcIssuer bool = true

@description('Enable workload identity')
param enableWorkloadIdentity bool = true

@description('Diagnostic settings')
param diagnosticSettings array = []

@description('Lock settings')
param lock object = {}

@description('Role assignments')
param roleAssignments array = []

// Build agent pool profiles with subnet
var systemPoolsWithSubnet = [for pool in primaryAgentPoolProfiles: union(pool, {
  vnetSubnetResourceId: !empty(subnetResourceId) ? subnetResourceId : null
})]

var userPoolsWithSubnet = [for pool in agentPools: union(pool, {
  vnetSubnetResourceId: !empty(subnetResourceId) ? subnetResourceId : null
})]

// Build AAD profile
var aadProfileConfig = enableAadAuthentication ? {
  managed: true
  enableAzureRBAC: enableAzureRBAC
  adminGroupObjectIDs: aadAdminGroupObjectIds
} : null

// Build API server access profile for private cluster
var apiServerAccessProfileConfig = enablePrivateCluster ? {
  enablePrivateCluster: true
  enablePrivateClusterPublicFQDN: enablePrivateClusterPublicFQDN
  privateDNSZone: !empty(privateDNSZoneResourceId) ? privateDNSZoneResourceId : 'system'
} : null

// Build auto-upgrade profile
var autoUpgradeProfileConfig = enableAutoUpgrade ? {
  upgradeChannel: autoUpgradeChannel
} : null

// Build security profile
var securityProfileConfig = {
  workloadIdentity: enableWorkloadIdentity ? {
    enabled: true
  } : null
}

module aksCluster 'br/public:avm/res/container-service/managed-cluster:0.12.0' = {
  name: '${deployment().name}-aks'
  params: {
    name: name
    location: location
    tags: tags
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    
    // Node pools
    primaryAgentPoolProfiles: systemPoolsWithSubnet
    agentPools: userPoolsWithSubnet
    
    // Identity
    managedIdentities: {
      systemAssigned: enableSystemAssignedIdentity && empty(userAssignedIdentityResourceId)
      userAssignedResourceIds: !empty(userAssignedIdentityResourceId) ? [userAssignedIdentityResourceId] : []
    }
    
    // Azure AD and RBAC
    enableRBAC: true
    aadProfile: aadProfileConfig
    disableLocalAccounts: disableLocalAccounts
    
    // Network configuration
    networkPlugin: networkPlugin
    networkPluginMode: !empty(networkPluginMode) ? networkPluginMode : null
    networkPolicy: !empty(networkPolicy) ? networkPolicy : null
    networkDataplane: !empty(networkDataplane) ? networkDataplane : null
    serviceCidr: serviceCidr
    dnsServiceIP: dnsServiceIP
    podCidr: networkPlugin == 'kubenet' || networkPluginMode == 'overlay' ? podCidr : null
    outboundType: outboundType
    loadBalancerSku: loadBalancerSku
    
    // Private cluster
    apiServerAccessProfile: apiServerAccessProfileConfig
    
    // SKU and upgrades
    skuTier: skuTier
    autoUpgradeProfile: autoUpgradeProfileConfig
    
    // Monitoring
    omsAgentEnabled: enableContainerInsights
    monitoringWorkspaceResourceId: enableContainerInsights && !empty(monitoringWorkspaceResourceId) ? monitoringWorkspaceResourceId : null
    
    // Add-ons
    enableKeyvaultSecretsProvider: enableKeyvaultSecretsProvider
    enableSecretRotation: enableSecretRotation
    httpApplicationRoutingEnabled: httpApplicationRoutingEnabled
    ingressApplicationGatewayEnabled: ingressApplicationGatewayEnabled
    appGatewayResourceId: ingressApplicationGatewayEnabled && !empty(appGatewayResourceId) ? appGatewayResourceId : null
    azurePolicyEnabled: enableAzurePolicy
    enableOidcIssuerProfile: enableOidcIssuer
    securityProfile: securityProfileConfig
    
    // Diagnostics
    diagnosticSettings: diagnosticSettings
    
    // Lock and RBAC
    lock: !empty(lock) ? lock : null
    roleAssignments: roleAssignments
  }
}

// Outputs
@description('The resource ID of the AKS cluster')
output resourceId string = aksCluster.outputs.resourceId

@description('The name of the AKS cluster')
output name string = aksCluster.outputs.name

@description('The resource group the AKS cluster was deployed into')
output resourceGroupName string = aksCluster.outputs.resourceGroupName

@description('The location the AKS cluster was deployed into')
output location string = aksCluster.outputs.location

@description('The control plane FQDN of the AKS cluster')
output controlPlaneFQDN string = aksCluster.outputs.controlPlaneFQDN

@description('The kubelet identity object ID')
output kubeletIdentityObjectId string = aksCluster.outputs.kubeletIdentityObjectId

@description('The kubelet identity client ID')
output kubeletIdentityClientId string = aksCluster.outputs.kubeletIdentityClientId

@description('The OIDC issuer URL')
output oidcIssuerUrl string = aksCluster.outputs.oidcIssuerUrl

@description('The principal ID of the system-assigned managed identity')
output systemAssignedMIPrincipalId string = aksCluster.outputs.systemAssignedMIPrincipalId

@description('All outputs from the AVM AKS module')
output aksCluster object = aksCluster.outputs
