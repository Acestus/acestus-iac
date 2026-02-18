using './example-using-custom-storage.bicep'

param projectName = 'example'
param environment = 'dev'
param locationCode = 'usw2'
param instanceNumber = '001'
param location = 'westus2'
param allowedIP = '192.168.1.100/32'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: 'automation'
  Environment: 'dev'
  Project: 'Acestus Custom Module Example'
}
