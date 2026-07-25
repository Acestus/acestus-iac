targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = 'southcentralus'

@description('The project name used in CAF naming.')
param projectName string = 'crm'

@description('The environment name used in CAF naming.')
param environment string = 'dev'

@description('The Azure region code used in CAF naming.')
param CAFLocation string = 'scus'

@description('The instance number used in CAF naming.')
param instanceNumber string = '001'

@description('Tags to be applied to all resources.')
param tags object = {}

var cafName = '${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var appServicePlanName = 'asp-${cafName}'
var userManagedIdentityName = 'umi-${cafName}'
var gitHubActionsIssuer = 'https://token.actions.githubusercontent.com'
var gitHubActionsAudience = 'api://AzureADTokenExchange'
var gitHubActionsRepository = 'Acestus/ace'
var gitHubActionsSubjects = [
  'repo:${gitHubActionsRepository}:environment:${environment}'
  'repo:${gitHubActionsRepository}:ref:refs/heads/main'
]

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'FC1'
    capacity: 0
    tier: 'FlexConsumption'
  }
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }
}

module userManagedIdentity '../../modules-bicep/user-managed-identity/user-managed-identity.bicep' = {
  name: '${deployment().name}-umi'
  params: {
    name: userManagedIdentityName
    location: location
    tags: tags
    federatedIdentityCredentials: [
      for subject in gitHubActionsSubjects: {
        name: 'github-oidc-${uniqueString(subject)}'
        issuer: gitHubActionsIssuer
        subject: subject
        audiences: [
          gitHubActionsAudience
        ]
      }
    ]
  }
}

@description('The resource ID of the App Service Plan.')
output appServicePlanResourceId string = appServicePlan.id

@description('The name of the App Service Plan.')
output appServicePlanNameOutput string = appServicePlan.name

@description('The resource ID of the user managed identity.')
output userManagedIdentityResourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity.')
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity.')
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId

@description('The name of the user managed identity.')
output userManagedIdentityName string = userManagedIdentity.outputs.identityName
