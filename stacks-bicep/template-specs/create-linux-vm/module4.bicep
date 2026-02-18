param sourceVnetName string

param destinationVnetName string

param destinationVnetId string


resource vnetParent 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: sourceVnetName

  resource vnetPeerings 'virtualNetworkPeerings@2020-11-01' = {
    name: '${sourceVnetName}-to-${destinationVnetName}'
    properties: {
      remoteVirtualNetwork: {
        id: destinationVnetId
      }
      allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      allowGatewayTransit: false
      useRemoteGateways: false
    }
  }
}
