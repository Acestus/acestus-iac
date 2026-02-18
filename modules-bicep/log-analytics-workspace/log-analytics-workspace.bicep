// Opinionated Log Analytics workspace module following Acestus standards

metadata name = 'Acestus Log Analytics Workspace'
metadata description = 'Log Analytics Workspace module with Acestus monitoring standards'
metadata version = '1.1.0'

@description('Name of the Log Analytics workspace')
param name string

@description('Location for the workspace')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('SKU for the workspace')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
  'Premium'
  'Standard'
  'CapacityReservation'
  'LACluster'
])
param sku string = 'PerGB2018'

@description('Capacity reservation level in GB (only for CapacityReservation SKU)')
param capacityReservationLevel int = 100

@description('Data retention period in days (legacy parameter - use dataRetention for AVM compatibility). Set to 0 to use dataRetention.')
param retentionInDays int = 0

@description('Data retention period in days (AVM-compatible parameter)')
@minValue(30)
@maxValue(730)
param dataRetention int = 90

// Resolve retention - prefer retentionInDays if explicitly set (> 0), otherwise use dataRetention
var resolvedRetention = retentionInDays > 0 ? retentionInDays : dataRetention

@description('Daily quota for data ingestion in GB (-1 for no limit)')
param dailyQuotaGb int = -1

@description('Enable public network access for ingestion')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable public network access for query')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Disable local authentication (legacy parameter - use features object for AVM compatibility)')
param disableLocalAuth bool = false

@description('Features object (AVM-compatible). Supports enableLogAccessUsingOnlyResourcePermissions and disableLocalAuth.')
param features object = {}

// Resolve features - use features object if provided, otherwise build from legacy param
var resolvedFeatures = !empty(features) ? features : {
  disableLocalAuth: disableLocalAuth
}

@description('Enable purge data on 30 days')
param forceCmkForQuery bool = false

@description('Data sources to configure')
param dataSources array = []

@description('Linked storage accounts')
param linkedStorageAccounts array = []

@description('Solutions to enable')
param solutions array = []

@description('Saved searches to create')
param savedSearches array = []

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
      capacityReservationLevel: sku == 'CapacityReservation' ? capacityReservationLevel : null
    }
    retentionInDays: resolvedRetention
    workspaceCapping: dailyQuotaGb > 0 ? {
      dailyQuotaGb: dailyQuotaGb
    } : null
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      disableLocalAuth: resolvedFeatures.?disableLocalAuth ?? false
      enableLogAccessUsingOnlyResourcePermissions: resolvedFeatures.?enableLogAccessUsingOnlyResourcePermissions ?? false
    }
    forceCmkForQuery: forceCmkForQuery
  }
}

// Data sources
resource dataSourceResources 'Microsoft.OperationalInsights/workspaces/dataSources@2023-11-01' = [for dataSource in dataSources: {
  parent: logAnalyticsWorkspace
  name: dataSource.name
  kind: dataSource.kind
  properties: dataSource.properties
}]

// Linked storage accounts
resource linkedStorageAccountResources 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2023-11-01' = [for account in linkedStorageAccounts: {
  parent: logAnalyticsWorkspace
  name: account.dataSourceType
  properties: {
    storageAccountIds: account.storageAccountIds
  }
}]

// Solutions
resource solutionResources 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution.name}(${name})'
  location: location
  tags: tags
  plan: {
    name: '${solution.name}(${name})'
    publisher: solution.?publisher ?? 'Microsoft'
    product: 'OMSGallery/${solution.name}'
    promotionCode: ''
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}]

// Saved searches
resource savedSearchResources 'Microsoft.OperationalInsights/workspaces/savedSearches@2023-11-01' = [for search in savedSearches: {
  parent: logAnalyticsWorkspace
  name: search.name
  properties: {
    displayName: search.displayName
    category: search.category
    query: search.query
    functionAlias: search.?functionAlias ?? null
    functionParameters: search.?functionParameters ?? null
  }
}]

@description('The resource ID of the Log Analytics workspace')
output resourceId string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics workspace')
output name string = logAnalyticsWorkspace.name

@description('The workspace ID (customer ID) - legacy output name')
output workspaceId string = logAnalyticsWorkspace.properties.customerId

@description('The workspace ID (customer ID) - AVM-compatible output name')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.properties.customerId
