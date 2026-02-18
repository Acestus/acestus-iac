param vnetNamePrefix string = 'vnet'

// Parameters
param location string

resource vnets 'Microsoft.Network/virtualNetworks@2020-11-01' existing =  {
  name: '${vnetNamePrefix}-${location}'
}

type vnetOutputObject = {
  name: string
  id: string
}

output vnetsOutput vnetOutputObject = {
  name: vnets.name
  id: vnets.id
}
