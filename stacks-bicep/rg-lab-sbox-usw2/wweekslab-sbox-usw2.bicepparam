using './lab-sbox-usw2.bicep'

var ProjectName = 'lab'
var Environment = 'sbox'
var CAFLocation = 'usw2'
var InstanceNumber = '001'

param storageName = 'st${ProjectName}${Environment}${CAFLocation}${InstanceNumber}'
param location = 'westus2'
param storageSKU = 'Standard_ZRS'
param allowedIP = '192.16.122.254'
param userAssignedId = '/subscriptions/<subscription-id>/resourceGroups/rg-labmgmt-sbox-usw2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/umi-labmgmt-sbox-usw2-018'
param keyVaultid = '/subscriptions/<subscription-id>/resourceGroups/rg-labmgmt-sbox-usw2/providers/Microsoft.KeyVault/vaults/kv-labmgmt-sbox-usw2-018'
param keyName = 'key-labmgmt-sbox-usw2-018'

