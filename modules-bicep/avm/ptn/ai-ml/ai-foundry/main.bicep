// Opinionated AI ML Foundry module following Acestus standards and security best practices

metadata name = 'Acestus AI ML Foundry'
metadata description = 'Custom AI ML Foundry module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('AI ML Foundry name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('AI ML Foundry properties')
param properties object

module aiMlFoundry 'br:avm/ptn/ai-ml/ai-foundry:0.6.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the AI ML Foundry')
output resourceId string = aiMlFoundry.outputs.resourceId

@description('All outputs from the AVM AI ML Foundry module')
output aiMlFoundry object = aiMlFoundry.outputs
