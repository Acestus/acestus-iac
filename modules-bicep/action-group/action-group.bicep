// Opinionated Action Group module following Acestus standards

metadata name = 'Acestus Action Group'
metadata description = 'Action Group module with Acestus monitoring standards'
metadata version = '1.0.0'

@description('Name of the action group')
param name string

@description('Short name for the action group (max 12 characters)')
@maxLength(12)
param shortName string

@description('Location for the action group (use global for action groups)')
param location string = 'global'

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable the action group')
param enabled bool = true

@description('Email receivers configuration')
param emailReceivers array = []

@description('SMS receivers configuration')
param smsReceivers array = []

@description('Webhook receivers configuration')
param webhookReceivers array = []

@description('Azure app push receivers configuration')
param azureAppPushReceivers array = []

@description('ITSM receivers configuration')
param itsmReceivers array = []

@description('Automation runbook receivers configuration')
param automationRunbookReceivers array = []

@description('Voice receivers configuration')
param voiceReceivers array = []

@description('Logic app receivers configuration')
param logicAppReceivers array = []

@description('Azure function receivers configuration')
param azureFunctionReceivers array = []

@description('ARM role receivers configuration')
param armRoleReceivers array = []

@description('Event hub receivers configuration')
param eventHubReceivers array = []

resource actionGroup 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    groupShortName: shortName
    enabled: enabled
    emailReceivers: [for receiver in emailReceivers: {
      name: receiver.name
      emailAddress: receiver.emailAddress
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
    }]
    smsReceivers: [for receiver in smsReceivers: {
      name: receiver.name
      countryCode: receiver.countryCode
      phoneNumber: receiver.phoneNumber
    }]
    webhookReceivers: [for receiver in webhookReceivers: {
      name: receiver.name
      serviceUri: receiver.serviceUri
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
      useAadAuth: receiver.?useAadAuth ?? false
      objectId: receiver.?objectId ?? null
      identifierUri: receiver.?identifierUri ?? null
      tenantId: receiver.?tenantId ?? null
    }]
    azureAppPushReceivers: [for receiver in azureAppPushReceivers: {
      name: receiver.name
      emailAddress: receiver.emailAddress
    }]
    itsmReceivers: itsmReceivers
    automationRunbookReceivers: [for receiver in automationRunbookReceivers: {
      name: receiver.name
      automationAccountId: receiver.automationAccountId
      runbookName: receiver.runbookName
      webhookResourceId: receiver.webhookResourceId
      isGlobalRunbook: receiver.?isGlobalRunbook ?? false
      serviceUri: receiver.?serviceUri ?? null
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
    }]
    voiceReceivers: [for receiver in voiceReceivers: {
      name: receiver.name
      countryCode: receiver.countryCode
      phoneNumber: receiver.phoneNumber
    }]
    logicAppReceivers: [for receiver in logicAppReceivers: {
      name: receiver.name
      resourceId: receiver.resourceId
      callbackUrl: receiver.callbackUrl
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
    }]
    azureFunctionReceivers: [for receiver in azureFunctionReceivers: {
      name: receiver.name
      functionAppResourceId: receiver.functionAppResourceId
      functionName: receiver.functionName
      httpTriggerUrl: receiver.httpTriggerUrl
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
    }]
    armRoleReceivers: [for receiver in armRoleReceivers: {
      name: receiver.name
      roleId: receiver.roleId
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
    }]
    eventHubReceivers: [for receiver in eventHubReceivers: {
      name: receiver.name
      subscriptionId: receiver.?subscriptionId ?? subscription().subscriptionId
      eventHubNameSpace: receiver.eventHubNameSpace
      eventHubName: receiver.eventHubName
      useCommonAlertSchema: receiver.?useCommonAlertSchema ?? true
      tenantId: receiver.?tenantId ?? subscription().tenantId
    }]
  }
}

@description('The resource ID of the action group')
output resourceId string = actionGroup.id

@description('The name of the action group')
output name string = actionGroup.name
