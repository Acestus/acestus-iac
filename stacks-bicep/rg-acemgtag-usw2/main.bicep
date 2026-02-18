targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = 'Global'

@description('The name of the project, used for naming resources.')
param projectName string

@description('The environment name, used for naming resources.')
param environment string

@description('The Cloud Adoption Framework location, used for naming resources.')
param CAFLocation string

@description('The instance number, used for naming resources.')
param instanceNumber string

@description('Email address for alerts.')
param alertEmailAddress string

@description('Resource ID of the Function App for Teams alerts.')
param functionAppResourceId string

@description('Default hostname of the Function App.')
param functionAppDefaultHostname string

@description('Tags to be applied to all resources.')
param tags object = {}

var emailActionGroupName = 'ag-${projectName}-email-${environment}-${CAFLocation}-${instanceNumber}'
var teamsActionGroupName = 'ag-${projectName}-teams-${environment}-${CAFLocation}-${instanceNumber}'

resource emailActionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: emailActionGroupName
  location: location
  tags: tags
  properties: {
    groupShortName: 'Email'
    enabled: true
    emailReceivers: [
      {
        name: 'AlertEmail'
        emailAddress: alertEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

resource teamsActionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: teamsActionGroupName
  location: location
  tags: tags
  properties: {
    groupShortName: 'Teams'
    enabled: true
    azureFunctionReceivers: [
      {
        name: 'AlertTransformer'
        functionAppResourceId: functionAppResourceId
        functionName: 'Alert_Transformer'
        httpTriggerUrl: 'https:
        useCommonAlertSchema: true
      }
    ]
  }
}

@description('The resource ID of the email action group.')
output emailActionGroupResourceId string = emailActionGroup.id

@description('The resource ID of the teams action group.')
output teamsActionGroupResourceId string = teamsActionGroup.id
