// Opinionated Import Image to ACR module following Acestus standards and security best practices

metadata name = 'Acestus Import Image to ACR'
metadata description = 'Custom Import Image to ACR module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Import Image to ACR name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Import Image to ACR properties')
param properties object

module importImageToAcr 'br:avm/ptn/deployment-script/import-image-to-acr:0.4.4' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Import Image to ACR')
output resourceId string = importImageToAcr.outputs.resourceId

@description('All outputs from the AVM Import Image to ACR module')
output importImageToAcr object = importImageToAcr.outputs
