// Opinionated Resource Role Assignment module following Acestus standards and security best practices

metadata name = 'Acestus Resource Role Assignment'
metadata description = 'Custom Resource Role Assignment module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Resource Role Assignment name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Role definition ID')
param roleDefinitionId string

@description('Principal ID')
param principalId string

@description('Scope for the role assignment')
param scope string

@description('Additional properties to merge')
param properties object

module resourceRoleAssignment 'br:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Role Assignment')
output resourceId string = resourceRoleAssignment.outputs.resourceId

@description('All outputs from the AVM Resource Role Assignment module')
output resourceRoleAssignment object = resourceRoleAssignment.outputs
