$Subscription = "Management"
$StackName = "stack-mgmt510-corp-usw2-prd"
$RGName = "rg-mgmt510-corp-usw2-prd"
$storageAccountName = "stmgmt510corpusw2prd"


Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName 
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table