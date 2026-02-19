// Opinionated Azure Image Builder module following Acestus standards and security best practices

metadata name = 'Acestus Azure Image Builder'
metadata description = 'Custom Azure Image Builder module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Azure Image Builder name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Azure Image Builder properties')
param properties object

module azureImageBuilder 'br:avm/ptn/virtual-machine-images/azure-image-builder:0.2.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Azure Image Builder')
output resourceId string = azureImageBuilder.outputs.resourceId

@description('All outputs from the AVM Azure Image Builder module')
output azureImageBuilder object = azureImageBuilder.outputs
