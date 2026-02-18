// Opinionated CICD Agents and Runners module following Acestus standards and security best practices

metadata name = 'Acestus CICD Agents and Runners'
metadata description = 'Custom CICD Agents and Runners module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('CICD Agents and Runners name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('CICD Agents and Runners properties')
param properties object

module cicdAgentsAndRunners 'br:avm/ptn/dev-ops/cicd-agents-and-runners:0.3.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the CICD Agents and Runners')
output resourceId string = cicdAgentsAndRunners.outputs.resourceId

@description('All outputs from the AVM CICD Agents and Runners module')
output cicdAgentsAndRunners object = cicdAgentsAndRunners.outputs
