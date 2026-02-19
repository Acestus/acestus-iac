// Opinionated Role Assignment module following Acestus standards and security best practices

metadata name = 'Acestus Role Assignment'
metadata description = 'Custom Role Assignment module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Role Assignment name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Role definition ID')
param properties object

@description('Principal ID')
@description('Scope for the role assignment')
@description('Additional properties to merge')
module roleAssignment 'br:avm/ptn/authorization/role-assignment:0.2.4' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Role Assignment')
output resourceId string = roleAssignment.outputs.resourceId

@description('All outputs from the AVM Role Assignment module')
output roleAssignment object = roleAssignment.outputs
