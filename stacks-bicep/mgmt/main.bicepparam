using './main.bicep'

param location = 'westus2'
param tags = {
  Environment: 'dev'
  ManagedBy: 'Bicep'
  Project: 'mgmt'
}
param logAnalyticsWorkspaceName = 'law-mgmt-dev-scus-001'
param applicationInsightsName = 'ai-mgmt-dev-scus-001'
