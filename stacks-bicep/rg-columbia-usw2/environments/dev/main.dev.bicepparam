using '../../main.bicep'

param projectName = 'columbia'
param environment = 'dev'
param CAFLocation = 'eus2'
param instanceNumber = '001'

// Dev environment - small /27 VNet (32 IPs) with /28 subnet (16 IPs)
param vnetAddressSpace = ['10.96.10.0/27']
param avdSubnetPrefix = '10.96.10.0/28'

param adminUsername = 'avdadmin'
// Set adminPassword via deployment parameter or Key Vault reference
param adminPassword = 'replace-with-secure-password01'

// Smaller VM size for dev - using B-series (typically has quota)
param vmSize = 'Standard_B2ms'
// B-series doesn't support accelerated networking
param enableAcceleratedNetworking = false
// Fewer hosts for dev
param avdHostCount = 1

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Sbox-710-Analytics'
  Project: 'Columbia AVD Platform'
  Environment: 'Development'
  Application: 'Azure Virtual Desktop'
}
