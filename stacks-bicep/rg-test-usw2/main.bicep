param location string = resourceGroup().location

@description('Project name for resource naming')
param projectName string

@description('Environment for resource naming')
param environment string

@description('Region for resource naming')
param region string

@description('Instance number for resource naming')
param instanceNumber string

@description('Tags for resources')
param tags object 

var functionAppName = 'func-${projectName}-${environment}-${region}-${instanceNumber}'
var storageAccountName = 'st${projectName}${environment}${region}${instanceNumber}'

module customStorageModule 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.2' = {
  name: 'customStorageTest'
  params: {
    storageAccountName: storageAccountName
    location: location
    skuName: 'Standard_ZRS'
    tags: tags
    allowSharedKeyAccess: false
  }
}

module functionApp 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/function-app/function-app:v1.0.0' = {
  name: 'functionApp'
  params: {
    name: functionAppName
    location: location
    tags: tags
    appServicePlanId: existingAppServicePlanId
    storageAccountId: customStorageModule.outputs.storageAccountId
    applicationInsightsId: existingApplicationInsightsId
    userManagedIdentityId: userManagedIdentityId
    pythonVersion: pythonVersion
    funcApiSettings: funcApiSettings
  }
}
