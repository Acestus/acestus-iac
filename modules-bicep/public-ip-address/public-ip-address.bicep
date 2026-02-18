// Opinionated public IP address module following Acestus standards

metadata name = 'Acestus Public IP Address'
metadata description = 'Public IP address module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Name of the public IP address')
param name string

@description('Location for the public IP address')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('SKU name for the public IP address')
@allowed([
  'Basic'
  'Standard'
])
param skuName string = 'Standard'

@description('SKU tier for the public IP address')
@allowed([
  'Regional'
  'Global'
])
param skuTier string = 'Regional'

@description('Allocation method for the public IP address')
@allowed([
  'Static'
  'Dynamic'
])
param allocationMethod string = 'Static'

@description('IP address version')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string = 'IPv4'

@description('DNS domain name label for the public IP')
param domainNameLabel string = ''

@description('Idle timeout in minutes')
@minValue(4)
@maxValue(30)
param idleTimeoutInMinutes int = 4

@description('Availability zones for the public IP')
param zones array = []

@description('Enable DDoS protection')
param ddosProtectionMode string = 'VirtualNetworkInherited'

@description('DDoS protection plan resource ID (required if ddosProtectionMode is Enabled)')
param ddosProtectionPlanId string = ''

// Build DNS settings if domain name label is provided
var dnsSettings = !empty(domainNameLabel) ? {
  domainNameLabel: domainNameLabel
} : null

// Build DDoS settings
var ddosSettings = ddosProtectionMode == 'Enabled' && !empty(ddosProtectionPlanId) ? {
  protectionMode: ddosProtectionMode
  ddosProtectionPlan: {
    id: ddosProtectionPlanId
  }
} : {
  protectionMode: ddosProtectionMode
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  zones: !empty(zones) ? zones : null
  properties: {
    publicIPAllocationMethod: allocationMethod
    publicIPAddressVersion: publicIPAddressVersion
    idleTimeoutInMinutes: idleTimeoutInMinutes
    dnsSettings: dnsSettings
    ddosSettings: ddosSettings
  }
}

@description('The resource ID of the public IP address')
output resourceId string = publicIPAddress.id

@description('The name of the public IP address')
output name string = publicIPAddress.name

@description('The IP address')
output ipAddress string = publicIPAddress.properties.ipAddress ?? ''

@description('The FQDN of the public IP address')
output fqdn string = publicIPAddress.properties.dnsSettings.?fqdn ?? ''
