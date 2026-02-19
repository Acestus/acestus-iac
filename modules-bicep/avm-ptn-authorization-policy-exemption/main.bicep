// Opinionated Policy Exemption module following Acestus standards and security best practices

metadata name = 'Acestus Policy Exemption'
metadata description = 'Custom Policy Exemption module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Policy Exemption name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Policy exemption properties')
param properties object

module policyExemption 'br:avm/ptn/authorization/policy-exemption:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Policy Exemption')
output resourceId string = policyExemption.outputs.resourceId

@description('All outputs from the AVM Policy Exemption module')
output policyExemption object = policyExemption.outputs
