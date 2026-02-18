using 'main.bicep'

param CAFName = 'acestus-idnt-usw2-001'
param workspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Sbox-710-Analytics'
  Project: 'Acestus Analytics Platform'
}
