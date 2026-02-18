using '../../main.bicep'

param projectName = 'acemgtag'
param environment = 'prd'
param CAFLocation = 'eus2'
param instanceNumber = '001'

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Sbox-710-Analytics'
  Project: 'Acestus Analytics Platform'
}
