using 'main.bicep'

param projectName = 'skmgtkv'
param environment = 'prd'
param CAFLocation = 'eus2'
param instanceNumber = '001'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Acestus'
  Project: 'Acestus Analytics Platform'
}
