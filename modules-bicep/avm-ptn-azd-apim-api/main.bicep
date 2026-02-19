// Opinionated APIM API module following Acestus standards and security best practices

metadata name = 'Acestus APIM API'
metadata description = 'Custom APIM API module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('APIM API name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('APIM API properties')
param properties object

module apimApi 'br:avm/ptn/azd/apim-api:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the APIM API')
output resourceId string = apimApi.outputs.resourceId

@description('All outputs from the AVM APIM API module')
output apimApi object = apimApi.outputs
