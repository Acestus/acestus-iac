@description('Username for the Virtual Machine.')
param adminUsername string = 'Acestus'

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Resource ID of the subnet.')
@allowed([
  '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-ase-001/subnets/default'
  '/subscriptions/<subscription-id>/resourceGroups/ase-RG-LB-AG/providers/Microsoft.Network/virtualNetworks/ase-LB-AG-VNET-10.86.0.0/subnets/ase-SNET-10.86.10.0'
  '/subscriptions/<subscription-id>/resourceGroups/ase-RG-AUTH/providers/Microsoft.Network/virtualNetworks/ase-AUTH-VNET-10.85.0.0/subnets/ase-AUTH-SNET-10.85.10.0'
  '/subscriptions/<subscription-id>/resourceGroups/ase-RG-IDENT/providers/Microsoft.Network/virtualNetworks/ase-IDENT-VNET-10.82.0.0/subnets/ase-IDENT-SNET-10.82.10.0'
  '/subscriptions/<subscription-id>/resourceGroups/USW3-LB-AG-RG-01/providers/Microsoft.Network/virtualNetworks/USW3-LB-AG-VNET-10.92.0.0/subnets/USW3-SNET-10.92.10.0'
  '/subscriptions/<subscription-id>/resourceGroups/USW3-SBOX-RG-01/providers/Microsoft.Network/virtualNetworks/USW3-SB0X-VNET-10.90.0.0/subnets/USW3-SNET-10.90.10.0'
  '/subscriptions/<subscription-id>/resourceGroups/USW3-SBOX-RG-02/providers/Microsoft.Network/virtualNetworks/USW3-SB0X-VNET-10.91.0.0/subnets/USW3-SNET-10.91.10.0'
])
param SubnetID string = '/subscriptions/<subscription-id>/resourceGroups/NetTools/providers/Microsoft.Network/virtualNetworks/vnet-nettools-ase-001/subnets/default'

var location = resourceGroup().location
var projectName = 'nettools'
var cafName = 
var vmName = 'vm-${cafName}'
var VMSize = 'Standard_B2s'
var nicName = 'nic-${cafName}'
var shortComputerName = '${projectName}-${instanceNumber}'
var osDiskName = 'disk-${cafName}'
var storageAccountName = 'stnettoolsase001'
var storageUri = 'https://${storageAccountName}.blob.${environment().suffixes.storage}'
var vmName = 'vm-${projectName}-${workloadName}-ase-${uniqueNumbers}'
var VMSize = 'Standard_D2s_v3'
var nicName = 'nic-${projectName}-${workloadName}-ase-${uniqueNumbers}'
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
        storageUri: 'https://stnettoolsase001.blob.core.windows.net/'
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
      commandToExecute: 'apt-get update && apt-get install -y nmap'
    }
  }
}
