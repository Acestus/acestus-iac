using '../../main.bicep'

param projectName = 'columbia'
param environment = 'prd'
param CAFLocation = 'eus2'
param instanceNumber = '001'

// Prod environment uses 10.86.0.0/24 
param vnetAddressSpace = ['10.86.10.0/27']
param avdSubnetPrefix = '10.86.10.0/28'

param adminUsername = 'avdadmin'
// Key Vault reference for admin password
param adminPassword = getSecret('3f9e26da-8dad-4891-99f4-be054a040743', 'rg-aceanakv-prd-eus2-002', 'kv-aceanakv-prd-eus2-002', 'sec-columbia-prd-eus2-001', '60a9367195ae442faa64cf808c0e42f7')

// Using B-series until DSv5 quota is approved
param vmSize = 'Standard_B2ms'
// B-series doesn't support accelerated networking
param enableAcceleratedNetworking = false
param avdHostCount = 3

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Corp-710-Analytics'
  Project: 'Columbia AVD Platform'
  Environment: 'Production'
  Application: 'Azure Virtual Desktop'
}
