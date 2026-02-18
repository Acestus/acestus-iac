using 'main.bicep'

param projectName = 'timelogger'
param environment = 'prd'
param createdBy = 'deployment-pipeline'
param nodeVmSize = 'Standard_D4s_v3'
param nodeCount = 3

// Existing ACR (shared across all environments) - Update with your ACR details
param existingAcrName = '<your-acr-name>'
param existingAcrResourceGroup = '<your-acr-resource-group>'
param existingAcrSubscriptionId = '<your-acr-subscription-id>'

// Existing Log Analytics Workspace (optional)
param existingLogAnalyticsName = '<your-log-analytics-name>'
param existingLogAnalyticsResourceGroup = '<your-log-analytics-rg>'
param existingLogAnalyticsSubscriptionId = '<your-log-analytics-sub-id>'

// Existing User Assigned Identity (optional)
param existingIdentityName = '<your-identity-name>'
param existingIdentityResourceGroup = '<your-identity-rg>'

// Existing Application Insights (optional)
param existingAppInsightsName = '<your-app-insights-name>'
param existingAppInsightsResourceGroup = '<your-app-insights-rg>'

param tags = {
  ManagedBy: '<your-repo-url>'
  CreatedBy: '<your-username>'
  Subscription: '<your-subscription-name>'
  Project: 'Time Logger Template'
}
