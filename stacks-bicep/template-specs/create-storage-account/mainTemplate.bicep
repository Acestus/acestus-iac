param ProjectName string
param Environment string = 'dev'
param InstanceNumber string = '001'

var storageSKU = 'Standard_ZRS'
var location = 'westus2'
var ResourceName = 'st'
var Resourcelocation = 'usw2'
var storageName = '${ResourceName}${ProjectName}${Environment}${Resourcelocation}${InstanceNumber}'
var allowedIP = '192.16.122.254'

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: storageName
  params: {
    name: storageName
    location: location
    skuName: storageSKU
    allowSharedKeyAccess: false
    requireInfrastructureEncryption: true
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: allowedIP
        }
      ]
    }
  }
}


output storageAccountName string = storageAccount.outputs.name  
