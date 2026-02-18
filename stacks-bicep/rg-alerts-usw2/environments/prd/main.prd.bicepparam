using '../../main.bicep'

param projectName = 'alerts'
param environment = 'prd'
param CAFLocation = 'eus2'
param instanceNumber = '001'
param workspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Sbox-710-Analytics'
  Project: 'Acestus Analytics Platform'
}
