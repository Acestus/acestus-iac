// Opinionated application gateway module following Acestus standards

metadata name = 'Acestus Application Gateway'
metadata description = 'Application Gateway module with Acestus security defaults'
metadata version = '1.0.0'

@description('Name of the application gateway')
param name string

@description('Location for the application gateway')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('SKU name for the application gateway')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param skuName string = 'WAF_v2'

@description('Tier for the application gateway')
@allowed([
  'Standard_v2'
  'WAF_v2'
])
param tier string = 'WAF_v2'

@description('Capacity (instance count) for the application gateway')
@minValue(1)
@maxValue(125)
param capacity int = 2

@description('Enable autoscaling')
param enableAutoscaling bool = true

@description('Minimum capacity for autoscaling')
@minValue(0)
@maxValue(125)
param minCapacity int = 1

@description('Maximum capacity for autoscaling')
@minValue(1)
@maxValue(125)
param maxCapacity int = 10

@description('Availability zones')
param zones array = ['1', '2', '3']

@description('Subnet resource ID for the application gateway')
param subnetId string

@description('Public IP address resource ID')
param publicIpAddressId string = ''

@description('Private IP address for frontend')
param privateIpAddress string = ''

@description('WAF policy resource ID')
param firewallPolicyId string = ''

@description('Enable HTTP/2')
param enableHttp2 bool = true

@description('Frontend ports configuration')
param frontendPorts array = [
  {
    name: 'port_80'
    port: 80
  }
  {
    name: 'port_443'
    port: 443
  }
]

@description('Backend address pools configuration')
param backendAddressPools array = []

@description('Backend HTTP settings configuration')
param backendHttpSettingsCollection array = []

@description('HTTP listeners configuration')
param httpListeners array = []

@description('Request routing rules configuration')
param requestRoutingRules array = []

@description('SSL certificates configuration')
param sslCertificates array = []

@description('Trusted root certificates configuration')
param trustedRootCertificates array = []

@description('Health probes configuration')
param probes array = []

@description('SSL policy configuration')
param sslPolicy object = {
  policyType: 'Predefined'
  policyName: 'AppGwSslPolicy20220101S'
}

@description('User assigned identity resource ID for Key Vault access')
param userAssignedIdentityId string = ''

// Build frontend IP configurations
var frontendIPConfigurations = concat(
  !empty(publicIpAddressId) ? [{
    name: 'appGwPublicFrontendIp'
    properties: {
      publicIPAddress: {
        id: publicIpAddressId
      }
    }
  }] : [],
  !empty(privateIpAddress) ? [{
    name: 'appGwPrivateFrontendIp'
    properties: {
      privateIPAddress: privateIpAddress
      privateIPAllocationMethod: 'Static'
      subnet: {
        id: subnetId
      }
    }
  }] : []
)

// Build gateway IP configuration
var gatewayIPConfigurations = [
  {
    name: 'appGwIpConfig'
    properties: {
      subnet: {
        id: subnetId
      }
    }
  }
]

// Build SKU configuration
var sku = enableAutoscaling ? {
  name: skuName
  tier: tier
} : {
  name: skuName
  tier: tier
  capacity: capacity
}

// Build autoscale configuration
var autoscaleConfiguration = enableAutoscaling ? {
  minCapacity: minCapacity
  maxCapacity: maxCapacity
} : null

resource applicationGateway 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: name
  location: location
  tags: tags
  zones: !empty(zones) ? zones : null
  identity: !empty(userAssignedIdentityId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  } : null
  properties: {
    sku: sku
    autoscaleConfiguration: autoscaleConfiguration
    gatewayIPConfigurations: gatewayIPConfigurations
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: [for port in frontendPorts: {
      name: port.name
      properties: {
        port: port.port
      }
    }]
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
    sslCertificates: sslCertificates
    trustedRootCertificates: trustedRootCertificates
    probes: probes
    sslPolicy: sslPolicy
    enableHttp2: enableHttp2
    firewallPolicy: !empty(firewallPolicyId) ? {
      id: firewallPolicyId
    } : null
  }
}

@description('The resource ID of the application gateway')
output resourceId string = applicationGateway.id

@description('The name of the application gateway')
output name string = applicationGateway.name
