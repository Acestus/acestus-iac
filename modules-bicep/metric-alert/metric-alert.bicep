// Opinionated Metric Alert module following Acestus standards

metadata name = 'Acestus Metric Alert'
metadata description = 'Metric Alert module with Acestus monitoring standards'
metadata version = '1.0.0'

@description('Name of the metric alert')
param name string

@description('Location for the metric alert (use global)')
param location string = 'global'

@description('Tags to apply to the resource')
param tags object = {}

@description('Description of the alert rule')
param alertDescription string = ''

@description('Severity of the alert (0 = Critical, 1 = Error, 2 = Warning, 3 = Informational, 4 = Verbose)')
@allowed([0, 1, 2, 3, 4])
param severity int = 2

@description('Enable the alert rule')
param enabled bool = true

@description('Resource IDs to scope the alert to')
param scopes array

@description('How often to evaluate the alert (ISO 8601 duration)')
param evaluationFrequency string = 'PT5M'

@description('Time window to aggregate metrics (ISO 8601 duration)')
param windowSize string = 'PT15M'

@description('Target resource type for cross-resource alerts')
param targetResourceType string = ''

@description('Target resource region for cross-resource alerts')
param targetResourceRegion string = ''

@description('Alert criteria configuration')
param criteria object

@description('Action group resource IDs to notify')
param actionGroupIds array = []

@description('Auto-mitigate the alert')
param autoMitigate bool = true

@description('Custom properties to include in the alert')
param customProperties object = {}

// Build actions configuration
var actions = [for actionGroupId in actionGroupIds: {
  actionGroupId: actionGroupId
}]

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: alertDescription
    severity: severity
    enabled: enabled
    scopes: scopes
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    targetResourceType: !empty(targetResourceType) ? targetResourceType : null
    targetResourceRegion: !empty(targetResourceRegion) ? targetResourceRegion : null
    criteria: criteria
    actions: actions
    autoMitigate: autoMitigate
  }
}

@description('The resource ID of the metric alert')
output resourceId string = metricAlert.id

@description('The name of the metric alert')
output name string = metricAlert.name
