// Opinionated Container App module following Acestus standards
// This wrapper provides a simplified interface to the AVM container-app module

metadata name = 'Acestus Container App'
metadata description = 'Container App module with Acestus defaults'
metadata version = '1.0.0'

@description('Name of the Container App')
param name string

@description('Location for the container app')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Resource ID of the Container Apps Environment')
param environmentResourceId string

@description('Managed identities configuration. Example: { userAssignedResourceIds: ["..."] }')
param managedIdentities object = {}

@description('Container definitions')
param containers array

@description('Enable external ingress')
param ingressExternal bool = true

@description('Allow insecure HTTP connections')
param ingressAllowInsecure bool = false

@description('Target port for ingress')
param ingressTargetPort int = 80

@description('Ingress transport protocol')
@allowed([
  'auto'
  'http'
  'http2'
  'tcp'
])
param ingressTransport string = 'auto'

@description('Additional port mappings')
param additionalPortMappings array = []

@description('Scale settings for the container app. Example: { minReplicas: 0, maxReplicas: 10, rules: [] }')
param scaleSettings object = {}

@description('Minimum replicas (direct param, or use scaleSettings.minReplicas)')
param scaleMinReplicas int = 0

@description('Maximum replicas (direct param, or use scaleSettings.maxReplicas)')
param scaleMaxReplicas int = 10

@description('Scale rules (direct param, or use scaleSettings.rules)')
param scaleRules array = []

@description('Registries configuration')
param registries array = []

@description('Volumes configuration')
param volumes array = []

@description('Dapr configuration')
param dapr object = {}

// Resolve scale settings - prioritize direct params, fall back to scaleSettings object
var effectiveMinReplicas = scaleMinReplicas != 0 ? scaleMinReplicas : (scaleSettings.?minReplicas ?? 0)
var effectiveMaxReplicas = scaleMaxReplicas != 10 ? scaleMaxReplicas : (scaleSettings.?maxReplicas ?? 10)
var effectiveScaleRules = !empty(scaleRules) ? scaleRules : (scaleSettings.?rules ?? [])

// Use the same AVM version as rg-aspire-wus3 stack for compatibility
// Note: Parameters are passed through as-is to match the exact AVM interface
module containerApp 'br/public:avm/res/app/container-app:0.20.0' = {
  name: '${deployment().name}-ca'
  params: {
    name: name
    location: location
    tags: tags
    environmentResourceId: environmentResourceId
    managedIdentities: managedIdentities
    containers: containers
    ingressExternal: ingressExternal
    ingressAllowInsecure: ingressAllowInsecure
    ingressTargetPort: ingressTargetPort
    ingressTransport: ingressTransport
    additionalPortMappings: additionalPortMappings
    scaleMinReplicas: effectiveMinReplicas
    scaleMaxReplicas: effectiveMaxReplicas
    scaleRules: effectiveScaleRules
    registries: registries
    volumes: volumes
    dapr: dapr
  }
}

@description('The resource ID of the Container App')
output resourceId string = containerApp.outputs.resourceId

@description('The name of the Container App')
output name string = containerApp.outputs.name

@description('The FQDN of the Container App')
output fqdn string = containerApp.outputs.fqdn

@description('The system assigned managed identity principal ID')
output systemAssignedMIPrincipalId string = containerApp.outputs.?systemAssignedMIPrincipalId ?? ''
