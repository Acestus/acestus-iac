$Subscription = "Acestus"
$StackName = "stack-mgmt100-corp-eus2-dev"
$RGName = "rg-mgmt100-corp-eus2-dev"
$storageAccountName = "stmgmt100corpeus2dev"

Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table
