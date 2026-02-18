// Opinionated Role Definition module following Acestus standards and security best practices

metadata name = 'Acestus Role Definition'
metadata description = 'Custom Role Definition module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Role Definition name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Role definition properties')
param properties object

module roleDefinition 'br:avm/ptn/authorization/role-definition:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Role Definition')
output resourceId string = roleDefinition.outputs.resourceId

@description('All outputs from the AVM Role Definition module')
output roleDefinition object = roleDefinition.outputs
