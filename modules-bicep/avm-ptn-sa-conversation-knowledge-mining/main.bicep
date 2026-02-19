// Opinionated Conversation Knowledge Mining module following Acestus standards and security best practices

metadata name = 'Acestus Conversation Knowledge Mining'
metadata description = 'Custom Conversation Knowledge Mining module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Conversation Knowledge Mining name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Conversation Knowledge Mining properties')
param properties object

module conversationKnowledgeMining 'br:avm/ptn/sa/conversation-knowledge-mining:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Conversation Knowledge Mining')
output resourceId string = conversationKnowledgeMining.outputs.resourceId

@description('All outputs from the AVM Conversation Knowledge Mining module')
output conversationKnowledgeMining object = conversationKnowledgeMining.outputs
