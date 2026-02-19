// Opinionated AKS Automatic Cluster module following Acestus standards and security best practices

metadata name = 'Acestus AKS Automatic Cluster'
metadata description = 'Custom AKS Automatic Cluster module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('AKS Automatic Cluster name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('AKS automatic cluster properties')
param properties object

module aksAutomaticCluster 'br:avm/ptn/azd/aks-automatic-cluster:0.3.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the AKS Automatic Cluster')
output resourceId string = aksAutomaticCluster.outputs.resourceId

@description('All outputs from the AVM AKS Automatic Cluster module')
output aksAutomaticCluster object = aksAutomaticCluster.outputs
