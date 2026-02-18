// Opinionated AI Platform Baseline module following Acestus standards and security best practices

metadata name = 'Acestus AI Platform Baseline'
metadata description = 'Custom AI Platform Baseline module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('AI Platform Baseline name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('AI Platform Baseline properties')
param properties object

module aiPlatformBaseline 'br:avm/ptn/ai-platform/baseline:0.8.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the AI Platform Baseline')
output resourceId string = aiPlatformBaseline.outputs.resourceId

@description('All outputs from the AVM AI Platform Baseline module')
output aiPlatformBaseline object = aiPlatformBaseline.outputs
