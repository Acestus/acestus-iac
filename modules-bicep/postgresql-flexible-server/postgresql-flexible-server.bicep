// Opinionated PostgreSQL Flexible Server module following Acestus standards

metadata name = 'Acestus PostgreSQL Flexible Server'
metadata description = 'PostgreSQL Flexible Server module with Acestus security standards'
metadata version = '1.0.0'

@description('Name of the PostgreSQL server')
param name string

@description('Location for the server')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Administrator login name')
@secure()
param administratorLogin string

@description('Administrator login password')
@secure()
param administratorLoginPassword string

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
  '15'
  '16'
])
param version string = '16'

@description('SKU tier')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param tier string = 'GeneralPurpose'

@description('SKU name (e.g., Standard_D2s_v3)')
param skuName string = 'Standard_D2s_v3'

@description('Storage size in GB')
@minValue(32)
@maxValue(32767)
param storageSizeGB int = 128

@description('Storage tier')
@allowed([
  'P4'
  'P6'
  'P10'
  'P15'
  'P20'
  'P30'
  'P40'
  'P50'
  'P60'
  'P70'
  'P80'
])
param storageTier string = 'P10'

@description('Enable storage auto grow')
@allowed([
  'Enabled'
  'Disabled'
])
param autoGrow string = 'Enabled'

@description('Backup retention days')
@minValue(7)
@maxValue(35)
param backupRetentionDays int = 35

@description('Enable geo-redundant backup')
@allowed([
  'Enabled'
  'Disabled'
])
param geoRedundantBackup string = 'Enabled'

@description('High availability mode')
@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
param highAvailabilityMode string = 'ZoneRedundant'

@description('Standby availability zone')
param standbyAvailabilityZone string = '2'

@description('Availability zone')
param availabilityZone string = '1'

@description('Virtual network subnet resource ID for private access')
param delegatedSubnetResourceId string = ''

@description('Private DNS zone resource ID')
param privateDnsZoneResourceId string = ''

@description('Public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Firewall rules (only when publicNetworkAccess is Enabled)')
param firewallRules array = []

@description('Databases to create')
param databases array = []

@description('Server configurations')
param configurations array = []

@description('User assigned identity resource ID')
param userAssignedIdentityId string = ''

@description('Enable Microsoft Entra only authentication')
param enableEntraOnlyAuth bool = false

@description('Microsoft Entra admin object ID')
param entraAdminObjectId string = ''

@description('Microsoft Entra admin principal name')
param entraAdminPrincipalName string = ''

@description('Microsoft Entra admin principal type')
@allowed([
  'Group'
  'ServicePrincipal'
  'User'
])
param entraAdminPrincipalType string = 'Group'

// Build network configuration
var network = !empty(delegatedSubnetResourceId) ? {
  delegatedSubnetResourceId: delegatedSubnetResourceId
  privateDnsZoneArmResourceId: privateDnsZoneResourceId
  publicNetworkAccess: 'Disabled'
} : {
  publicNetworkAccess: publicNetworkAccess
}

// Build identity
var identity = !empty(userAssignedIdentityId) ? {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${userAssignedIdentityId}': {}
  }
} : null

// Build authentication config
var authConfig = enableEntraOnlyAuth ? {
  activeDirectoryAuth: 'Enabled'
  passwordAuth: 'Disabled'
} : {
  activeDirectoryAuth: !empty(entraAdminObjectId) ? 'Enabled' : 'Disabled'
  passwordAuth: 'Enabled'
}

resource postgreSqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2024-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: tier
  }
  identity: identity
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    authConfig: authConfig
    storage: {
      storageSizeGB: storageSizeGB
      tier: storageTier
      autoGrow: autoGrow
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: highAvailabilityMode
      standbyAvailabilityZone: highAvailabilityMode != 'Disabled' ? standbyAvailabilityZone : null
    }
    availabilityZone: availabilityZone
    network: network
  }
}

// Entra admin
resource entraAdmin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2024-08-01' = if (!empty(entraAdminObjectId)) {
  parent: postgreSqlServer
  name: entraAdminObjectId
  properties: {
    principalName: entraAdminPrincipalName
    principalType: entraAdminPrincipalType
    tenantId: subscription().tenantId
  }
}

// Firewall rules
resource firewallRuleResources 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2024-08-01' = [for rule in firewallRules: if (publicNetworkAccess == 'Enabled') {
  parent: postgreSqlServer
  name: rule.name
  properties: {
    startIpAddress: rule.startIpAddress
    endIpAddress: rule.endIpAddress
  }
}]

// Databases
resource databaseResources 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2024-08-01' = [for db in databases: {
  parent: postgreSqlServer
  name: db.name
  properties: {
    charset: db.?charset ?? 'UTF8'
    collation: db.?collation ?? 'en_US.utf8'
  }
}]

// Configurations
resource configurationResources 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2024-08-01' = [for config in configurations: {
  parent: postgreSqlServer
  name: config.name
  properties: {
    value: config.value
    source: 'user-override'
  }
}]

@description('The resource ID of the PostgreSQL server')
output resourceId string = postgreSqlServer.id

@description('The name of the PostgreSQL server')
output name string = postgreSqlServer.name

@description('The FQDN of the PostgreSQL server')
output fqdn string = postgreSqlServer.properties.fullyQualifiedDomainName
