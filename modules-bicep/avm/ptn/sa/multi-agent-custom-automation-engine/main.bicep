// Opinionated Multi-Agent Custom Automation Engine module following Acestus standards and security best practices

metadata name = 'Acestus Multi-Agent Custom Automation Engine'
metadata description = 'Custom Multi-Agent Custom Automation Engine module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Multi-Agent Custom Automation Engine name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Multi-Agent Custom Automation Engine properties')
param properties object

module multiAgentCustomAutomationEngine 'br:avm/ptn/sa/multi-agent-custom-automation-engine:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Multi-Agent Custom Automation Engine')
output resourceId string = multiAgentCustomAutomationEngine.outputs.resourceId

@description('All outputs from the AVM Multi-Agent Custom Automation Engine module')
output multiAgentCustomAutomationEngine object = multiAgentCustomAutomationEngine.outputs
