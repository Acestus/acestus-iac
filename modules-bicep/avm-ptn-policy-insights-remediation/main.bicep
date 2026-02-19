// Opinionated Remediation module following Acestus standards and security best practices

metadata name = 'Acestus Remediation'
metadata description = 'Custom Remediation module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Remediation name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Remediation properties')
param properties object

module remediation 'br:avm/ptn/policy-insights/remediation:0.1.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Remediation')
output resourceId string = remediation.outputs.resourceId

@description('All outputs from the AVM Remediation module')
output remediation object = remediation.outputs
