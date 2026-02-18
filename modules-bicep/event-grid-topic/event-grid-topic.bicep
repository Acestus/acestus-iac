// Opinionated Event Grid System Topic module following Acestus standards

metadata name = 'Acestus Event Grid System Topic'
metadata description = 'Event Grid System Topic module with Acestus standards'
metadata version = '1.0.0'

@description('Name of the Event Grid system topic')
param name string

@description('Location for the system topic')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Source resource ID for the system topic')
param source string

@description('Topic type (e.g., Microsoft.Storage.StorageAccounts)')
param topicType string

@description('Enable system assigned managed identity')
param enableSystemAssignedIdentity bool = false

@description('User assigned identity resource IDs')
param userAssignedIdentityIds array = []

@description('Event subscriptions to create')
param eventSubscriptions array = []

// Build identity configuration
var identityType = enableSystemAssignedIdentity ? (!empty(userAssignedIdentityIds) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentityIds) ? 'UserAssigned' : 'None')

var userAssignedIdentities = !empty(userAssignedIdentityIds) ? reduce(userAssignedIdentityIds, {}, (cur, next) => union(cur, { '${next}': {} })) : null

resource systemTopic 'Microsoft.EventGrid/systemTopics@2024-06-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: identityType != 'None' ? {
    type: identityType
    userAssignedIdentities: userAssignedIdentities
  } : null
  properties: {
    source: source
    topicType: topicType
  }
}

// Event subscriptions
resource subscriptions 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2024-06-01-preview' = [for sub in eventSubscriptions: {
  parent: systemTopic
  name: sub.name
  properties: {
    destination: sub.destination
    filter: sub.?filter ?? {
      includedEventTypes: []
    }
    eventDeliverySchema: sub.?eventDeliverySchema ?? 'EventGridSchema'
    retryPolicy: sub.?retryPolicy ?? {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
    deadLetterDestination: sub.?deadLetterDestination ?? null
    labels: sub.?labels ?? []
  }
}]

@description('The resource ID of the system topic')
output resourceId string = systemTopic.id

@description('The name of the system topic')
output name string = systemTopic.name

@description('The principal ID of the system assigned identity')
output systemAssignedMIPrincipalId string = systemTopic.identity.?principalId ?? ''

@description('The metric resource ID for the system topic')
output metricResourceId string = systemTopic.properties.metricResourceId
