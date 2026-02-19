// Opinionated Monitoring module following Acestus standards and security best practices
// Deploys: Log Analytics Workspace + Application Insights + Dashboard

metadata name = 'Acestus Monitoring'
metadata description = 'Custom Monitoring module with Acestus security defaults and naming conventions'
metadata version = '1.1.0'

// ============================================================================
// Parameters - Identity
// ============================================================================

@description('Base name for all monitoring resources')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

// ============================================================================
// Parameters - Log Analytics Configuration
// ============================================================================

@description('Name for the Log Analytics workspace (defaults to log-{name})')
param logAnalyticsName string = 'law-${name}'

// ============================================================================
// Parameters - Application Insights Configuration
// ============================================================================

@description('Name for Application Insights (defaults to appi-{name})')
param applicationInsightsName string = 'ai-${name}'

// ============================================================================
// Parameters - Dashboard Configuration
// ============================================================================

@description('Name for the monitoring dashboard (defaults to dash-{name})')
param dashboardName string = ''

// ============================================================================
// Variables
// ============================================================================

var resolvedLogAnalyticsName = !empty(logAnalyticsName) ? logAnalyticsName : 'log-${name}'
var resolvedApplicationInsightsName = !empty(applicationInsightsName) ? applicationInsightsName : 'appi-${name}'
var resolvedDashboardName = !empty(dashboardName) ? dashboardName : 'dash-${name}'

// ============================================================================
// AVM Pattern Module
// ============================================================================

module monitoring 'br/public:avm/ptn/azd/monitoring:0.2.1' = {
  name: '${deployment().name}-avm-monitoring'
  params: {
    logAnalyticsName: resolvedLogAnalyticsName
    applicationInsightsName: resolvedApplicationInsightsName
    applicationInsightsDashboardName: resolvedDashboardName
    location: location
    tags: tags
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('The resource ID of the Log Analytics workspace')
output logAnalyticsWorkspaceResourceId string = monitoring.outputs.logAnalyticsWorkspaceResourceId

@description('The name of the Log Analytics workspace')
output logAnalyticsWorkspaceName string = monitoring.outputs.logAnalyticsWorkspaceName

@description('The resource ID of Application Insights')
output applicationInsightsResourceId string = monitoring.outputs.applicationInsightsResourceId

@description('The name of Application Insights')
output applicationInsightsName string = monitoring.outputs.applicationInsightsName

@description('The connection string for Application Insights')
output applicationInsightsConnectionString string = monitoring.outputs.applicationInsightsConnectionString

@description('The instrumentation key for Application Insights')
output applicationInsightsInstrumentationKey string = monitoring.outputs.applicationInsightsInstrumentationKey
