using '../../main.bicep'

param projectName = 'aceanakv'
param environment = 'prd'
param CAFLocation = 'usw2'
param instanceNumber = '002'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Corp-710-Analytics'
  Project: 'Acestus Analytics Platform'
}
