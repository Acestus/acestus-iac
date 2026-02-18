using '../../main.bicep'

param projectName = 'aceedm'
param environment = 'dev'
param CAFLocation = 'usw2'
param instanceNumber = '001'
param workspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Sbox-530-EnterpriseDataManagement'
  Project: 'Acestus EDM Platform'
}

