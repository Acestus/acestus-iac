// Opinionated Service Health Alerts module following Acestus standards and security best practices

metadata name = 'Acestus Service Health Alerts'
metadata description = 'Custom Service Health Alerts module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Service Health Alerts name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Service Health Alerts properties')
param properties object

module serviceHealthAlerts 'br:avm/ptn/subscription/service-health-alerts:0.1.1' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Service Health Alerts')
output resourceId string = serviceHealthAlerts.outputs.resourceId

@description('All outputs from the AVM Service Health Alerts module')
output serviceHealthAlerts object = serviceHealthAlerts.outputs
