param vnets object[]

var vnetPeeringsArray = [for (vnet, i) in vnets: map(vnets, (vnet2, j) => i == j ? {} : {
  sourceName: vnet.name
  destinationName: vnet2.name
  destinationId: vnet2.id
})]

var flattenedVnetPeeringsArray = filter(flatten(vnetPeeringsArray), peering => peering != {})

module deployVnetPeerings 'module4.bicep' = [for vnetPeering in flattenedVnetPeeringsArray: {
  name: 'deployVnetPeerings${vnetPeering.sourceName}-${vnetPeering.destinationName}'
  params: {
    destinationVnetId: vnetPeering.destinationId
    destinationVnetName: vnetPeering.destinationName
    sourceVnetName: vnetPeering.sourceName
  }
}]


output vnetPeeringsArray array = flattenedVnetPeeringsArray
