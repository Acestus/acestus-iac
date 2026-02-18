param locations array = [
  { name: 'East US', sname: 'eus' }
  { name: 'West US', sname: 'wus' }
  { name: 'Central US', sname: 'cus' }
]
param vnetNamePrefix string = 'vnet'


module vnets './module1.bicep' = [for location in locations: {
  name: location.sname
  params: {
    location: location.sname
    vnetNamePrefix: vnetNamePrefix
  }

}]

var retrievedVnets = map(vnets, vnet => {
  name: vnet.outputs.vnetsOutput.name
  id: vnet.outputs.vnetsOutput.id
})

output retrievedVnetsOutput array = retrievedVnets
