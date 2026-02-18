using '../../main.bicep'

param projectName = 'test'
param environment = 'dev'
param region = 'usw2'
param instanceNumber = '001'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Environment: 'Development'
  CAFName: '${projectName}-${environment}-${region}-${instanceNumber}'
  Project: 'Custom Module Testing'
  Purpose: 'Testing custom storage account module'
  Subscription: 'Sbox-510-Infrastructure'
}
