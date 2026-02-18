@description('Project Name used to create the VM Name')
param projectName string = 'nettools'

@description('Instance Number used to create the VM Name')
param instanceNumber string = '001'

@description('Username for the Virtual Machine.')
param adminUsername string = 'afuqua'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Resource ID of the subnet.')
param SubnetID string = '/subscriptions/<subscription-id>/resourceGroups/rg-qa-Acestus-usw2-001/providers/Microsoft.Network/virtualNetworks/vnet-qa-Acestus-usw2-001/subnets/snet-qa-Acestus-usw2-001-bastion'

var location = resourceGroup().location
var cafName = '${projectName}-usw2-${instanceNumber}'
var VMSize = 'Standard_B2s'
var osDiskName = 'osdisk-${cafName}'
var nicName = 'nic-${cafName}'
var shortComputerName = 'vm-${projectName}-${instanceNumber}'

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
  name: shortComputerName
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
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'fromImage'
        name: osDiskName
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
      }
    }
  }
}

resource vmName_installNetTools 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  parent: VM
  name: 'installNetTools'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: []
      commandToExecute: 'apt-get update && apt-get install -y nmap net-tools traceroute'
    }
  }
}

resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${shortComputerName}'
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
    targetResourceId: resourceId('Microsoft.Compute/virtualMachines', shortComputerName)
  }
}

