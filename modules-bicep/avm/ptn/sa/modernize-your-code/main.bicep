// Opinionated Modernize Your Code module following Acestus standards and security best practices

metadata name = 'Acestus Modernize Your Code'
metadata description = 'Custom Modernize Your Code module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Modernize Your Code name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Modernize Your Code properties')
param properties object

module modernizeYourCode 'br:avm/ptn/sa/modernize-your-code:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Modernize Your Code')
output resourceId string = modernizeYourCode.outputs.resourceId

@description('All outputs from the AVM Modernize Your Code module')
output modernizeYourCode object = modernizeYourCode.outputs
