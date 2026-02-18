@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Resource ID of the subnet.')
param SubnetID string = '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-usw2-001/subnets/default'

var location = resourceGroup().location
var projectName = 'nettools'
var subscriptionName = 'SBX-510-Infrastructure'
var workloadName1 = substring(subscriptionName, 0, indexOf(subscriptionName, '-'))
var workloadName2 = substring(subscriptionName, 4, indexOf(subscriptionName, '-'))
var workloadName = concat(workloadName1, workloadName2)
var uniqueNumbers = substring(uniqueString(resourceGroup().id, deployment().name), 0, 3)
var vmName = 'vm-${projectName}-${workloadName}-usw2-${uniqueNumbers}'
var VMSize = 'Standard_D2s_v3'
var nicName = 'nic-${projectName}-${workloadName}-usw2-${uniqueNumbers}'
var osDiskName = 'disk-${projectName}-${workloadName}-usw2-${uniqueNumbers}'

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
      computerName: vmName
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
        storageUri: 'https://stnettoolsusw2001.blob.core.windows.net/'
      }
    }
  }
}

resource vmName_cloud_init 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
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
      commandToExecute: 'apt-get update'
    }
  }
}
