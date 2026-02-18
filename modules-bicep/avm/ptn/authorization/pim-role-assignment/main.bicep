// Opinionated PIM Role Assignment module following Acestus standards and security best practices

metadata name = 'Acestus PIM Role Assignment'
metadata description = 'Custom PIM Role Assignment module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('PIM Role Assignment name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('PIM role assignment properties')
param properties object

module pimRoleAssignment 'br:avm/ptn/authorization/pim-role-assignment:0.1.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the PIM Role Assignment')
output resourceId string = pimRoleAssignment.outputs.resourceId

@description('All outputs from the AVM PIM Role Assignment module')
output pimRoleAssignment object = pimRoleAssignment.outputs
