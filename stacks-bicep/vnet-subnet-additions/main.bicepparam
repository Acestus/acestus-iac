using './main.bicep'

// ==================================
// Parameters
// ==================================

param location = 'West US 2'
param vnetName = 'vnet-transit-conn-usw2-001'
param tags = {
  Purpose: 'Subnet-Addition'
  ManagedBy: 'Bicep'
}
