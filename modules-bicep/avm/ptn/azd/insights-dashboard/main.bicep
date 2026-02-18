// Opinionated Insights Dashboard module following Acestus standards and security best practices

metadata name = 'Acestus Insights Dashboard'
metadata description = 'Custom Insights Dashboard module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Insights Dashboard name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Insights Dashboard properties')
param properties object

module insightsDashboard 'br:avm/ptn/azd/insights-dashboard:0.1.2' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Insights Dashboard')
output resourceId string = insightsDashboard.outputs.resourceId

@description('All outputs from the AVM Insights Dashboard module')
output insightsDashboard object = insightsDashboard.outputs
