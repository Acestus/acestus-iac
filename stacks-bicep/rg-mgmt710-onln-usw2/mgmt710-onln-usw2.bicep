param location string
param storageSKU string
param storageName string
param allowedIP string

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  name: storageName
  params: {
    name: storageName
    location: location
    skuName: storageSKU
    defaultToOAuthAuthentication: false
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: allowedIP
        }
      ]
    }
    blobServices: {
      deleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
      }
      automaticSnapshotPolicyEnabled: false
      containerDeleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
      }
      lastAccessTimeTrackingPolicy: {
        enable: true
        name: 'AccessTimeTracking' 
        trackingGranularityInDays: 1
      }
    }
    allowSharedKeyAccess: false
  }
}

output storageAccountName string = storageAccount.outputs.name

