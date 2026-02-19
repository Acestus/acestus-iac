$Subscription = "Acestus"
$StackName = "stack-mgmt510-corp-eus2-dev"
$RGName = "rg-mgmt510-corp-eus2-dev"
$storageAccountName = "stmgmt510corpeus2dev"

Set-AzContext -Subscription $Subscription
Get-AzSubscription -SubscriptionName $Subscription
Get-AzResourceGroup -Name $RGName | Format-Table
Get-AzResourceGroupDeploymentStack -Name $StackName -ResourceGroupName $RGName
Get-AzStorageAccount -ResourceGroupName $RGName -Name $storageAccountName | Format-Table
