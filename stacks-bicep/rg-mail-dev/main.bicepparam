using './main.bicep'

param location = 'southcentralus'
param functionAppName = 'acestus-blog-api-scus'
param storageAccountName = 'acestusblogapiscus'
param appServicePlanName = 'asp-mail-dev-scus-001'
param appInsightsName = 'ai-mail-dev-scus-001'

param newsletterFromHistory = 'newsletter@history.acestus.com'
param newsletterFromCloud = 'newsletter@cloud.acestus.com'
param newsletterFromChristian = 'newsletter@dad.acestus.com'
