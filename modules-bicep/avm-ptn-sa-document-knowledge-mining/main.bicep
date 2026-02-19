// Opinionated Document Knowledge Mining module following Acestus standards and security best practices

metadata name = 'Acestus Document Knowledge Mining'
metadata description = 'Custom Document Knowledge Mining module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Document Knowledge Mining name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Document Knowledge Mining properties')
param properties object

module documentKnowledgeMining 'br:avm/ptn/sa/document-knowledge-mining:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Document Knowledge Mining')
output resourceId string = documentKnowledgeMining.outputs.resourceId

@description('All outputs from the AVM Document Knowledge Mining module')
output documentKnowledgeMining object = documentKnowledgeMining.outputs
