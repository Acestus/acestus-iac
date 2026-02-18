// Opinionated route table module following Acestus standards

metadata name = 'Acestus Route Table'
metadata description = 'Route Table module with Acestus networking standards'
metadata version = '1.0.0'

@description('Name of the route table')
param name string

@description('Location for the route table')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Disable BGP route propagation')
param disableBgpRoutePropagation bool = false

@description('Routes to create in the route table')
param routes array = []

resource routeTable 'Microsoft.Network/routeTables@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [for route in routes: {
      name: route.name
      properties: {
        addressPrefix: route.addressPrefix
        nextHopType: route.nextHopType
        nextHopIpAddress: route.?nextHopIpAddress ?? null
        hasBgpOverride: route.?hasBgpOverride ?? false
      }
    }]
  }
}

@description('The resource ID of the route table')
output resourceId string = routeTable.id

@description('The name of the route table')
output name string = routeTable.name

@description('The routes in the route table')
output routes array = routeTable.properties.routes
