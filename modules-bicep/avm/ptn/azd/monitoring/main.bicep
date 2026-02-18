// Opinionated Monitoring module following Acestus standards and security best practices

metadata name = 'Acestus Monitoring'
metadata description = 'Custom Monitoring module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Monitoring name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Monitoring properties')
param properties object

module monitoring 'br:avm/ptn/azd/monitoring:0.2.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Monitoring')
output resourceId string = monitoring.outputs.resourceId

@description('All outputs from the AVM Monitoring module')
output monitoring object = monitoring.outputs
