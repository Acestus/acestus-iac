using 'main.bicep'

param functionAppName = 'func-jml-prd-usw2-001'
param storageAccountName = 'stjmlprdusw2001'
param location = 'West US 2'
param tenantId = '13f66e9f-e5f2-4105-a6ba-d2d40b02cdbc'
param aiResourceGroup = 'rg-acehr-prd-usw2-001'
param existingAppServicePlanId = '/subscriptions/<subscription-id>/resourceGroups/rg-acehr-prd-usw2-001/providers/Microsoft.Web/serverfarms/asp-acehr-prd-usw2-001'
param existingApplicationInsightsId = '/subscriptions/<subscription-id>/resourceGroups/rg-acehr-prd-usw2-001/providers/Microsoft.Insights/components/ai-acehr-prd-usw2-001'
param userManagedIdentityId = '/subscriptions/<subscription-id>/resourceGroups/rg-acehr-prd-usw2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/umi-acehr-prd-usw2-001'
param existingServiceBusNamespaceId = '/subscriptions/<subscription-id>/resourceGroups/rg-acehr-prd-usw2-001/providers/Microsoft.ServiceBus/namespaces/sb-acehr-prd-usw2-001'
param pythonVersion = '3.13'

param funcApiSettings = {
  maxFileSize: 52428800 // 50MB
  allowedFileTypes: ['.html', '.htm', '.txt', '.xml', '.json', '.csv', '.log']
  enableAuthentication: false
  rateLimitPerMinute: 2000
  cacheControlMaxAge: 300
  enableHTMLGeneration: true
  defaultScriptType: 'default'
  enableTokenReplacement: true
}

