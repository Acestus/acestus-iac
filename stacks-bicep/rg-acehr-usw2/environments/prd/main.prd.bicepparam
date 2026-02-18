using '../../main.bicep'

param projectName = 'acehr'
param environment = 'prd'
param region = 'usw2'
param instanceNumber = '001'

param aspSKU = 'EP1'
param linuxASPinstanceNumber = 'lnx'
param workspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Corp-750-HumanResources'
  Project: 'Acestus Analytics Platform'
  CAFName: '${projectName}-${environment}-${region}-${instanceNumber}'
}
