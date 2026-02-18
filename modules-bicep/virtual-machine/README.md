# Acestus Virtual Machine Module

This is a custom Bicep module for Azure Virtual Machines that implements Acestus security standards and naming conventions.

## Features

- **Security First**: Defaults to Trusted Launch, secure boot, vTPM, and managed identities
- **Acestus Standards**: Follows organizational security and compliance requirements
- **Multi-Platform**: Supports both Windows and Linux VMs
- **Flexible Configuration**: Supports various deployment scenarios with disks, networking, and extensions
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Virtual Machine name |
| `nicConfigurations` | array | Network interface configurations |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `vmSize` | string | `Standard_D2s_v5` | VM size |
| `osType` | string | `Linux` | Operating system type |
| `imageReference` | object | Ubuntu 22.04 LTS | VM image reference |
| `adminUsername` | string | `azureadmin` | Admin username |
| `adminPassword` | securestring | `''` | Admin password |
| `sshPublicKey` | securestring | `''` | SSH public key for Linux |
| `disablePasswordAuthentication` | bool | `true` | Disable password auth for Linux |
| `osDiskType` | string | `Premium_LRS` | OS disk type |
| `osDiskSizeGB` | int | `0` | OS disk size (0 for default) |
| `dataDisks` | array | `[]` | Data disk configurations |
| `zone` | string | `''` | Availability zone |
| `availabilitySetResourceId` | string | `''` | Availability set resource ID |
| `enableSystemAssignedIdentity` | bool | `true` | Enable system-assigned identity |
| `userAssignedIdentities` | array | `[]` | User-assigned identity IDs |
| `bootDiagnosticsEnabled` | bool | `true` | Enable boot diagnostics |
| `encryptionAtHost` | bool | `false` | Enable encryption at host |
| `secureBootEnabled` | bool | `true` | Enable secure boot |
| `vTpmEnabled` | bool | `true` | Enable vTPM |
| `securityType` | string | `TrustedLaunch` | Security type |
| `enableHybridBenefit` | bool | `false` | Enable Azure Hybrid Benefit |
| `enableAutomaticUpdates` | bool | `true` | Enable automatic updates |
| `patchMode` | string | `AutomaticByPlatform` | Patch mode |

## Usage Examples

### Basic Linux VM with SSH
```bicep
module linuxVm 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-machine:v1.0.0' = {
  name: 'myLinuxVm'
  params: {
    name: 'vm-app-dev-usw2-001'
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    nicConfigurations: [
      {
        nicSuffix: '-nic-01'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnet.outputs.resourceId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
  }
}
```

### Windows VM with Password
```bicep
module windowsVm 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-machine:v1.0.0' = {
  name: 'myWindowsVm'
  params: {
    name: 'vm-win-prd-usw2-001'
    osType: 'Windows'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-g2'
      version: 'latest'
    }
    adminPassword: adminPasswordSecret
    enableHybridBenefit: true
    nicConfigurations: [
      {
        nicSuffix: '-nic-01'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnet.outputs.resourceId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
  }
}
```

### VM with Data Disks and Availability Zone
```bicep
module vmWithDisks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-machine:v1.0.0' = {
  name: 'myVmWithDisks'
  params: {
    name: 'vm-data-prd-usw2-001'
    vmSize: 'Standard_D4s_v5'
    zone: '1'
    dataDisks: [
      {
        name: 'data-disk-01'
        diskSizeGB: 256
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        lun: 0
        caching: 'ReadOnly'
        createOption: 'Empty'
      }
      {
        name: 'data-disk-02'
        diskSizeGB: 512
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        lun: 1
        caching: 'None'
        createOption: 'Empty'
      }
    ]
    nicConfigurations: [
      {
        nicSuffix: '-nic-01'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnet.outputs.resourceId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
  }
}
```

### Confidential VM
```bicep
module confidentialVm 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-machine:v1.0.0' = {
  name: 'myConfidentialVm'
  params: {
    name: 'vm-secure-prd-usw2-001'
    vmSize: 'Standard_DC2as_v5'
    securityType: 'ConfidentialVM'
    encryptionAtHost: true
    sshPublicKey: loadTextContent('~/.ssh/id_rsa.pub')
    nicConfigurations: [
      {
        nicSuffix: '-nic-01'
        ipConfigurations: [
          {
            name: 'ipconfig1'
            subnetResourceId: subnet.outputs.resourceId
            privateIPAllocationMethod: 'Dynamic'
          }
        ]
      }
    ]
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the Virtual Machine |
| `name` | string | The name of the Virtual Machine |
| `resourceGroupName` | string | The resource group the VM was deployed into |
| `location` | string | The location of the Virtual Machine |
| `systemAssignedMIPrincipalId` | string | Principal ID of system-assigned identity |
| `virtualMachine` | object | All outputs from the AVM module |

## Security Considerations

- Use Trusted Launch or Confidential VMs for production workloads
- Enable secure boot and vTPM for enhanced security
- Use SSH keys instead of passwords for Linux VMs
- Enable managed identities for Azure resource access
- Use Azure Bastion or JIT access instead of public IPs
- Enable encryption at host for sensitive workloads
- Keep VMs patched with automatic updates enabled
