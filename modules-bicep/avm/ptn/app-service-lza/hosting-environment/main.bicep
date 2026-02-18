// Opinionated App Service LZA Hosting Environment module following Acestus standards and security best practices

metadata name = 'Acestus App Service LZA Hosting Environment'
metadata description = 'Custom App Service LZA Hosting Environment module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Hosting Environment name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Hosting environment properties')
param properties object

module hostingEnvironment 'br:avm/ptn/app-service-lza/hosting-environment:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Hosting Environment')
output resourceId string = hostingEnvironment.outputs.resourceId

@description('All outputs from the AVM Hosting Environment module')
output hostingEnvironment object = hostingEnvironment.outputs
