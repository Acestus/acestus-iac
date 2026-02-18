// Opinionated private DNS zone module following Acestus standards

metadata name = 'Acestus Private DNS Zone'
metadata description = 'Private DNS Zone module with Acestus networking standards'
metadata version = '1.0.0'

@description('Name of the private DNS zone (e.g., privatelink.blob.core.windows.net)')
param name string

@description('Tags to apply to the resource')
param tags object = {}

@description('Virtual network links to create')
param virtualNetworkLinks array = []

@description('A records to create')
param aRecords array = []

@description('AAAA records to create')
param aaaaRecords array = []

@description('CNAME records to create')
param cnameRecords array = []

@description('MX records to create')
param mxRecords array = []

@description('PTR records to create')
param ptrRecords array = []

@description('SRV records to create')
param srvRecords array = []

@description('TXT records to create')
param txtRecords array = []

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: 'global'
  tags: tags
}

// Virtual network links
resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [for link in virtualNetworkLinks: {
  parent: privateDnsZone
  name: link.name
  location: 'global'
  tags: tags
  properties: {
    virtualNetwork: {
      id: link.virtualNetworkId
    }
    registrationEnabled: link.?registrationEnabled ?? false
  }
}]

// A records
resource aRecordResources 'Microsoft.Network/privateDnsZones/A@2024-06-01' = [for record in aRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    aRecords: [for ip in record.ipv4Addresses: {
      ipv4Address: ip
    }]
  }
}]

// AAAA records
resource aaaaRecordResources 'Microsoft.Network/privateDnsZones/AAAA@2024-06-01' = [for record in aaaaRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    aaaaRecords: [for ip in record.ipv6Addresses: {
      ipv6Address: ip
    }]
  }
}]

// CNAME records
resource cnameRecordResources 'Microsoft.Network/privateDnsZones/CNAME@2024-06-01' = [for record in cnameRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    cnameRecord: {
      cname: record.cname
    }
  }
}]

// MX records
resource mxRecordResources 'Microsoft.Network/privateDnsZones/MX@2024-06-01' = [for record in mxRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    mxRecords: record.mxRecords
  }
}]

// PTR records
resource ptrRecordResources 'Microsoft.Network/privateDnsZones/PTR@2024-06-01' = [for record in ptrRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    ptrRecords: [for ptr in record.ptrRecords: {
      ptrdname: ptr
    }]
  }
}]

// SRV records
resource srvRecordResources 'Microsoft.Network/privateDnsZones/SRV@2024-06-01' = [for record in srvRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    srvRecords: record.srvRecords
  }
}]

// TXT records
resource txtRecordResources 'Microsoft.Network/privateDnsZones/TXT@2024-06-01' = [for record in txtRecords: {
  parent: privateDnsZone
  name: record.name
  properties: {
    ttl: record.?ttl ?? 3600
    txtRecords: [for txt in record.values: {
      value: [txt]
    }]
  }
}]

@description('The resource ID of the private DNS zone')
output resourceId string = privateDnsZone.id

@description('The name of the private DNS zone')
output name string = privateDnsZone.name
