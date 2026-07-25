using './main.bicep'

param location = 'southcentralus'
param projectName = 'crm'
param environment = 'dev'
param CAFLocation = 'scus'
param instanceNumber = '001'
param tags = {
  CreatedBy: 'acestus'
  ManagedBy: 'Bicep'
}
