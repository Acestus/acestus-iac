using '../../main.bicep'

param projectName = 'aceedm'
param environment = 'dev'
param CAFLocation = 'eus2'
param instanceNumber = '001'
param workspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

param tags = {
  ManagedBy: 'https://github.com/acestus/acestus-iac'
  CreatedBy: 'acestus'
  Subscription: 'Acestus'
  Project: 'Acestus EDM Platform'
}
