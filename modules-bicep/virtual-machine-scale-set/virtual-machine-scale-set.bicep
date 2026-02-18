// Opinionated Virtual Machine Scale Set module following Acestus standards

metadata name = 'Acestus Virtual Machine Scale Set'
metadata description = 'VMSS module with Acestus security standards'
metadata version = '1.0.0'

@description('Name of the virtual machine scale set')
param name string

@description('Location for the VMSS')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('SKU name (VM size)')
param skuName string = 'Standard_D2s_v5'

@description('Initial instance count')
@minValue(0)
@maxValue(1000)
param capacity int = 2

@description('Availability zones')
param zones array = ['1', '2', '3']

@description('Upgrade policy mode')
@allowed([
  'Automatic'
  'Manual'
  'Rolling'
])
param upgradeMode string = 'Rolling'

@description('Enable automatic OS upgrades')
param enableAutomaticOSUpgrade bool = true

@description('OS disk type')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
])
param osDiskType string = 'Premium_ZRS'

@description('OS disk size in GB')
param osDiskSizeGB int = 128

@description('OS disk caching')
@allowed([
  'None'
  'ReadOnly'
  'ReadWrite'
])
param osDiskCaching string = 'ReadWrite'

@description('Image reference publisher')
param imagePublisher string = 'Canonical'

@description('Image reference offer')
param imageOffer string = '0001-com-ubuntu-server-jammy'

@description('Image reference SKU')
param imageSku string = '22_04-lts-gen2'

@description('Image reference version')
param imageVersion string = 'latest'

@description('Admin username')
param adminUsername string

@description('Admin password (for Windows or if SSH not used)')
@secure()
param adminPassword string = ''

@description('SSH public key for Linux VMs')
param sshPublicKey string = ''

@description('Subnet resource ID')
param subnetId string

@description('Enable public IP per instance')
param enablePublicIP bool = false

@description('Load balancer backend address pool IDs')
param loadBalancerBackendAddressPoolIds array = []

@description('Application gateway backend address pool IDs')
param applicationGatewayBackendAddressPoolIds array = []

@description('Application security group IDs')
param applicationSecurityGroupIds array = []

@description('User assigned identity resource IDs')
param userAssignedIdentityIds array = []

@description('Enable system assigned identity')
param enableSystemAssignedIdentity bool = false

@description('Enable boot diagnostics')
param enableBootDiagnostics bool = true

@description('Boot diagnostics storage account URI')
param bootDiagnosticsStorageUri string = ''

@description('Custom data (cloud-init) - base64 encoded')
param customData string = ''

@description('Data disks configuration')
param dataDisks array = []

@description('Enable encryption at host')
param encryptionAtHost bool = true

@description('OS type')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Rolling upgrade policy')
param rollingUpgradePolicy object = {
  maxBatchInstancePercent: 20
  maxUnhealthyInstancePercent: 20
  maxUnhealthyUpgradedInstancePercent: 20
  pauseTimeBetweenBatches: 'PT0S'
}

@description('Scale-in policy rules')
@allowed([
  'Default'
  'NewestVM'
  'OldestVM'
])
param scaleInPolicyRules string = 'Default'

@description('Overprovision VMs')
param overprovision bool = false

@description('Enable single placement group')
param singlePlacementGroup bool = false

@description('Platform fault domain count')
param platformFaultDomainCount int = 1

// Build identity configuration
var identityType = enableSystemAssignedIdentity ? (!empty(userAssignedIdentityIds) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentityIds) ? 'UserAssigned' : 'None')

var userAssignedIdentities = !empty(userAssignedIdentityIds) ? reduce(userAssignedIdentityIds, {}, (cur, next) => union(cur, { '${next}': {} })) : null

// Pre-build pool arrays as objects with id property
var lbPools = [for poolId in loadBalancerBackendAddressPoolIds: { id: poolId }]
var appGwPools = [for poolId in applicationGatewayBackendAddressPoolIds: { id: poolId }]
var asgList = [for asgId in applicationSecurityGroupIds: { id: asgId }]

// Build network interface configuration
var ipConfigurations = [
  {
    name: 'ipconfig1'
    properties: {
      primary: true
      subnet: {
        id: subnetId
      }
      publicIPAddressConfiguration: enablePublicIP ? {
        name: 'pip'
        properties: {
          idleTimeoutInMinutes: 15
        }
      } : null
      loadBalancerBackendAddressPools: lbPools
      applicationGatewayBackendAddressPools: appGwPools
      applicationSecurityGroups: asgList
    }
  }
]

// Build Linux configuration
var linuxConfiguration = osType == 'Linux' ? {
  disablePasswordAuthentication: !empty(sshPublicKey)
  ssh: !empty(sshPublicKey) ? {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ]
  } : null
} : null

// Build Windows configuration
var windowsConfiguration = osType == 'Windows' ? {
  enableAutomaticUpdates: true
  provisionVMAgent: true
  patchSettings: {
    patchMode: 'AutomaticByPlatform'
    automaticByPlatformSettings: {
      rebootSetting: 'IfRequired'
    }
  }
} : null

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: 'Standard'
    capacity: capacity
  }
  zones: !empty(zones) ? zones : null
  identity: identityType != 'None' ? {
    type: identityType
    userAssignedIdentities: userAssignedIdentities
  } : null
  properties: {
    overprovision: overprovision
    singlePlacementGroup: singlePlacementGroup
    platformFaultDomainCount: platformFaultDomainCount
    upgradePolicy: {
      mode: upgradeMode
      automaticOSUpgradePolicy: upgradeMode != 'Manual' ? {
        enableAutomaticOSUpgrade: enableAutomaticOSUpgrade
        disableAutomaticRollback: false
      } : null
      rollingUpgradePolicy: upgradeMode == 'Rolling' ? rollingUpgradePolicy : null
    }
    scaleInPolicy: {
      rules: [scaleInPolicyRules]
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: take(name, 9)
        adminUsername: adminUsername
        adminPassword: !empty(adminPassword) ? adminPassword : null
        customData: !empty(customData) ? customData : null
        linuxConfiguration: linuxConfiguration
        windowsConfiguration: windowsConfiguration
      }
      storageProfile: {
        imageReference: {
          publisher: imagePublisher
          offer: imageOffer
          sku: imageSku
          version: imageVersion
        }
        osDisk: {
          createOption: 'FromImage'
          caching: osDiskCaching
          diskSizeGB: osDiskSizeGB
          managedDisk: {
            storageAccountType: osDiskType
          }
        }
        dataDisks: [for (disk, i) in dataDisks: {
          lun: i
          createOption: 'Empty'
          diskSizeGB: disk.sizeGB
          caching: disk.?caching ?? 'ReadOnly'
          managedDisk: {
            storageAccountType: disk.?storageAccountType ?? 'Premium_ZRS'
          }
        }]
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${name}-nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              ipConfigurations: ipConfigurations
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: enableBootDiagnostics
          storageUri: !empty(bootDiagnosticsStorageUri) ? bootDiagnosticsStorageUri : null
        }
      }
      securityProfile: {
        encryptionAtHost: encryptionAtHost
      }
    }
  }
}

@description('The resource ID of the VMSS')
output resourceId string = vmss.id

@description('The name of the VMSS')
output name string = vmss.name

@description('The principal ID of the system assigned identity')
output systemAssignedMIPrincipalId string = vmss.identity.?principalId ?? ''
