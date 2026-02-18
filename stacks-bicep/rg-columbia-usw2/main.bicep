targetScope = 'resourceGroup'

// ============================================================================
// Columbia Azure Virtual Desktop Stack
// Deploys 3 AVD session hosts on a VNet using Acestus wrapper modules
// ============================================================================

metadata name = 'Columbia AVD Infrastructure'
metadata description = 'Azure Virtual Desktop deployment with 3 session hosts on dedicated VNet'
metadata version = '1.0.0'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The project name, used for naming resources.')
param projectName string = 'columbia'

@description('The environment name.')
@allowed(['dev', 'tst', 'prd'])
param environment string = 'prd'

@description('The CAF location suffix.')
param CAFLocation string = 'usw2'

@description('The instance number suffix.')
param instanceNumber string = '001'

@description('Tags to be applied to all resources.')
param tags object = {}

@description('Virtual Network address space.')
param vnetAddressSpace array = ['10.86.0.0/22']

@description('AVD subnet address prefix.')
param avdSubnetPrefix string = '10.86.0.0/24'

@description('Admin username for the VMs.')
param adminUsername string = 'avdadmin'

@description('Admin password for the VMs.')
@secure()
param adminPassword string

@description('VM size for AVD session hosts.')
param vmSize string = 'Standard_D4s_v5'

@description('Enable accelerated networking on NICs (requires supported VM size).')
param enableAcceleratedNetworking bool = true

@description('Number of AVD session hosts.')
@minValue(1)
@maxValue(10)
param avdHostCount int = 3

@description('Resource ID of the Log Analytics workspace for diagnostics.')
param workspaceResourceId string = ''

@description('Enable Microsoft Entra ID login for VMs.')
param enableEntraIdLogin bool = true

@description('NSG resource ID to attach to the AVD subnet. Optional.')
param nsgResourceId string = ''

// Naming variables
var vnetName = 'vnet-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var avdSubnetName = 'snet-avd-${projectName}'

// Subnet configuration - conditionally include NSG
var subnetConfig = !empty(nsgResourceId) ? {
  name: avdSubnetName
  addressPrefix: avdSubnetPrefix
  networkSecurityGroupResourceId: nsgResourceId
  privateEndpointNetworkPolicies: 'Disabled'
  privateLinkServiceNetworkPolicies: 'Enabled'
} : {
  name: avdSubnetName
  addressPrefix: avdSubnetPrefix
  privateEndpointNetworkPolicies: 'Disabled'
  privateLinkServiceNetworkPolicies: 'Enabled'
}

// ============================================================================
// Virtual Network
// ============================================================================
module vnet 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-network:v1.1.0' = {
  name: '${deployment().name}-vnet'
  params: {
    name: vnetName
    location: location
    tags: tags
    addressPrefixes: vnetAddressSpace
    subnets: [
      subnetConfig
    ]
    diagnosticSettings: !empty(workspaceResourceId) ? [
      {
        name: 'diagnostics'
        workspaceResourceId: workspaceResourceId
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
      }
    ] : []
  }
}

// ============================================================================
// AVD Session Hosts (Virtual Machines)
// ============================================================================
// Windows computer names max 15 chars

module avdSessionHosts 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-machine:v1.1.0' = [for i in range(1, avdHostCount): {
  name: '${deployment().name}-vm-${i}'
  params: {
    name: 'vm-${projectName}-${padLeft(string(i), 3, '0')}'  // e.g., vm-columbia-001 (14 chars)
    location: location
    tags: union(tags, {
      Role: 'AVD-SessionHost'
      HostIndex: string(i)
    })
    vmSize: vmSize
    osType: 'Windows'

    imageReference: {
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'windows-11'
      sku: 'win11-23h2-avd'
      version: 'latest'
    }
    adminUsername: adminUsername
    adminPassword: adminPassword
    osDiskType: 'Premium_LRS'
    osDiskSizeGB: 128
    securityType: 'TrustedLaunch'
    secureBootEnabled: true
    vTpmEnabled: true
    enableSystemAssignedIdentity: true
    enableAutomaticUpdates: true
    patchMode: 'AutomaticByOS' 
    enableHybridBenefit: true
    nicConfigurations: [
      {
        name: 'nic-${projectName}-avd-${padLeft(string(i), 2, '0')}'
        enableAcceleratedNetworking: enableAcceleratedNetworking
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: vnet.outputs.subnetResourceIds[0]
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
  }
}]

// ============================================================================
// Microsoft Entra ID Login Extension
// ============================================================================
resource aadLoginExtension 'Microsoft.Compute/virtualMachines/extensions@2024-03-01' = [for i in range(1, avdHostCount): if (enableEntraIdLogin) {
  name: 'vm-${projectName}-${padLeft(string(i), 3, '0')}/AADLoginForWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: 'AADLoginForWindows'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    settings: {
      mdmId: ''
    }
  }
  dependsOn: [
    avdSessionHosts[i - 1]
  ]
}]

// ============================================================================
// Outputs
// ============================================================================
@description('Virtual Network resource ID')
output vnetResourceId string = vnet.outputs.resourceId

@description('Virtual Network name')
output vnetName string = vnet.outputs.name

@description('AVD Subnet resource ID')
output avdSubnetResourceId string = vnet.outputs.subnetResourceIds[0]

@description('Network Security Group resource ID')
output nsgResourceId string = nsgResourceId

@description('AVD Session Host VM resource IDs')
output avdSessionHostIds array = [for i in range(0, avdHostCount): avdSessionHosts[i].outputs.resourceId]

@description('AVD Session Host VM names')
output avdSessionHostNames array = [for i in range(0, avdHostCount): avdSessionHosts[i].outputs.name]

@description('AVD Session Host system-assigned identity principal IDs')
output avdSessionHostPrincipalIds array = [for i in range(0, avdHostCount): avdSessionHosts[i].outputs.systemAssignedMIPrincipalId]
