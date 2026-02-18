// Opinionated Subscription Placement module following Acestus standards and security best practices

metadata name = 'Acestus Subscription Placement'
metadata description = 'Custom Subscription Placement module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Subscription Placement name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Subscription Placement properties')
param properties object

module subscriptionPlacement 'br:avm/ptn/mgmt-groups/subscription-placement:0.3.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Subscription Placement')
output resourceId string = subscriptionPlacement.outputs.resourceId

@description('All outputs from the AVM Subscription Placement module')
output subscriptionPlacement object = subscriptionPlacement.outputs
