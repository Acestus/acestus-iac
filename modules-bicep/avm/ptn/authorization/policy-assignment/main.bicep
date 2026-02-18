// Opinionated Policy Assignment module following Acestus standards and security best practices

metadata name = 'Acestus Policy Assignment'
metadata description = 'Custom Policy Assignment module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Policy Assignment name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Policy assignment properties')
param properties object

module policyAssignment 'br:avm/ptn/authorization/policy-assignment:0.5.3' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Policy Assignment')
output resourceId string = policyAssignment.outputs.resourceId

@description('All outputs from the AVM Policy Assignment module')
output policyAssignment object = policyAssignment.outputs
