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
  '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-uks-001/subnets/default'
])
param SubnetID string = '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-uks-001/subnets/default'

var location = resourceGroup().location
var projectName = 'nettools'
var subscriptionName = 'SBX-510-Infrastructure'
var workloadName1 = substring(subscriptionName, 0, indexOf(subscriptionName, '-'))
var workloadName2 = substring(subscriptionName, 4, indexOf(subscriptionName, '-'))
var workloadName = concat(workloadName1, workloadName2)
var uniqueNumbers = substring(uniqueString(resourceGroup().id, deployment().name), 0, 3)
var vmName = 'vm-${projectName}-${workloadName}-uks-${uniqueNumbers}'
var VMSize = 'Standard_D2s_v3'
var nicName = 'nic-${projectName}-${workloadName}-uks-${uniqueNumbers}'
var shortComputerName = '${projectName}-${uniqueNumbers}'
var osDiskName = 'disk-${projectName}-${workloadName}-ase-${uniqueNumbers}'

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
        storageUri: 'https://stnettoolsase001.blob.core.windows.net/'
      }
    }
  }
}
