targetScope = 'resourceGroup'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the project, used for naming resources.')
param projectName string

@description('The environment name, used for naming resources.')
param environment string

@description('The Cloud Adoption Framework location, used for naming resources.')
param CAFLocation string

@description('The instance number, used for naming resources.')
param instanceNumber string

@description('Tags to be applied to all resources.')
param tags object = {}

@description('The Aspire dashboard container image.')
param aspireDashboardImage string = 'mcr.microsoft.com/dotnet/aspire-dashboard:latest'

@description('The Log Analytics workspace daily quota in GB.')
param logAnalyticsDailyQuotaGb int = 5

@description('The Container Apps CPU allocation.')
param containerCpu string = '0.5'

@description('The Container Apps memory allocation.')
param containerMemory string = '1Gi'

@description('The minimum number of replicas.')
param minReplicas int = 1

@description('The maximum number of replicas.')
param maxReplicas int = 3

var logAnalyticsWorkspaceName = 'law-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var containerAppsEnvironmentName = 'cae-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var containerAppName = 'ca-aspire-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'
var userManagedIdentityName = 'umi-${projectName}-${environment}-${CAFLocation}-${instanceNumber}'

module userManagedIdentity 'br:acracemgtcrprdeus2001.azurecr.io/bicep/modules/user-managed-identity:v1.1.0' = {
  params: {
    name: userManagedIdentityName
    location: location
    tags: tags
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.15.0' = {
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    dailyQuotaGb: logAnalyticsDailyQuotaGb
    dataRetention: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
  }
}

module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.11.3' = {
  params: {
    name: containerAppsEnvironmentName
    location: location
    tags: tags
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
        sharedKey: logAnalyticsWorkspace.outputs.primarySharedKey
      }
    }
    managedIdentities: {
      userAssignedResourceIds: [userManagedIdentity.outputs.resourceId]
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundant: false
  }
}

module aspireDashboard 'br/public:avm/res/app/container-app:0.20.0' = {
  params: {
    name: containerAppName
    location: location
    tags: tags
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    managedIdentities: {
      userAssignedResourceIds: [userManagedIdentity.outputs.resourceId]
    }
    containers: [
      {
        name: 'aspire-dashboard'
        image: aspireDashboardImage
        resources: {
          cpu: containerCpu
          memory: containerMemory
        }
        env: [
          {
            name: 'ASPNETCORE_ENVIRONMENT'
            value: 'Production'
          }
          {
            name: 'ASPNETCORE_URLS'
            value: 'http:
          }
          {
            name: 'DOTNET_DASHBOARD_OTLP_ENDPOINT_URL'
            value: 'http:
          }
          {
            name: 'DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS'
            value: 'false'
          }
        ]
        probes: [
          {
            type: 'Liveness'
            httpGet: {
              path: '/health'
              port: 8080
              scheme: 'HTTP'
            }
            initialDelaySeconds: 30
            periodSeconds: 30
            timeoutSeconds: 5
            failureThreshold: 3
          }
          {
            type: 'Readiness'
            httpGet: {
              path: '/health/ready'
              port: 8080
              scheme: 'HTTP'
            }
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          }
        ]
      }
    ]
    ingressExternal: true
    ingressAllowInsecure: false
    ingressTargetPort: 8080
    ingressTransport: 'http'
    additionalPortMappings: [
      {
        external: true
        targetPort: 18889
        exposedPort: 18889
      }
    ]
    scaleSettings: {
      minReplicas: minReplicas
      maxReplicas: maxReplicas
      cooldownPeriod: 300
      pollingInterval: 30
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
  }
}

@description('The resource ID of the Log Analytics workspace.')
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.outputs.resourceId

@description('The name of the Log Analytics workspace.')
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.name

@description('The workspace ID of the Log Analytics workspace.')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId

@description('The resource ID of the Container Apps Environment.')
output containerAppsEnvironmentResourceId string = containerAppsEnvironment.outputs.resourceId

@description('The name of the Container Apps Environment.')
output containerAppsEnvironmentName string = containerAppsEnvironment.outputs.name

@description('The default domain of the Container Apps Environment.')
output containerAppsEnvironmentDefaultDomain string = containerAppsEnvironment.outputs.defaultDomain

@description('The resource ID of the Aspire Dashboard Container App.')
output aspireDashboardResourceId string = aspireDashboard.outputs.resourceId

@description('The name of the Aspire Dashboard Container App.')
output aspireDashboardName string = aspireDashboard.outputs.name

@description('The FQDN of the Aspire Dashboard.')
output aspireDashboardFqdn string = aspireDashboard.outputs.fqdn

@description('The URL to access the Aspire Dashboard.')
output aspireDashboardUrl string = 'https:

@description('The OTLP endpoint URL for telemetry ingestion.')
output otlpEndpointUrl string = 'http:

@description('The resource ID of the user managed identity.')
output userManagedIdentityResourceId string = userManagedIdentity.outputs.resourceId

@description('The principal ID of the user managed identity.')
output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.principalId

@description('The client ID of the user managed identity.')
output userManagedIdentityClientId string = userManagedIdentity.outputs.clientId
