// Opinionated Security Center module following Acestus standards and security best practices

metadata name = 'Acestus Security Center'
metadata description = 'Custom Security Center module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Security Center name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Security Center properties')
param properties object

module securityCenter 'br:avm/ptn/security/security-center:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Security Center')
output resourceId string = securityCenter.outputs.resourceId

@description('All outputs from the AVM Security Center module')
output securityCenter object = securityCenter.outputs
