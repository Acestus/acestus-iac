// Opinionated network security group module following Acestus standards

metadata name = 'Acestus Network Security Group'
metadata description = 'NSG module with Acestus security defaults'
metadata version = '1.0.0'

@description('Name of the network security group')
param name string

@description('Location for the NSG')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Security rules to create')
param securityRules array = []

@description('Enable flow logs for this NSG')
param enableFlowLogs bool = false

@description('Flow log storage account resource ID')
param flowLogStorageAccountId string = ''

@description('Network Watcher name for flow logs')
param networkWatcherName string = ''

@description('Network Watcher resource group for flow logs')
param networkWatcherResourceGroup string = ''

@description('Flow log retention days')
@minValue(1)
@maxValue(365)
param flowLogRetentionDays int = 30

@description('Enable traffic analytics')
param enableTrafficAnalytics bool = false

@description('Log Analytics workspace resource ID for traffic analytics')
param logAnalyticsWorkspaceId string = ''

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        description: rule.?description ?? ''
        protocol: rule.protocol
        sourcePortRange: rule.?sourcePortRange ?? '*'
        sourcePortRanges: rule.?sourcePortRanges ?? []
        destinationPortRange: rule.?destinationPortRange ?? '*'
        destinationPortRanges: rule.?destinationPortRanges ?? []
        sourceAddressPrefix: rule.?sourceAddressPrefix ?? ''
        sourceAddressPrefixes: rule.?sourceAddressPrefixes ?? []
        destinationAddressPrefix: rule.?destinationAddressPrefix ?? ''
        destinationAddressPrefixes: rule.?destinationAddressPrefixes ?? []
        sourceApplicationSecurityGroups: rule.?sourceApplicationSecurityGroups ?? []
        destinationApplicationSecurityGroups: rule.?destinationApplicationSecurityGroups ?? []
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
}

// Flow log resource (deployed to Network Watcher resource group)
module flowLog 'br/public:avm/res/network/network-watcher:0.5.0' = if (enableFlowLogs && !empty(flowLogStorageAccountId)) {
  name: '${name}-flowlog-deploy'
  scope: resourceGroup(networkWatcherResourceGroup)
  params: {
    name: networkWatcherName
    location: location
    flowLogs: [
      {
        name: '${name}-flowlog'
        enabled: true
        targetResourceId: networkSecurityGroup.id
        storageId: flowLogStorageAccountId
        retentionPolicy: {
          days: flowLogRetentionDays
          enabled: true
        }
        flowAnalyticsConfiguration: enableTrafficAnalytics && !empty(logAnalyticsWorkspaceId) ? {
          networkWatcherFlowAnalyticsConfiguration: {
            enabled: true
            workspaceResourceId: logAnalyticsWorkspaceId
            trafficAnalyticsInterval: 10
          }
        } : null
      }
    ]
  }
}

@description('The resource ID of the NSG')
output resourceId string = networkSecurityGroup.id

@description('The name of the NSG')
output name string = networkSecurityGroup.name

@description('The default security rules')
output defaultSecurityRules array = networkSecurityGroup.properties.defaultSecurityRules
