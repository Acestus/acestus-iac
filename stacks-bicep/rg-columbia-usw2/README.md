# Columbia AVD Stack (rg-columbia-usw2)

Azure Virtual Desktop infrastructure deployment with 3 session hosts on a dedicated virtual network.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│              VNet: vnet-columbia-prd-usw2           │
│              Address Space: 10.86.0.0/22            │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │      Subnet: snet-avd-columbia                │  │
│  │      Address: 10.86.0.0/24                    │  │
│  │      NSG: nsg-columbia-avd-prd-usw2           │  │
│  │                                               │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐       │  │
│  │  │  VM-01  │  │  VM-02  │  │  VM-03  │       │  │
│  │  │  AVD    │  │  AVD    │  │  AVD    │       │  │
│  │  │ Host    │  │ Host    │  │ Host    │       │  │
│  │  └─────────┘  └─────────┘  └─────────┘       │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Resources Deployed

| Resource Type | Name | Purpose |
|---------------|------|---------|
| Virtual Network | vnet-columbia-prd-usw2 | Network connectivity for AVD hosts |
| Network Security Group | nsg-columbia-avd-prd-usw2 | Security rules for AVD traffic |
| Virtual Machine (x3) | vm-columbia-avd-01/02/03 | AVD session hosts |
| Network Interfaces (x3) | nic-columbia-avd-01/02/03 | NIC for each VM |

## Configuration

### Default Settings

- **VM Size**: Standard_D4s_v5 (4 vCPUs, 16 GB RAM)
- **OS Image**: Windows 11 23H2 AVD (Multi-session)
- **OS Disk**: 128 GB Premium SSD
- **Security**: Trusted Launch enabled (Secure Boot + vTPM)
- **Networking**: Accelerated Networking enabled
- **Identity**: System-assigned Managed Identity

### NSG Rules

| Rule | Direction | Port | Source | Description |
|------|-----------|------|--------|-------------|
| AllowRDP | Inbound | 3389 | VirtualNetwork | RDP for AVD service |
| AllowHTTPS | Inbound | 443 | AzureCloud | AVD management |
| AllowAzureCloudOutbound | Outbound | 443 | Any | Azure services |
| AllowWindowsActivation | Outbound | 1688 | Any | Windows KMS |

## Deployment

### Prerequisites

1. Azure PowerShell module installed
2. Logged into Azure (`Connect-AzAccount`)
3. Resource group `rg-columbia-usw2` created
4. Admin password ready (secure string)

### Deploy

```powershell
# From repository root
.\scripts\deploy-bicep.ps1 -Stack rg-columbia-usw2 -Environment prd

# Or from this directory
.\deploy-bicep-stack.ps1
```

### Deploy with Admin Password

```powershell
# Using deployment parameter
az deployment group create \
  --resource-group rg-columbia-usw2 \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --parameters adminPassword='<your-secure-password>'
```

## Post-Deployment Steps

After deploying the infrastructure, complete these steps to configure AVD:

1. **Join VMs to Azure AD or AD DS**
   - Configure Azure AD Join or domain join
   - Add VMs to appropriate OU

2. **Register with AVD Host Pool**
   - Create/use existing AVD Host Pool
   - Generate registration token
   - Install AVD agent on session hosts

3. **Configure User Access**
   - Add users/groups to AVD Application Groups
   - Configure FSLogix profile containers (if needed)

4. **Enable Monitoring**
   - Configure Azure Monitor for AVD
   - Enable diagnostics to Log Analytics

## Module Dependencies

This stack uses the following Acestus wrapper modules:

- `modules-bicep/virtual-network/virtual-network.bicep` - VNet wrapper (uses AVM res/network/virtual-network)
- `modules-bicep/network-security-group/network-security-group.bicep` - NSG wrapper
- `modules-bicep/virtual-machine/virtual-machine.bicep` - VM wrapper (uses AVM res/compute/virtual-machine)

## Customization

### Scale Session Hosts

Modify `avdHostCount` in `main.bicepparam`:

```bicep
param avdHostCount = 5  // Scale to 5 hosts
```

### Change VM Size

```bicep
param vmSize = 'Standard_D8s_v5'  // 8 vCPUs, 32 GB RAM
```

### Change Address Space

```bicep
param vnetAddressSpace = ['10.87.0.0/22']
param avdSubnetPrefix = '10.87.0.0/24'
```

## Maintenance

### Windows Updates

VMs are configured with:
- `enableAutomaticUpdates: true`
- `patchMode: AutomaticByPlatform`

Azure Update Management will handle patching automatically.

### Azure Hybrid Benefit

Enabled by default (`enableHybridBenefit: true`). Ensure appropriate Windows Server licenses are available.
