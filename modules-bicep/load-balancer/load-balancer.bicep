// Opinionated load balancer module following Acestus standards

metadata name = 'Acestus Load Balancer'
metadata description = 'Load Balancer module with Acestus networking standards'
metadata version = '1.0.0'

@description('Name of the load balancer')
param name string

@description('Location for the load balancer')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('SKU name for the load balancer')
@allowed([
  'Basic'
  'Standard'
  'Gateway'
])
param skuName string = 'Standard'

@description('SKU tier for the load balancer')
@allowed([
  'Regional'
  'Global'
])
param skuTier string = 'Regional'

@description('Frontend IP configurations')
param frontendIPConfigurations array = []

@description('Backend address pools')
param backendAddressPools array = []

@description('Load balancing rules')
param loadBalancingRules array = []

@description('Health probes')
param probes array = []

@description('Inbound NAT rules')
param inboundNatRules array = []

@description('Inbound NAT pools')
param inboundNatPools array = []

@description('Outbound rules')
param outboundRules array = []

resource loadBalancer 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    frontendIPConfigurations: [for config in frontendIPConfigurations: {
      name: config.name
      zones: config.?zones ?? null
      properties: {
        privateIPAddress: config.?privateIPAddress ?? null
        privateIPAddressVersion: config.?privateIPAddressVersion ?? 'IPv4'
        privateIPAllocationMethod: config.?privateIPAllocationMethod ?? 'Dynamic'
        publicIPAddress: !empty(config.?publicIPAddressId ?? '') ? {
          id: config.publicIPAddressId
        } : null
        subnet: !empty(config.?subnetId ?? '') ? {
          id: config.subnetId
        } : null
      }
    }]
    backendAddressPools: [for pool in backendAddressPools: {
      name: pool.name
    }]
    loadBalancingRules: [for rule in loadBalancingRules: {
      name: rule.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, rule.frontendIPConfigurationName)
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, rule.backendAddressPoolName)
        }
        probe: !empty(rule.?probeName ?? '') ? {
          id: resourceId('Microsoft.Network/loadBalancers/probes', name, rule.probeName)
        } : null
        protocol: rule.protocol
        frontendPort: rule.frontendPort
        backendPort: rule.backendPort
        idleTimeoutInMinutes: rule.?idleTimeoutInMinutes ?? 4
        enableFloatingIP: rule.?enableFloatingIP ?? false
        enableTcpReset: rule.?enableTcpReset ?? true
        disableOutboundSnat: rule.?disableOutboundSnat ?? false
        loadDistribution: rule.?loadDistribution ?? 'Default'
      }
    }]
    probes: [for probe in probes: {
      name: probe.name
      properties: {
        protocol: probe.protocol
        port: probe.port
        requestPath: probe.?requestPath ?? null
        intervalInSeconds: probe.?intervalInSeconds ?? 5
        numberOfProbes: probe.?numberOfProbes ?? 2
        probeThreshold: probe.?probeThreshold ?? 1
      }
    }]
    inboundNatRules: [for rule in inboundNatRules: {
      name: rule.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, rule.frontendIPConfigurationName)
        }
        protocol: rule.protocol
        frontendPort: rule.frontendPort
        backendPort: rule.backendPort
        idleTimeoutInMinutes: rule.?idleTimeoutInMinutes ?? 4
        enableFloatingIP: rule.?enableFloatingIP ?? false
        enableTcpReset: rule.?enableTcpReset ?? true
      }
    }]
    inboundNatPools: inboundNatPools
    outboundRules: [for rule in outboundRules: {
      name: rule.name
      properties: {
        frontendIPConfigurations: rule.frontendIPConfigurations
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, rule.backendAddressPoolName)
        }
        protocol: rule.?protocol ?? 'All'
        allocatedOutboundPorts: rule.?allocatedOutboundPorts ?? 0
        idleTimeoutInMinutes: rule.?idleTimeoutInMinutes ?? 4
        enableTcpReset: rule.?enableTcpReset ?? true
      }
    }]
  }
}

@description('The resource ID of the load balancer')
output resourceId string = loadBalancer.id

@description('The name of the load balancer')
output name string = loadBalancer.name

@description('The backend address pool resource IDs')
output backendAddressPoolIds array = [for (pool, i) in backendAddressPools: loadBalancer.properties.backendAddressPools[i].id]

@description('The frontend IP configuration resource IDs')
output frontendIPConfigurationIds array = [for (config, i) in frontendIPConfigurations: loadBalancer.properties.frontendIPConfigurations[i].id]
