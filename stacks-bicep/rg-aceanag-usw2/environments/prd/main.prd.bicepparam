using '../../main.bicep'

param projectName = 'aceanag'
param environment = 'prd'
param CAFLocation = 'eus2'
param instanceNumber = '001'

param tags = {
  ManagedBy: 'https://github.com/acestus/acestus-iac'
  CreatedBy: 'acestus'
  Subscription: 'Acestus'
  Project: 'Acestus Analytics Platform'
}
