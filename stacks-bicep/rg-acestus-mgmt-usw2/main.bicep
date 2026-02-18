param sites_func_teamsalert_mgmt_usw_001_name string = 'func-teamsalert-mgmt-usw-001'
param serverfarms_plan_acestus_mgmt_eus2_001_name string = 'plan-acestus-mgmt-eus2-001'
param components_ai_acestus_mgmt_eus2_001_name string = 'ai-acestus-mgmt-eus2-001'
param actionGroups_ag_emailalert_mgmt_eus2_001_name string = 'ag-emailalert-mgmt-eus2-001'
param actionGroups_ag_teamsalert_mgmt_eus2_001_name string = 'ag-teamsalert-mgmt-eus2-001'
param smartdetectoralertrules_failure_anomalies_ai_acestus_mgmt_eus2_001_name string = 'failure anomalies - ai-acestus-mgmt-eus2-001'
param actiongroups_application_insights_smart_detection_externalid string = '/subscriptions/<subscription-id>/resourceGroups/azurenamingtool/providers/microsoft.insights/actiongroups/application insights smart detection'
param workspaces_Acestus_law_externalid string = '/subscriptions/<subscription-id>/resourceGroups/Acestus-mgmt/providers/Microsoft.OperationalInsights/workspaces/Acestus-law'

resource actionGroups_ag_emailalert_mgmt_eus2_001_name_resource 'microsoft.insights/actionGroups@2024-10-01-preview' = {
  name: actionGroups_ag_emailalert_mgmt_eus2_001_name
  location: 'Global'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  properties: {
    groupShortName: 'FabricEmail'
    enabled: true
    emailReceivers: [
      {
        name: 'ExecutionEmail'
        emailAddress: 'user@example.com'
        useCommonAlertSchema: true
      }
    ]
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: []
    armRoleReceivers: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_resource 'microsoft.insights/components@2020-02-02' = {
  name: components_ai_acestus_mgmt_eus2_001_name
  location: 'westus2'
  tags: {
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
    Environment: 'mgmt'
  }
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: workspaces_Acestus_law_externalid
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource serverfarms_plan_acestus_mgmt_eus2_001_name_resource 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: serverfarms_plan_acestus_mgmt_eus2_001_name
  location: 'West US 2'
  tags: {
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
    Environment: 'mgmt'
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
    asyncScalingEnabled: false
  }
}

resource smartdetectoralertrules_failure_anomalies_ai_acestus_mgmt_eus2_001_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2021-04-01' = {
  name: smartdetectoralertrules_failure_anomalies_ai_acestus_mgmt_eus2_001_name
  location: 'global'
  tags: {
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
    Environment: 'mgmt'
  }
  properties: {
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    state: 'Enabled'
    severity: 'Sev3'
    frequency: 'PT1M'
    detector: {
      id: 'FailureAnomaliesDetector'
    }
    scope: [
      components_ai_acestus_mgmt_eus2_001_name_resource.id
    ]
    actionGroups: {
      groupIds: [
        actiongroups_application_insights_smart_detection_externalid
      ]
    }
  }
}

resource actionGroups_ag_teamsalert_mgmt_eus2_001_name_resource 'microsoft.insights/actionGroups@2024-10-01-preview' = {
  name: actionGroups_ag_teamsalert_mgmt_eus2_001_name
  location: 'Global'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  properties: {
    groupShortName: 'FabricTeams'
    enabled: true
    emailReceivers: []
    smsReceivers: []
    webhookReceivers: []
    eventHubReceivers: []
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: []
    voiceReceivers: []
    logicAppReceivers: []
    azureFunctionReceivers: [
      {
        name: 'AlertTransformer'
        functionAppResourceId: sites_func_teamsalert_mgmt_usw_001_name_resource.id
        functionName: 'alert_transformer'
        httpTriggerUrl: 'https:
        useCommonAlertSchema: false
      }
    ]
    armRoleReceivers: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_degradationindependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'degradationindependencyduration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'degradationindependencyduration'
      DisplayName: 'Degradation in dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_degradationinserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'degradationinserverresponsetime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'degradationinserverresponsetime'
      DisplayName: 'Degradation in server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_digestMailConfiguration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'digestMailConfiguration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'digestMailConfiguration'
      DisplayName: 'Digest Mail Configuration'
      Description: 'This rule describes the digest mail preferences'
      HelpUrl: 'www.homail.com'
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_billingdatavolumedailyspikeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_billingdatavolumedailyspikeextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_billingdatavolumedailyspikeextension'
      DisplayName: 'Abnormal rise in daily data volume (preview)'
      Description: 'This detection rule automatically analyzes the billing data generated by your application, and can warn you about an unusual increase in your application\'s billing costs'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_canaryextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_canaryextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_canaryextension'
      DisplayName: 'Canary extension'
      Description: 'Canary extension'
      HelpUrl: 'https:
      IsHidden: true
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_exceptionchangeextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_exceptionchangeextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_exceptionchangeextension'
      DisplayName: 'Abnormal rise in exception volume (preview)'
      Description: 'This detection rule automatically analyzes the exceptions thrown in your application, and can warn you about unusual patterns in your exception telemetry.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_memoryleakextension 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_memoryleakextension'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_memoryleakextension'
      DisplayName: 'Potential memory leak detected (preview)'
      Description: 'This detection rule automatically analyzes the memory consumption of each process in your application, and can warn you about potential memory leaks or increased memory consumption.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_securityextensionspackage 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_securityextensionspackage'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_securityextensionspackage'
      DisplayName: 'Potential security issue detected (preview)'
      Description: 'This detection rule automatically analyzes the telemetry generated by your application and detects potential security issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_extension_traceseveritydetector 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'extension_traceseveritydetector'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'extension_traceseveritydetector'
      DisplayName: 'Degradation in trace severity ratio (preview)'
      Description: 'This detection rule automatically analyzes the trace logs emitted from your application, and can warn you about unusual patterns in the severity of your trace telemetry.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_longdependencyduration 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'longdependencyduration'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'longdependencyduration'
      DisplayName: 'Long dependency duration'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_migrationToAlertRulesCompleted 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'migrationToAlertRulesCompleted'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'migrationToAlertRulesCompleted'
      DisplayName: 'Migration To Alert Rules Completed'
      Description: 'A configuration that controls the migration state of Smart Detection to Smart Alerts'
      HelpUrl: 'https:
      IsHidden: true
      IsEnabledByDefault: false
      IsInPreview: true
      SupportsEmailNotifications: false
    }
    Enabled: false
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_slowpageloadtime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'slowpageloadtime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'slowpageloadtime'
      DisplayName: 'Slow page load time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource components_ai_acestus_mgmt_eus2_001_name_slowserverresponsetime 'microsoft.insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
  parent: components_ai_acestus_mgmt_eus2_001_name_resource
  name: 'slowserverresponsetime'
  location: 'westus2'
  properties: {
    RuleDefinitions: {
      Name: 'slowserverresponsetime'
      DisplayName: 'Slow server response time'
      Description: 'Smart Detection rules notify you of performance anomaly issues.'
      HelpUrl: 'https:
      IsHidden: false
      IsEnabledByDefault: true
      IsInPreview: false
      SupportsEmailNotifications: true
    }
    Enabled: true
    SendEmailsToSubscriptionOwners: true
    CustomEmails: []
  }
}

resource sites_func_teamsalert_mgmt_usw_001_name_resource 'Microsoft.Web/sites@2024-11-01' = {
  name: sites_func_teamsalert_mgmt_usw_001_name
  location: 'West US 2'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_func_teamsalert_mgmt_usw_001_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_func_teamsalert_mgmt_usw_001_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_plan_acestus_mgmt_eus2_001_name_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    outboundVnetRouting: {
      allTraffic: false
      applicationTraffic: false
      contentShareTraffic: false
      imagePullTraffic: false
      backupRestoreTraffic: false
    }
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientAffinityProxyEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Optional'
    hostNamesDisabled: false
    ipMode: 'IPv4'
    customDomainVerificationId: 'B237E2B8FB5E2546E528FC335F90A6017977CE7ADC22A23F67997D1D2439B6B9'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    endToEndEncryptionEnabled: false
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_func_teamsalert_mgmt_usw_001_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_func_teamsalert_mgmt_usw_001_name_resource
  name: 'ftp'
  location: 'West US 2'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  properties: {
    allow: true
  }
}

resource sites_func_teamsalert_mgmt_usw_001_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-11-01' = {
  parent: sites_func_teamsalert_mgmt_usw_001_name_resource
  name: 'scm'
  location: 'West US 2'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  properties: {
    allow: true
  }
}

resource sites_func_teamsalert_mgmt_usw_001_name_web 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: sites_func_teamsalert_mgmt_usw_001_name_resource
  name: 'web'
  location: 'West US 2'
  tags: {
    Environment: 'Production'
    Application: 'FabricScheduler-AlertTransformer'
    ManagedBy: 'Bicep-AVM'
    CostCenter: '510-Infrastructure-Production'
    Department: '510-Infrastructure'
  }
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$func-teamsalert-mgmt-usw-001'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Enabled'
    localMySqlEnabled: false
    managedServiceIdentityId: 57816
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
    http20ProxyFlag: 0
  }
}

resource sites_func_teamsalert_mgmt_usw_001_name_sites_func_teamsalert_mgmt_usw_001_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2024-11-01' = {
  parent: sites_func_teamsalert_mgmt_usw_001_name_resource
  name: '${sites_func_teamsalert_mgmt_usw_001_name}.azurewebsites.net'
  location: 'West US 2'
  properties: {
    siteName: 'func-teamsalert-mgmt-usw-001'
    hostNameType: 'Verified'
  }
}
