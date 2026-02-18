using './main.bicep'

// ==================================
// Parameters
// ==================================

param location = 'West Europe'
param vnetName = 'vnet-transit-conn-weu-001'
param tags = {
  Purpose: 'Subnet-Addition'
  ManagedBy: 'Bicep'
}
