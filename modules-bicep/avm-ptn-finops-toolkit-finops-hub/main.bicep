// Opinionated FinOps Hub module following Acestus standards and security best practices

metadata name = 'Acestus FinOps Hub'
metadata description = 'Custom FinOps Hub module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('FinOps Hub name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('FinOps Hub properties')
param properties object

module finopsHub 'br:avm/ptn/finops-toolkit/finops-hub:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the FinOps Hub')
output resourceId string = finopsHub.outputs.resourceId

@description('All outputs from the AVM FinOps Hub module')
output finopsHub object = finopsHub.outputs
