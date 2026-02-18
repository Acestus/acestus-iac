$Subscription = "Corp-100-Marketing"
$StackName = "stack-mgmt100-corp-usw2-prd"
$RGName = "rg-mgmt100-corp-usw2-prd"
$storageAccountName = "stmgmt100corpusw2prd"

Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName 
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table