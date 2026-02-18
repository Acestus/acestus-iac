// Parameters
param locations array = [
  { name: 'East US', sname: 'eus' }
  { name: 'West US 2', sname: 'wus2' }
  { name: 'Central US', sname: 'cus' }
]
param vnetNamePrefix string = 'vnet'


module vnets 'module2.bicep' = {
  name: 'vnets'
  params: {
    locations: locations
    vnetNamePrefix: vnetNamePrefix
  }
}


module vnetPeerings './module3.bicep' = {
  name: 'vnetPeerings'
  params: {
    vnets: vnets.outputs.retrievedVnetsOutput
  }
}
