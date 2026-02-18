@description('Project Name used to create the VM Name')
param projectName string = 'default'

@description('Instance Number used to create the VM Name')
param instanceNumber string = '001'

@description('Username for the Virtual Machine.')
param adminUsername string = 'Acestus'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2025-datacenter-azure-edition-smalldisk'
])
param OSVersion string = '2025-datacenter-azure-edition-smalldisk'

@description('Resource ID of the subnet.')
@allowed([
  '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-usw2-001/subnets/default'
])
param SubnetID string = '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-usw2-001/subnets/default'

var location = resourceGroup().location
var cafName = '${projectName}-usw2-${instanceNumber}'
var vmName = 'vm-${cafName}'
var VMSize = 'Standard_B2s'
var nicName = 'nic-${cafName}'
var shortComputerName = 'vm-${projectName}-${instanceNumber}'
var osDiskName = 'disk-${cafName}'
var storageAccountName = 'stnettoolsusw2001'
var storageUri = 'https://${storageAccountName}.blob.${environment().suffixes.storage}'

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: SubnetID
          }
        }
      }
    ]
  }
}


resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: shortComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: osDiskName
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageUri
      }
    }
  }
}

resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  dependsOn: [
    VM
  ]
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'Central Standard Time'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 15
    }
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', vmName)
  }
}

