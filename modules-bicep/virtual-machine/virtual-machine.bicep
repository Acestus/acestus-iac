// Opinionated Azure Virtual Machine module following Acestus standards and security best practices

metadata name = 'Acestus Virtual Machine'
metadata description = 'Custom Virtual Machine module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Virtual Machine name')
param name string

@description('Location for the Virtual Machine')
param location string = resourceGroup().location

@description('Tags to apply to the Virtual Machine')
param tags object = {}

@description('Virtual Machine size')
param vmSize string = 'Standard_D2s_v5'

@description('OS type')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'

@description('Image reference for the Virtual Machine')
param imageReference object = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

@description('Admin username for the Virtual Machine')
param adminUsername string = 'azureadmin'

@description('Admin password for the Virtual Machine (required for Windows, optional for Linux with SSH)')
@secure()
param adminPassword string = ''

@description('SSH public key for Linux VMs')
@secure()
param sshPublicKey string = ''

@description('Disable password authentication for Linux VMs')
param disablePasswordAuthentication bool = true

@description('OS disk type')
@allowed([
  'Standard_LRS'
  'StandardSSD_LRS'
  'Premium_LRS'
  'StandardSSD_ZRS'
  'Premium_ZRS'
])
param osDiskType string = 'Premium_LRS'

@description('OS disk size in GB (0 for default)')
param osDiskSizeGB int = 0

@description('Delete OS disk on VM deletion')
param osDiskDeleteOption string = 'Delete'

@description('Data disks to attach')
param dataDisks array = []

@description('Availability Zone (-1 for no zone, 1-3 for specific zone)')
param availabilityZone int = -1

@description('Availability Set resource ID')
param availabilitySetResourceId string = ''

@description('Network interface configurations')
param nicConfigurations array

@description('Enable system-assigned managed identity')
param enableSystemAssignedIdentity bool = true

@description('User-assigned identity resource IDs')
param userAssignedIdentities array = []

@description('Boot diagnostics storage account URI (empty to disable)')
param bootDiagnosticStorageAccountUri string = ''

@description('Enable boot diagnostics with managed storage')
param bootDiagnosticsEnabled bool = true

@description('Enable encryption at host')
param encryptionAtHost bool = false

@description('Enable secure boot (requires Gen2 VM)')
param secureBootEnabled bool = true

@description('Enable vTPM (requires Gen2 VM)')
param vTpmEnabled bool = true

@description('Security type for the VM')
@allowed([
  ''
  'TrustedLaunch'
  'ConfidentialVM'
])
param securityType string = 'TrustedLaunch'

@description('Enable Azure Hybrid Benefit for Windows VMs')
param enableHybridBenefit bool = false

@description('Enable automatic updates (Windows only)')
param enableAutomaticUpdates bool = true

@description('Patch mode for the VM')
@allowed([
  'AutomaticByPlatform'
  'AutomaticByOS'
  'Manual'
  'ImageDefault'
])
param patchMode string = 'AutomaticByPlatform'

@description('Enable VM agent')
param provisionVMAgent bool = true

@description('Lock settings for the Virtual Machine')
param lock object = {}

@description('Role assignments for the Virtual Machine')
param roleAssignments array = []

// Build managed identities object
var managedIdentitiesConfig = {
  systemAssigned: enableSystemAssignedIdentity
  userAssignedResourceIds: userAssignedIdentities
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.21.0' = {
  name: '${deployment().name}-vm'
  params: {
    name: name
    location: location
    tags: tags
    vmSize: vmSize
    osType: osType
    imageReference: imageReference
    adminUsername: adminUsername
    adminPassword: !empty(adminPassword) ? adminPassword : null
    disablePasswordAuthentication: osType == 'Linux' ? disablePasswordAuthentication : false
    publicKeys: osType == 'Linux' && !empty(sshPublicKey) ? [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ] : []
    osDisk: {
      diskSizeGB: osDiskSizeGB > 0 ? osDiskSizeGB : null
      managedDisk: {
        storageAccountType: osDiskType
      }
      deleteOption: osDiskDeleteOption
      caching: 'ReadWrite'
      createOption: 'FromImage'
    }
    dataDisks: dataDisks
    availabilityZone: availabilityZone
    availabilitySetResourceId: !empty(availabilitySetResourceId) ? availabilitySetResourceId : null
    nicConfigurations: nicConfigurations
    managedIdentities: managedIdentitiesConfig
    bootDiagnostics: bootDiagnosticsEnabled
    bootDiagnosticStorageAccountUri: !empty(bootDiagnosticStorageAccountUri) ? bootDiagnosticStorageAccountUri : ''
    encryptionAtHost: encryptionAtHost
    secureBootEnabled: securityType != '' ? secureBootEnabled : false
    vTpmEnabled: securityType != '' ? vTpmEnabled : false
    securityType: !empty(securityType) ? securityType : null
    licenseType: osType == 'Windows' && enableHybridBenefit ? 'Windows_Server' : null
    enableAutomaticUpdates: osType == 'Windows' ? enableAutomaticUpdates : null
    patchMode: patchMode
    provisionVMAgent: provisionVMAgent
    lock: !empty(lock) ? lock : null
    roleAssignments: roleAssignments
  }
}

// Outputs
@description('The resource ID of the Virtual Machine')
output resourceId string = virtualMachine.outputs.resourceId

@description('The name of the Virtual Machine')
output name string = virtualMachine.outputs.name

@description('The resource group the Virtual Machine was deployed into')
output resourceGroupName string = virtualMachine.outputs.resourceGroupName

@description('The location the Virtual Machine was deployed into')
output location string = virtualMachine.outputs.location

@description('The principal ID of the system-assigned managed identity')
output systemAssignedMIPrincipalId string = virtualMachine.outputs.systemAssignedMIPrincipalId

@description('All outputs from the AVM Virtual Machine module')
output virtualMachine object = virtualMachine.outputs
