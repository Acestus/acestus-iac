// Opinionated AKS module following Acestus standards and security best practices

metadata name = 'Acestus AKS'
metadata description = 'Custom AKS module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('AKS cluster name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('AKS properties')
param properties object

module aks 'br:avm/ptn/azd/aks:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the AKS cluster')
output resourceId string = aks.outputs.resourceId

@description('All outputs from the AVM AKS module')
output aks object = aks.outputs
