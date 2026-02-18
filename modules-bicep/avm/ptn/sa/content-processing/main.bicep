// Opinionated Content Processing module following Acestus standards and security best practices

metadata name = 'Acestus Content Processing'
metadata description = 'Custom Content Processing module with Acestus security defaults and naming conventions'
metadata version = '1.0.0'

@description('Content Processing name')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Content Processing properties')
param properties object

module contentProcessing 'br:avm/ptn/sa/content-processing:0.2.0' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
    properties: properties
  }
}

@description('The resource ID of the Content Processing')
output resourceId string = contentProcessing.outputs.resourceId

@description('All outputs from the AVM Content Processing module')
output contentProcessing object = contentProcessing.outputs
